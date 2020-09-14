//
//  SNCActionSheetTransition.m
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import "SNCActionSheetTransition.h"
#import "UIView+SNCPublic.h"
#import "StackNavigationController.h"

@interface SNCActionSheetTransition() <UIGestureRecognizerDelegate>

@property (nonatomic,assign) CATransform3D fromTransform;
@property (nonatomic,assign) CATransform3D toTransform;

@end

@implementation SNCActionSheetTransition

- (void)didMoveToSuperview{
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view.superview addConstraints:@[
        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view.superview attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:self.contentSize.width],
        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:self.contentSize.height],
    ]];
    [super didMoveToSuperview];
}

- (void)startTransition:(NSTimeInterval)duration{
    self.viewController.navigationBarHidden = YES;
    BOOL push = self.viewController==self.toViewController;
    if (push){
        UIView *transparentBackground = [self.view snc_addTransparentBackground];
        transparentBackground.alpha = 0;
        [transparentBackground addGestureRecognizer:({
            UITapGestureRecognizer *v = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
            v.delegate = self;
            v;
        })];
        self.fromTransform                             = self.fromView.layer.transform;
        self.toTransform                               = CATransform3DTranslate(CATransform3DIdentity, 0, CGRectGetHeight(self.view.bounds), 0);
        self.view.layer.transform                      = self.toTransform;
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.view.layer.transform                      = CATransform3DIdentity;
            self.fromView.layer.transform                  = CATransform3DScale(CATransform3DIdentity, 0.985, 0.985, 1);
            [self.view snc_addTransparentBackground].alpha = 0.5;
        } completion:^(BOOL finished) {
            [self complete:!self.interactionCancelled &&finished];
        }];
        [super startTransition:duration];
        return;
    }
    [self.view snc_addTransparentBackground].alpha = 0.5;
    self.fromTransform                             = self.view.layer.transform;
    self.toTransform                               = self.toView.layer.transform;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view snc_addTransparentBackground].alpha = 0;
        self.view.layer.transform                      = CATransform3DTranslate(CATransform3DIdentity, 0, CGRectGetHeight(self.view.bounds),0);
        self.toView.layer.transform                    = CATransform3DIdentity;
    } completion:^(BOOL finished) {
        [self complete:!self.interactionCancelled &&finished];
    }];
    [super startTransition:duration];
}

- (void)complete:(BOOL)finished{
    if (!finished){
        self.fromView.layer.transform = self.fromTransform;
        self.toView.layer.transform   = self.toTransform;
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
    [super complete:finished];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return self.shouldPopWhenTouchTransparentBackground;
}

- (void)tap{
    [self.containerNavigationController popViewControllerAnimated:YES];
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

- (BOOL)transparent{
    return YES;
}

@end
