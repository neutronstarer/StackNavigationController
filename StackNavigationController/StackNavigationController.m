//
//  StackNavigationController.m
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import <pthread.h>

#import "NSObject+SNCPrivate.h"
#import "SNCTransition+Private.h"
#import "StackNavigationController.h"
#import "UINavigationController+SNCPrivate.h"
#import "UIViewController+SNCPrivate.h"

static inline void inMain(void(^block)(void)){
    if (pthread_main_np()){
        block();
        return;
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        block();
    });
}

@interface StackNavigationController ()

@property (nonatomic, assign) Class               navigationControllerClass;
@property (nonatomic, strong) NSArray             *navigationControllers;

@property (nonatomic, weak  ) UIViewController    *statusBarController;
@property (nonatomic, weak  ) UIViewController    *rotationController;
//percent driven interactive transition
@property (nonatomic, assign) NSTimeInterval      beginTime;
@property (nonatomic, assign) NSTimeInterval      animationDuration;
@property (nonatomic, assign) NSTimeInterval      animationPausedTimeOffset;
@property (nonatomic, assign) CGFloat             animationCompletionSpeed;
@property (nonatomic, strong) CADisplayLink       *displayLink;
@property (nonatomic, assign) BOOL                interacting;

@property (nonatomic, strong) UIGestureRecognizer *interactivePopGestureRecognizer;
@property (nonatomic, assign) CGPoint             gestureRecognizerStartPoint;

@property (nonatomic, strong) dispatch_queue_t    queue;
@property (nonatomic, strong) dispatch_semaphore_t lock;

@property (nonatomic, strong) NSArray             *viewWillAppearAppearances;
@property (nonatomic, strong) NSArray             *viewWillDisappearAppearances;

@property (nonatomic, copy  ) void(^interactionWillCancel)(void);
@property (nonatomic, copy  ) void(^interactionDidComplete)(void);
@end

@implementation StackNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addGestureRecognizer:self.interactivePopGestureRecognizer];
    // Do any additional setup after loading the view.
}

- (instancetype)initWithNavigationControllerClass:(nullable Class)navigationControllerClass{
    self=[self init];
    if (!self) return nil;
    self.navigationControllerClass=navigationControllerClass;
    return self;
}

- (instancetype)initWithRootViewController:(__kindof UIViewController *)rootViewController{
    self=[self init];
    if (!self) return nil;
    [self pushViewController:rootViewController animated:NO];
    return self;
}

- (instancetype)initWithViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers{
    self=[self init];
    if (!self) return nil;
    [self pushViewControllers:viewControllers animated:NO];
    return self;
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers{
    [self setViewControllers:viewControllers animated:NO];
}

//- (void)pushViewController:(__kindof UIViewController *)viewController{
//    [self pushViewController:viewController animated:YES];
//}
//
//- (void)pushViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers{
//    [self pushViewControllers:viewControllers animated:YES];
//}

//- (nullable __kindof UIViewController *)popViewController{
//    return [self popViewControllerAnimated:YES];
//}

- (nullable __kindof UIViewController *)popViewControllerAnimated:(BOOL)animated completion:(void(^_Nullable)(BOOL finished))completion{
    return [self popViewControllerWithDuration:animated?self.viewControllers.lastObject.snc_transition.expectedTransitionDuration:0 completion:completion];
}

//- (nullable NSArray<__kindof UIViewController *> *)popToRootViewController{
//    return [self popToRootViewControllerAnimated:YES];
//}

//- (nullable NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController{
//    return [self popToViewController:viewController animated:YES];
//}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers animated:(BOOL)animated{
    [self setViewControllers:viewControllers animated:animated completion:nil];
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers animated:(BOOL)animated completion:(void(^_Nullable)(BOOL finished))completion{
    [self setViewControllers:viewControllers duration:animated?viewControllers.lastObject.snc_transition.expectedTransitionDuration:0 completion:completion];
}

- (void)pushViewController:(__kindof UIViewController *)viewController animated:(BOOL)animated{
    [self pushViewController:viewController animated:animated completion:nil];
}

- (void)pushReplaceViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [self pushReplaceViewController:viewController animated:animated completion:nil];
}

- (void)pushViewController:(__kindof UIViewController *)viewController animated:(BOOL)animated completion:(void(^_Nullable)(BOOL finished))completion{
    [self pushViewController:viewController duration:animated?viewController.snc_transition.expectedTransitionDuration:0 completion:completion];
}

- (void)pushReplaceViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(BOOL))completion{
    [self pushReplaceViewController:viewController duration:animated?viewController.snc_transition.expectedTransitionDuration:0 completion:completion];
}

- (void)pushViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers animated:(BOOL)animated{
    [self pushViewControllers:viewControllers animated:animated completion:nil];
}

- (void)pushViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers animated:(BOOL)animated completion:(void(^_Nullable)(BOOL finished))completion{
    [self pushViewControllers:viewControllers duration:animated?viewControllers.lastObject.snc_transition.expectedTransitionDuration:0 completion:completion];
}

- (nullable __kindof UIViewController *)popViewControllerAnimated:(BOOL)animated{
    return [self popViewControllerAnimated:animated completion:nil];
}

- (nullable NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated{
    return [self popToRootViewControllerAnimated:animated completion:nil];
}

- (nullable NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated completion:(void(^_Nullable)(BOOL finished))completion{
    return [self popToRootViewControllerWithDuration:animated?self.viewControllers.lastObject.snc_transition.expectedTransitionDuration:0 completion:completion];
}

- (nullable NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    return [self popToViewController:viewController animated:animated completion:nil];
}

- (nullable NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^_Nullable)(BOOL finished))completion{
    return [self popToViewController:viewController duration:animated?self.viewControllers.lastObject.snc_transition.expectedTransitionDuration:0 completion:completion];
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers duration:(NSTimeInterval)duration completion:(void(^_Nullable)(BOOL finished))completion{
    if (viewControllers.count==0){
        if (completion) completion(NO);
        return;
    }
    [self _pushViewControllers:viewControllers clearRange:NSMakeRange(0, self.viewControllers.count) duration:duration completion:^(BOOL finished){
        if (completion) completion(finished);
    }];
}

- (void)pushViewController:(__kindof UIViewController *)viewController duration:(NSTimeInterval)duration completion:(void(^_Nullable)(BOOL finished))completion{
    [self _pushViewControllers:@[viewController] clearRange:NSMakeRange(0, 0) duration:duration completion:^(BOOL finished){
        if (completion) completion(finished);
    }];
}

- (void)pushReplaceViewController:(UIViewController *)viewController duration:(NSTimeInterval)duration completion:(void(^_Nullable)(BOOL finished))completion{
    [self _pushViewControllers:@[viewController] clearRange:NSMakeRange(self.navigationControllers.count-1, 1) duration:duration completion:^(BOOL finished){
        if (completion) completion(finished);
    }];
}

- (void)pushViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers duration:(NSTimeInterval)duration completion:(void(^_Nullable)(BOOL finished))completion{
    if (viewControllers.count==0){
        if (completion) completion(NO);
        return;
    }
    [self _pushViewControllers:viewControllers clearRange:NSMakeRange(0, 0) duration:duration completion:^(BOOL finished){
        if (completion) completion(finished);
    }];
}

- (nullable __kindof UIViewController *)popViewControllerWithDuration:(NSTimeInterval)duration completion:(void(^_Nullable)(BOOL finished))completion{
    if (self.viewControllers.count<2){
        if (completion) completion(NO);
        return nil;
    }
    return [self _popToIndex:self.viewControllers.count-2 duration:duration completion:^(BOOL finished){
        if (completion) completion(finished);
    }].lastObject;
}

- (nullable NSArray<__kindof UIViewController *> *)popToRootViewControllerWithDuration:(NSTimeInterval)duration completion:(void(^_Nullable)(BOOL finished))completion{
    if (self.viewControllers.count<2){
        if (completion) completion(NO);
        return nil;
    }
    return [self _popToIndex:0 duration:duration completion:^(BOOL finished){
        if (completion) completion(finished);
    }];
}

- (nullable NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController duration:(NSTimeInterval)duration completion:(void(^_Nullable)(BOOL finished))completion{
    if (!self.viewControllers){
        if (completion) completion(NO);
        return nil;
    }
    NSInteger index=[self.viewControllers indexOfObject:viewController];
    if (index==NSNotFound){
        if (completion) completion(NO);
        return nil;
    }
    if (index==self.viewControllers.count-1){
        if (completion) completion(NO);
        return nil;
    }
    return [self _popToIndex:index duration:duration completion:^(BOOL finished){
        if (completion) completion(finished);
    }];
}

/// push view controllers to stack
/// @param viewControllers view controller to push
/// @param clearRange  range of view controllers to remove from stack when transition complete
/// @param duration duration in second
/// @param completion completion block
- (void)_pushViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers clearRange:(NSRange)clearRange duration:(NSTimeInterval)duration completion:(void(^_Nullable)(BOOL finished))completion{
    __weak typeof(self) weakSelf = self;
    NSArray<UINavigationController *> *oldNavigationControllers = ({
        [self.navigationControllers copy];
    });
    NSArray<UINavigationController *> *newNavigationControllers = ({
        NSMutableArray *v = [NSMutableArray arrayWithCapacity:oldNavigationControllers.count+viewControllers.count];
        [v addObjectsFromArray:oldNavigationControllers];
        [v addObjectsFromArray:({
            NSMutableArray *v=[NSMutableArray arrayWithCapacity:viewControllers.count];
            for (NSInteger i = 0, count = viewControllers.count; i<count; i++){
                BOOL backItemVisable = i+(NSInteger)(oldNavigationControllers.count)-(NSInteger)(clearRange.length)>0;
                [v addObject:[self createNavigationControllerForViewController:viewControllers[i] backItemVisable:backItemVisable]];
            }
            v;
        })];
        v;
    });
    if (NSEqualRanges(NSMakeRange(0, 0), clearRange)){
        self.navigationControllers = newNavigationControllers;
    }else{
        self.navigationControllers = ({
            NSMutableArray *v = [newNavigationControllers mutableCopy];
            [v removeObjectsInRange:clearRange];
            v;
        });
    }
    void(^block)(void) = ^{
        __strong typeof (weakSelf) self = weakSelf;
        dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
        dispatch_group_t group = dispatch_group_create();
        BOOL animated = duration>0;
        __block BOOL cancelled = NO;
        __block void (^completeBlock)(BOOL finished);
        inMain(^{
            __strong typeof (weakSelf) self = weakSelf;
            self.animationDuration = duration;
            NSMutableArray <void(^)(void)> *willCancelBlocks = [NSMutableArray arrayWithCapacity:3];
            NSMutableArray <void(^)(void)> *didCancelBlocks  = [NSMutableArray arrayWithCapacity:3];
            NSMutableArray <void(^)(void)> *didFinishBlocks  = [NSMutableArray arrayWithCapacity:3];
            NSMutableArray <void(^)(void)> *transitionBlocks = [NSMutableArray arrayWithCapacity:3];
            BOOL visableFlags[newNavigationControllers.count];
            {
                UIViewController *newStatusBarController = nil;
                UIViewController *newRotationController  = nil;
                for (NSInteger newCount = newNavigationControllers.count-1, i=newCount; i>=0; i--){
                    if (i==newCount) {
                        visableFlags[i]=YES;
                    }else{
                        if (i == clearRange.location-1){
                            NSInteger next = i+clearRange.length+1;
                            UIViewController *nextViewController = newNavigationControllers[next];
                            visableFlags[i]=visableFlags[next]?nextViewController.snc_transition.transparent:NO;
                        }else if(i>clearRange.location+clearRange.length || i<clearRange.location-1){
                            NSInteger next = i+1;
                            UIViewController *nextViewController = newNavigationControllers[next];
                            visableFlags[i]=visableFlags[next]?nextViewController.snc_transition.transparent:NO;
                        }else{
                            visableFlags[i] = NO;
                        }
                    }
                    if (!visableFlags[i]) continue;
                    UIViewController *viewController = [newNavigationControllers[i] topViewController];
                    if (!newStatusBarController){
                        if (!viewController.snc_transition.resignStatusBarController) newStatusBarController = viewController;
                    }
                    if (!newRotationController){
                        if (!viewController.snc_transition.resignRotationController) newRotationController = viewController;
                    }
                }
                __weak UIViewController *oldStatusBarController = self.statusBarController;
                __weak UIViewController *oldRotationController = self.rotationController;
                self.statusBarController = newStatusBarController;
                self.rotationController = newRotationController;
                [willCancelBlocks addObject:^{
                    __strong typeof(weakSelf) self=weakSelf;
                    //reverse controller
                    self.statusBarController = oldStatusBarController;
                    self.rotationController = oldRotationController;
                }];
            }
            __block void (^willCancelBlock)(void)=^{
                for (NSInteger i=willCancelBlocks.count-1;i>=0;i--){
                    willCancelBlocks[i]();
                }
            };
            __block void (^didCancelBlock)(void) = ^{
                __strong typeof(weakSelf) self=weakSelf;
                for (NSInteger i=0,count=didCancelBlocks.count;i<count;i++){
                    didCancelBlocks[i]();
                }
                //reverse navigation controllers
                self.navigationControllers = oldNavigationControllers;
                if (completion) completion(NO);
            };
            __block void(^didFinishBlock)(void) = ^{
                for (NSInteger i=didFinishBlocks.count-1;i>=0;i--){
                    didFinishBlocks[i]();
                }
                if (completion) completion(YES);
            };
            completeBlock = ^(BOOL finished){
                __strong typeof(weakSelf) self=weakSelf;
                if (finished && didFinishBlock) didFinishBlock();
                else if (didCancelBlock) didCancelBlock();
                didCancelBlock = nil;
                didFinishBlock = nil;
                self.interactionWillCancel = nil;
                self.interactionDidComplete = nil;
            };
            self.interactionWillCancel = ^{
                if (!cancelled) cancelled = YES;
                willCancelBlock();
            };
            self.interactionDidComplete = ^{
                if (cancelled) completeBlock(!cancelled);
            };
            BOOL appeared = self.view.superview?YES:NO;
            for (NSInteger i = 0, count = newNavigationControllers.count; i < count; i++){
                __weak UINavigationController *navigationController = newNavigationControllers[i];
                __weak SNCTransition *transition = navigationController.snc_transition;
                transition.containerNavigationController = self;
                transition.viewController                = navigationController;
                transition.fromViewController            = i>0?newNavigationControllers[i-1]:nil;
                transition.toViewController              = navigationController;
                if (visableFlags[i]) {
                    if (!navigationController.parentViewController){
                        if(appeared) [navigationController beginAppearanceTransition:YES animated:animated];
                        [self snc_addChildViewController:navigationController];
                        [self.view addSubview:navigationController.view];
                        [transition didMoveToSuperview];
                        [willCancelBlocks addObject:^{
                            if(appeared) [navigationController beginAppearanceTransition:NO animated:animated];
                        }];
                        [didCancelBlocks addObject:^{
                            __strong typeof(weakSelf) self=weakSelf;
                            [navigationController didMoveToParentViewController:self];
                            [navigationController willMoveToParentViewController:nil];
                            [navigationController.view removeFromSuperview];
                            [navigationController removeFromParentViewController];
                            if(appeared) [navigationController endAppearanceTransition];
                        }];
                        [didFinishBlocks addObject:^{
                            __strong typeof(weakSelf) self=weakSelf;
                            [navigationController didMoveToParentViewController:self];
                            if(appeared) [navigationController endAppearanceTransition];
                            navigationController.interactivePopGestureRecognizer.enabled = NO;
                        }];
                    }
                }else{
                    if (navigationController.parentViewController){
                        if(appeared) [navigationController beginAppearanceTransition:NO animated:animated];
                        [navigationController willMoveToParentViewController:nil];
                        [willCancelBlocks addObject:^{
                            if(appeared) [navigationController beginAppearanceTransition:YES animated:animated];
                        }];
                        [didCancelBlocks addObject:^{
                            __strong typeof(weakSelf) self=weakSelf;
                            if(appeared) [navigationController endAppearanceTransition];
                            [navigationController removeFromParentViewController];
                            [self snc_addChildViewController:navigationController];
                            [navigationController didMoveToParentViewController:self];
                        }];
                        [didFinishBlocks addObject:^{
                            if(appeared) [navigationController endAppearanceTransition];
                            [navigationController.view removeFromSuperview];
                            [navigationController removeFromParentViewController];
                        }];
                    }
                }
                if (i>=oldNavigationControllers.count){
                    transition.interactionCancelledBlock = ^BOOL{
                        return cancelled;
                    };
                    transition.completeBlock = ^(BOOL finished) {
                        dispatch_group_leave(group);
                        transition.completeBlock = nil;
                    };
                    [didCancelBlocks addObject:^{
                        [transition complete:NO];
                    }];
                    [didFinishBlocks addObject:^{
                        [transition complete:YES];
                    }];
                    [transitionBlocks addObject:^{
                        dispatch_group_enter(group);
                        [transition startTransition:duration];
                    }];
                }
            }
            [transitionBlocks enumerateObjectsUsingBlock:^(void (^obj)(void), NSUInteger idx, BOOL * stop) {
                obj();
            }];
        });
        if (animated){
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                completeBlock(!cancelled);
                __strong typeof (weakSelf) self = weakSelf;
                dispatch_semaphore_signal(self.lock);
            });
            return;
        }
        inMain(^{
            completeBlock(YES);
            __strong typeof (weakSelf) self = weakSelf;
            dispatch_semaphore_signal(self.lock);
        });
    };
    if (self.interacting||oldNavigationControllers.count==0){
        dispatch_sync(self.queue, block);
        return;
    }
    dispatch_async(self.queue, block);
}

- (nullable NSArray<UIViewController *> *)_popToIndex:(NSInteger)index duration:(NSTimeInterval)duration completion:(void(^_Nullable)(BOOL finished))completion{
    __weak typeof(self) weakSelf = self;
    NSArray<UINavigationController*> *oldNavigationControllers = ({
        [self.navigationControllers copy];
    });
    NSArray *popedNavigationControllers=({
        NSRange range = NSMakeRange(index+1, oldNavigationControllers.count-index-1);
        [oldNavigationControllers subarrayWithRange:range];
    });
    NSArray *expectedNavigationControllers = [oldNavigationControllers subarrayWithRange:NSMakeRange(0, index+1)];
    self.navigationControllers = expectedNavigationControllers;
    void(^block)(void) = ^{
        __strong typeof (weakSelf) self = weakSelf;
        dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
        dispatch_group_t group = dispatch_group_create();
        BOOL animated = duration > 0;
        __block BOOL cancelled = NO;
        __block void (^completeBlock)(BOOL finished);
        inMain(^{
            __strong typeof (weakSelf) self = weakSelf;
            self.animationDuration = duration;
            NSMutableArray <void(^)(void)> *willCancelBlocks = [NSMutableArray arrayWithCapacity:3];
            NSMutableArray <void(^)(void)> *didCancelBlocks  = [NSMutableArray arrayWithCapacity:3];
            NSMutableArray <void(^)(void)> *didFinishBlocks  = [NSMutableArray arrayWithCapacity:3];
            NSMutableArray <void(^)(void)> *transitionBlocks = [NSMutableArray arrayWithCapacity:3];
            BOOL visableFlags[oldNavigationControllers.count];
            {
                UIViewController *newStatusBarController = nil;
                UIViewController *newRotationController  = nil;
                
                for (NSInteger i=oldNavigationControllers.count-1;i>=0;i--){
                    visableFlags[i]=NO;
                    if (i==index) visableFlags[i]=YES;
                    else if (i>index) visableFlags[i]=NO;
                    else{
                        UIViewController *nextViewController = expectedNavigationControllers[i+1];
                        visableFlags[i]=visableFlags[i+1]?nextViewController.snc_transition.transparent:NO;
                    }
                    if (!visableFlags[i]) continue;
                    UIViewController *viewController = [oldNavigationControllers[i] topViewController];
                    if (!newStatusBarController){
                        if (!viewController.snc_transition.resignStatusBarController) newStatusBarController = viewController;
                    }
                    if (!newRotationController){
                        if (!viewController.snc_transition.resignRotationController) newRotationController = viewController;
                    }
                }
                {
                    __weak UIViewController *oldStatusBarController = self.statusBarController;
                    __weak UIViewController *oldRotationController  = self.rotationController;
                    self.statusBarController                        = newStatusBarController;
                    self.rotationController                         = newRotationController;
                    [willCancelBlocks addObject:^{
                        __strong typeof(weakSelf) self=weakSelf;
                        self.statusBarController = oldStatusBarController;
                        self.rotationController  = oldRotationController;
                    }];
                }
            }
            __block void(^willCancelBlock)(void)=^{
                for (NSInteger i = willCancelBlocks.count-1; i>=0; i--){
                    willCancelBlocks[i]();
                }
            };
            __block void(^didCancelBlock)(void)=^{
                __strong typeof(weakSelf) self = weakSelf;
                self.navigationControllers = oldNavigationControllers;
                for (NSInteger i = 0,count = didCancelBlocks.count;i<count;i++){
                    didCancelBlocks[i]();
                }
                if (completion) completion(NO);
            };
            __block void(^didFinishBlock)(void) = ^{
                for (NSInteger i = didFinishBlocks.count-1; i>=0; i--){
                    didFinishBlocks[i]();
                }
                if (completion) completion(YES);
            };
            completeBlock = ^(BOOL finished){
                __strong typeof(weakSelf) self=weakSelf;
                if (finished && didFinishBlock) didFinishBlock();
                else if (didCancelBlock) didCancelBlock();
                didCancelBlock = nil;
                didFinishBlock = nil;
                self.interactionWillCancel = nil;
                self.interactionDidComplete = nil;
            };
            self.interactionWillCancel = ^{
                if (!cancelled) cancelled = YES;
                willCancelBlock();
            };
            self.interactionDidComplete = ^{
                if (cancelled) completeBlock(!cancelled);
            };
            BOOL appeared = self.view.superview?YES:NO;
            for (NSInteger i=oldNavigationControllers.count-1;i>=0;i--){
                __weak UINavigationController *navigationController = oldNavigationControllers[i];
                __weak SNCTransition *transition                    = navigationController.snc_transition;
                transition.containerNavigationController            = self;
                transition.viewController                           = navigationController;
                transition.fromViewController                       = navigationController;
                transition.toViewController                         = i>0?oldNavigationControllers[i-1]:nil;
                if (visableFlags[i]) {
                    if (!navigationController.parentViewController){
                        [self snc_addChildViewController:navigationController];
                        if(appeared) [navigationController beginAppearanceTransition:YES animated:animated];
                        [self.view insertSubview:navigationController.view atIndex:0];
                        navigationController.view.frame = self.view.bounds;
                        navigationController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                        navigationController.view.translatesAutoresizingMaskIntoConstraints = YES;
                        [transition didMoveToSuperview];
                        [willCancelBlocks addObject:^{
                            if(appeared) [navigationController beginAppearanceTransition:NO animated:animated];
                        }];
                        [didCancelBlocks addObject:^{
                            __strong typeof(weakSelf) self=weakSelf;
                            [navigationController didMoveToParentViewController:self];
                            [navigationController willMoveToParentViewController:nil];
                            [navigationController.view removeFromSuperview];
                            [navigationController removeFromParentViewController];
                            if(appeared) [navigationController endAppearanceTransition];
                        }];
                        [didFinishBlocks addObject:^{
                            __strong typeof(weakSelf) self=weakSelf;
                            [navigationController didMoveToParentViewController:self];
                            if(appeared) [navigationController endAppearanceTransition];
                            navigationController.interactivePopGestureRecognizer.enabled = NO;
                        }];
                    }
                }else{
                    if (navigationController.parentViewController){
                        [navigationController beginAppearanceTransition:NO animated:animated];
                        [navigationController willMoveToParentViewController:nil];
                        [willCancelBlocks addObject:^{
                            if(appeared) [navigationController beginAppearanceTransition:YES animated:animated];
                        }];
                        [didCancelBlocks addObject:^{
                            __strong typeof(weakSelf) self=weakSelf;
                            [navigationController removeFromParentViewController];
                            [self snc_addChildViewController:navigationController];
                            [navigationController didMoveToParentViewController:self];
                            if(appeared) [navigationController endAppearanceTransition];
                        }];
                        [didFinishBlocks addObject:^{
                            [navigationController.view removeFromSuperview];
                            [navigationController removeFromParentViewController];
                            if(appeared) [navigationController endAppearanceTransition];
                        }];
                    }
                }
                if (i>index){
                    transition.interactionCancelledBlock = ^BOOL{
                        return cancelled;
                    };
                    transition.completeBlock = ^(BOOL finished) {
                        dispatch_group_leave(group);
                        transition.completeBlock = nil;
                    };
                    [didCancelBlocks addObject:^{
                        [transition complete:NO];
                    }];
                    [didFinishBlocks addObject:^{
                        [transition complete:YES];
                    }];
                    [transitionBlocks addObject:^{
                        dispatch_group_enter(group);
                        [transition startTransition:duration];
                    }];
                }
            }
            [transitionBlocks enumerateObjectsUsingBlock:^(void (^obj)(void), NSUInteger idx, BOOL * stop) {
                obj();
            }];
        });
        if (animated){
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                completeBlock(!cancelled);
                __strong typeof (weakSelf) self = weakSelf;
                dispatch_semaphore_signal(self.lock);
            });
            return;
        }
        inMain(^{
            completeBlock(YES);
            __strong typeof (weakSelf) self = weakSelf;
            dispatch_semaphore_signal(self.lock);
        });
    };
    if (self.interacting){
        dispatch_sync(self.queue, block);
    }else{
        dispatch_async(self.queue, block);
    }
    return ({
        NSMutableArray *v = [NSMutableArray array];
        [popedNavigationControllers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [v addObject:[obj topViewController]];
        }];
        v;
    });
}

- (void)startInteraction{
    CALayer *layer = self.view.layer;
    layer.speed = 0.0;
    self.animationPausedTimeOffset = layer.timeOffset;
}

- (void)updateInteraction:(CGFloat)progress{
    progress=fmax(fmin(progress, 1), 0);
    CALayer *layer = self.view.layer;
    layer.timeOffset = self.animationPausedTimeOffset + self.animationDuration * progress;
}

- (void)finishInteraction:(CGFloat)speed{
    if (self.displayLink) return;
    self.animationCompletionSpeed=speed;
    self.displayLink=[CADisplayLink displayLinkWithTarget:self selector:@selector(finishingRender)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)cancelInteraction:(CGFloat)speed{
    if (self.displayLink) return;
    self.animationCompletionSpeed=speed;
    self.displayLink=[CADisplayLink displayLinkWithTarget:self selector:@selector(cancellingRender)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    if (self.interactionWillCancel){
        self.interactionWillCancel();
    }
}

- (void)recoverLayer{
    if (!self.displayLink) return;
    [self.displayLink invalidate];
    self.displayLink=nil;
    CALayer *layer = self.view.layer;
    layer.timeOffset = self.animationPausedTimeOffset;
    layer.speed = 1.0;
    if (self.interactionDidComplete){
        self.interactionDidComplete();
    }
}

- (void)finishingRender{
    CALayer *layer = self.view.layer;
    NSTimeInterval duration  = self.displayLink.duration;
    NSTimeInterval timeOffset = layer.timeOffset+duration*self.animationCompletionSpeed;
    NSTimeInterval targetTimeOffset = self.animationPausedTimeOffset+self.animationDuration;
    if (timeOffset < targetTimeOffset){
        layer.timeOffset=timeOffset;
        return;
    }
    layer.timeOffset=targetTimeOffset;
    [self recoverLayer];
}

- (void)cancellingRender{
    CALayer *layer = self.view.layer;
    NSTimeInterval duration = self.displayLink.duration;
    NSTimeInterval timeOffset = layer.timeOffset-duration*self.animationCompletionSpeed;
    if (timeOffset > self.animationPausedTimeOffset){
        layer.timeOffset=timeOffset;
        return;
    }
    layer.timeOffset=self.animationPausedTimeOffset;
    [self recoverLayer];
}


#pragma mark --
#pragma mark -- create new navigationController from navigationController class

- (__kindof UINavigationController*)createNavigationControllerForViewController:(UIViewController*)viewController backItemVisable:(BOOL)backItemVisable{
    UINavigationController *navigationController = [[self.navigationControllerClass alloc]init];
    [navigationController snc_original_setViewControllers:backItemVisable?@[[[UIViewController alloc]init],viewController]:@[viewController] animated:NO];
    navigationController.snc_navigationController=self;
    return navigationController;
}

#pragma mark --
#pragma mark -- getter

- (Class)navigationControllerClass{
    if (_navigationControllerClass) return _navigationControllerClass;
    return UINavigationController.class;
}

- (NSArray<UIViewController*>*)viewControllers{
    NSMutableArray *v = [NSMutableArray array];
    [self.navigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [v addObject:obj.topViewController];
    }];
    return v;
}

- (dispatch_queue_t)queue{
    if (_queue) return _queue;
    _queue = dispatch_queue_create("com.neutronstarer.stackernavigationcontroller", DISPATCH_QUEUE_SERIAL);
    return _queue;
}


- (dispatch_semaphore_t)lock{
    if (_lock) return _lock;
    _lock = dispatch_semaphore_create(1);
    return _lock;
}

- (UIGestureRecognizer*)interactivePopGestureRecognizer{
    if (_interactivePopGestureRecognizer) return _interactivePopGestureRecognizer;
    _interactivePopGestureRecognizer = ({
        UIScreenEdgePanGestureRecognizer *v = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        v.edges = UIRectEdgeLeft;
        v;
    });
    return _interactivePopGestureRecognizer;
}

- (void)pan:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer{
    UIView *view = gestureRecognizer.view;
    UIView *superview=view.superview;
    CGPoint point=[gestureRecognizer locationInView:superview];
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            if (self.navigationControllers.count<2 || self.topViewController.snc_transition.interactivePopGestureRecognizerDisabled|| self.interacting){
                break;
            }
            self.interacting = YES;
            if (![self popViewControllerAnimated:YES]){
                self.interacting = NO;
                break;
            }
            self.gestureRecognizerStartPoint = point;
            [self startInteraction];
            break;
        case UIGestureRecognizerStateChanged:
            if (!self.interacting)break;
            [self updateInteraction:(point.x-self.gestureRecognizerStartPoint.x)/CGRectGetWidth(view.bounds)];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:{
            if (!self.interacting) break;
            CGPoint velocity=[(UIPanGestureRecognizer*)gestureRecognizer velocityInView:superview];
            CGFloat width = CGRectGetWidth(view.bounds);
            if (velocity.x>1000){
                [self finishInteraction:velocity.x/width/3.0];
            }else if (point.x-self.gestureRecognizerStartPoint.x>width/4.0){
                [self finishInteraction:1];
            } else {
                [self cancelInteraction:point.x/width];
            }
            self.interacting = NO;
        }break;
        default: break;
    }
}
#pragma mark --
#pragma mark -- override


- (BOOL)shouldAutomaticallyForwardAppearanceMethods{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSMutableArray *array = [NSMutableArray array];
    for (UIViewController *viewController in self.navigationControllers){
        if (viewController.view.superview != self.view) return;
        [array addObject:viewController];
        [viewController beginAppearanceTransition:YES animated:animated];
    }
    self.viewWillAppearAppearances = array;
}

- (void)viewDidAppear:(BOOL)animated{
    for (UIViewController *viewController in self.viewWillAppearAppearances){
        [viewController endAppearanceTransition];
    }
    self.viewWillAppearAppearances = nil;
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSMutableArray *array = [NSMutableArray array];
    for (UIViewController *viewController in self.navigationControllers){
        if (viewController.view.superview != self.view) return;
        [array addObject:viewController];
        [viewController beginAppearanceTransition:NO animated:animated];
    }
    self.viewWillDisappearAppearances = array;
}

- (void)viewDidDisappear:(BOOL)animated{
    for (UIViewController *viewController in self.viewWillDisappearAppearances){
        [viewController endAppearanceTransition];
    }
    self.viewWillDisappearAppearances = nil;
    [super viewDidDisappear:animated];
}


- (void)snc_addChildViewController:(UIViewController *)childController{
    NSAssert(0, @"Do not call this method directly");
    return;
}

- (void)setStatusBarController:(UIViewController *)statusBarController{
    if (_statusBarController!=statusBarController) {
        _statusBarController=statusBarController;
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setRotationController:(UIViewController *)rotationController{
    if (_rotationController != rotationController){
        _rotationController = rotationController;
    }
    [UIViewController attemptRotationToDeviceOrientation];
}

- (BOOL)shouldAutorotate{
    if (!self.rotationController) return [super shouldAutorotate];
    return [self.rotationController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if (!self.rotationController) return [super supportedInterfaceOrientations];
    return [self.rotationController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    if (!self.rotationController) return [super preferredInterfaceOrientationForPresentation];
    return [self.rotationController preferredInterfaceOrientationForPresentation];
}

- (BOOL)prefersStatusBarHidden{
    if (!self.statusBarController) return [super prefersStatusBarHidden];
    return [self.statusBarController prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    if (!self.statusBarController) return [super preferredStatusBarStyle];
    return [self.statusBarController preferredStatusBarStyle];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    if (!self.statusBarController) return [super preferredStatusBarUpdateAnimation];
    return [self.statusBarController preferredStatusBarUpdateAnimation];
}

- (UIViewController*)topViewController{
    return self.viewControllers.lastObject;
}

+ (void)load{
    [self snc_swizzleOrignalMethod:@selector(addChildViewController:) alteredMethod:@selector(snc_addChildViewController:)];
}

@end
