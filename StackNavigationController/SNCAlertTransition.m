//
//  SNCAlertTransition.m
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import "SNCAlertTransition.h"
#import "UIView+SNCPublic.h"

@interface SNCAlertTransition()

@property (nonatomic, assign) CGFloat       fromAlpha;
@property (nonatomic, assign) CATransform3D fromTransform;

@end

@implementation SNCAlertTransition

- (void)didMoveToSuperview{
    CGSize size = self.contentSize;
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view.superview addConstraints:@[
        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view.superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:size.width],
        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:size.height],
    ]];
    [super didMoveToSuperview];
}

- (void)startTransition:(NSTimeInterval)duration{
    self.viewController.navigationBarHidden = YES;
    BOOL push = self.viewController==self.toViewController;
    if (push){
        [self.view snc_addTransparentBackground].alpha = 0;
        self.fromAlpha                                 = 1;
        self.fromTransform                             = CATransform3DScale(CATransform3DIdentity, 0.5, 0.5, 1);
        self.view.layer.transform                      = self.fromTransform;
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.view.layer.transform = CATransform3DIdentity;
        } completion:^(BOOL finished) {
            [self complete:!self.interactionCancelled && finished];
        }];
        [UIView animateWithDuration:duration/2.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.view snc_addTransparentBackground].alpha = 0.5;
        } completion:nil];
        [super startTransition:duration];
        return;
    }
    [self.view snc_addTransparentBackground].alpha = 0.5;
    self.fromAlpha                                 = self.view.alpha;
    self.fromTransform                             = self.view.layer.transform;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view snc_addTransparentBackground].alpha = 0;
        self.view.alpha                                = 0;
    } completion:^(BOOL finished) {
        [self complete:!self.interactionCancelled && finished];
    }];
    [super startTransition:duration];
}

- (BOOL)complete:(BOOL)finished{
    if (![super complete:finished]){
        return NO;
    }
    if (!finished){
        self.view.alpha           = self.fromAlpha;
        self.view.layer.transform = self.fromTransform;
    }
    BOOL push = self.viewController==self.toViewController;
    if (push){
        if (!finished||!self.transparent){
            [self.view snc_removeTransparentBackground];
        }
    }else{
        if (finished||!self.transparent){
            [self.view snc_removeTransparentBackground];
        }else{
            [self.view snc_addTransparentBackground].alpha = 0.5;
        }
    }
    return YES;
}

- (BOOL)transparent{
    return YES;
}

- (BOOL)resignStatusBarController{
    return YES;
}

- (BOOL)resignRotationController{
    return YES;
}

- (BOOL)interactivePopGestureRecognizerDisabled{
    return YES;
}

@end
