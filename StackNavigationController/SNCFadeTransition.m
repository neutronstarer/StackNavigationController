//
//  SNCFadeTransition.m
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import "SNCFadeTransition.h"
#import "UIView+SNCPublic.h"

@interface SNCFadeTransition ()

@end

@implementation SNCFadeTransition

- (instancetype)init{
    self = [super init];
    self.animationOptions = UIViewAnimationOptionCurveLinear;
    return self;
}

- (void)willPush{
    [self.toView snc_addTransparentBackground].alpha = 0;
    self.toView.alpha = 0;
}

- (void)pushing{
    [self.toView snc_addTransparentBackground].alpha = 0.5;
    self.toView.alpha = 1;
}

- (void)didPush{
    if (!self.transparent) [self.toView snc_removeTransparentBackground];
}

- (void)didCancelPush{
    [self.toView snc_removeTransparentBackground];
    self.toView.alpha = 0;
}

- (void)willPop{
    [self.fromView snc_addTransparentBackground].alpha = 0.5;
    self.fromView.alpha = 1;
}

- (void)poping{
    [self.fromView snc_addTransparentBackground].alpha = 0;
    self.fromView.alpha = 0;
}

- (void)didPop{
    [self.fromView snc_removeTransparentBackground];
}

- (void)didCancelPop{
    if (self.transparent) [self.fromView snc_addTransparentBackground].alpha = 0.5;
    else [self.fromView snc_removeTransparentBackground];
    self.fromView.alpha = 1;
}

@end
