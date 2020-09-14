//
//  UIViewController+SNCPublic.m
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import <objc/runtime.h>

#import "NSObject+SNCPrivate.h"
#import "SNCPushTransition.h"
#import "StackNavigationController.h"
#import "UIViewController+SNCPrivate.h"
#import "UIViewController+SNCPublic.h"
#import "NSObject+SNCPrivate.h"

@implementation UIViewController (SNCPublic)

- (StackNavigationController *)snc_navigationController {
    if ([self isKindOfClass:UINavigationController.class]) {
        return [objc_getAssociatedObject(self, @selector(snc_navigationController)) anyObject];
    }
    return [self.navigationController snc_navigationController];
}

- (void)setSnc_navigationController:(StackNavigationController * _Nullable)snc_navigationController{
    objc_setAssociatedObject(self, @selector(snc_navigationController), snc_navigationController ? ({
        NSHashTable *v = [NSHashTable weakObjectsHashTable];
        [v addObject:snc_navigationController];
        v;
    }): nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setSnc_transition:(SNCTransition*)snc_transition{
    objc_setAssociatedObject(self, @selector(snc_transition), snc_transition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SNCTransition*)snc_transition{
    SNCTransition *transition = objc_getAssociatedObject(self, @selector(snc_transition));
    if (transition) return transition;
    if ([self isKindOfClass:UINavigationController.class]){
        transition=[(UINavigationController*)self topViewController].snc_transition;
        if (transition) return transition;
    }
    transition=[[SNCPushTransition alloc]init];
    self.snc_transition = transition;
    return transition;
}

- (void)snc_original_viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    //fix transiform bug while rotating
    if (self.snc_navigationController){
        CATransform3D transform = self.view.layer.transform;
        self.view.layer.transform = CATransform3DIdentity;
        // next runloop
        [self performSelector:@selector(snc_setViewLayerTransform:) withObject:@(transform) afterDelay:0];
    }
    [self snc_original_viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)snc_setViewLayerTransform:(NSValue*)value{
    self.view.layer.transform = value.CATransform3DValue;
}

+ (void)load{
    [self snc_swizzleOrignalMethod:@selector(viewWillTransitionToSize:withTransitionCoordinator:) alteredMethod:@selector(snc_original_viewWillTransitionToSize:withTransitionCoordinator:)];
}

@end
