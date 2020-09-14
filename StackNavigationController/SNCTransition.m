//
//  SNCTransition.m
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import "SNCTransition.h"
#import "StackNavigationController.h"
#import "UIView+SNCPublic.h"

@interface SNCTransition()

@property (nonatomic, weak) StackNavigationController *containerNavigationController;
@property (nonatomic, weak) UINavigationController    *viewController;
@property (nonatomic, weak) UINavigationController    *fromViewController;
@property (nonatomic, weak) UINavigationController    *toViewController;

@property (nonatomic, copy) void(^completeBlock)(BOOL finished);
@property (nonatomic, copy) BOOL(^interactionCancelledBlock)(void);

@end

@implementation SNCTransition


- (instancetype)init{
    self = [super init];
    self.expectedTransitionDuration = UINavigationControllerHideShowBarDuration;
    return self;
}

- (void)didMoveToSuperview{
    // fix navigation display when view have add to superview
    if (@available(iOS 13.0, *)) {
        
    } else {
        self.viewController.navigationBarHidden = !self.viewController.navigationBarHidden;
        self.viewController.navigationBarHidden = !self.viewController.navigationBarHidden;
    }
}

- (BOOL)complete:(BOOL)finished{
    if (!self.completeBlock) return NO;

    // fix navigation display when pop interaction is cancelled
    BOOL push = self.viewController==self.toViewController;
    if (!push && !finished){
        if (@available(iOS 13.0, *)) {
            
        } else {
            self.viewController.navigationBarHidden = !self.viewController.navigationBarHidden;
            self.viewController.navigationBarHidden = !self.viewController.navigationBarHidden;
        }
    }
    self.completeBlock(finished);
    return YES;
}

- (void)startTransition:(NSTimeInterval)duration{
    // fix navigation display when poping to pre view controller
    BOOL push = self.viewController==self.toViewController;
    if (push) {
        return;
    }
    if (@available(iOS 13.0, *)) {
        
    } else {
        self.toViewController.navigationBarHidden = !self.toViewController.navigationBarHidden;
        self.toViewController.navigationBarHidden = !self.toViewController.navigationBarHidden;
    }
}

- (BOOL)interactionCancelled{
    if (self.interactionCancelledBlock) return self.interactionCancelledBlock();
    return NO;
}

- (UIView*)containerView{
    return self.containerNavigationController.view;
}

- (UIView*)view{
    return self.viewController.view;
}

- (UIView*)fromView{
    return self.fromViewController.view;
}

- (UIView*)toView{
    return self.toViewController.view;
}


@end
