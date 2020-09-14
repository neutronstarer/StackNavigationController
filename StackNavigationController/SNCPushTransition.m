//
//  SNCPushTransition.m
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import "SNCPushTransition.h"
#import "UIView+SNCPublic.h"

@interface SNCPushTransition()

@end

@implementation SNCPushTransition

- (instancetype)init{
    self = [super init];
    self.animationOptions = UIViewAnimationOptionCurveLinear;
    return self;
}

- (void)willPush{
    [self.toView snc_addTransparentBackground].alpha = 0;
    self.toView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, CGRectGetWidth(self.toView.bounds), 0, 0);
}

- (void)pushing{
    [self.toView snc_addTransparentBackground].alpha = 2/3.0;
    self.fromView.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.985, 0.985, 1);
    self.toView.layer.transform = CATransform3DIdentity;
}

- (void)didPush{
    if (!self.transparent) [self.toView snc_removeTransparentBackground];
}

- (void)didCancelPush{
    [self.toView snc_removeTransparentBackground];
    self.fromView.layer.transform = CATransform3DIdentity;
    self.toView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, CGRectGetWidth(self.toView.bounds), 0, 0);
}

- (void)willPop{
    [self.fromView snc_addTransparentBackground].alpha = 2/3.0;
    self.fromView.layer.transform = CATransform3DIdentity;
    self.toView.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.985, 0.985, 1);
}

- (void)poping{
    [self.fromView snc_addTransparentBackground].alpha = 0;
    self.fromView.layer.transform =  CATransform3DTranslate(CATransform3DIdentity, CGRectGetWidth(self.fromView.bounds), 0, 0);
    self.toView.layer.transform = CATransform3DIdentity;
}

- (void)didPop{
    [self.fromView snc_removeTransparentBackground];
}

- (void)didCancelPop{
    if (self.transparent) [self.fromView snc_addTransparentBackground].alpha = 2/3.0;
    else [self.fromView snc_removeTransparentBackground];
    self.fromView.layer.transform = CATransform3DIdentity;
    self.toView.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.985, 0.985, 1);
}

@end
