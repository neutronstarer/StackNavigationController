//
//  SNCCurtainTransition.m
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import "SNCCurtainTransition.h"

@implementation SNCCurtainTransition

- (instancetype)init{
    self = [super init];
    self.animationOptions = UIViewAnimationOptionCurveLinear;
    self.expectedTransitionDuration = 0.35;
    return self;
}

- (NSInteger)fromIndex{
    return [[self.containerView subviews] indexOfObject:self.fromView];
}

- (NSInteger)toIndex{
    return [[self.containerView subviews] indexOfObject:self.toView];
}

- (void)willPush{
    [self.fromView snc_addTransparentBackground].alpha = 2/3.0;
    self.fromView.layer.transform = CATransform3DIdentity;
    self.toView.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.985, 0.985, 1);
    NSInteger fromIndex = [self fromIndex];
    NSInteger toIndex = [self toIndex];
    if (fromIndex != NSNotFound && toIndex != NSNotFound) {
        [self.containerView exchangeSubviewAtIndex:fromIndex withSubviewAtIndex:toIndex];
    }
}

- (void)pushing{
    [self.fromView snc_addTransparentBackground].alpha = 0;
    self.fromView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, CGRectGetHeight(self.containerView.bounds), 0);
    self.toView.layer.transform = CATransform3DIdentity;
}

- (void)didPush{
    if (!self.transparent) [self.fromView snc_removeTransparentBackground];
    NSInteger fromIndex = [self fromIndex];
    NSInteger toIndex = [self toIndex];
    if (fromIndex != NSNotFound && toIndex != NSNotFound) {
        [self.containerView exchangeSubviewAtIndex:fromIndex withSubviewAtIndex:toIndex];
    }
}

- (void)didCancelPush{
    [self.fromView snc_removeTransparentBackground];
    self.fromView.layer.transform = CATransform3DIdentity;
    self.toView.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.985, 0.985, 1);
    NSInteger fromIndex = [self fromIndex];
    NSInteger toIndex = [self toIndex];
    if (fromIndex != NSNotFound && toIndex != NSNotFound) {
        [self.containerView exchangeSubviewAtIndex:fromIndex withSubviewAtIndex:toIndex];
    }
}

- (void)willPop{
    [self.toView snc_addTransparentBackground].alpha = 0;
    self.toView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, CGRectGetHeight(self.containerView.bounds), 0);
    self.fromView.layer.transform = CATransform3DIdentity;
    NSInteger fromIndex = [self fromIndex];
    NSInteger toIndex = [self toIndex];
    if (fromIndex != NSNotFound && toIndex != NSNotFound) {
        [self.containerView exchangeSubviewAtIndex:fromIndex withSubviewAtIndex:toIndex];
    }
}

- (void)poping{
    [self.toView snc_addTransparentBackground].alpha = 2/3.0;
    self.toView.layer.transform = CATransform3DIdentity;
    self.fromView.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.985, 0.985, 1);
}

- (void)didPop{
    [self.toView snc_removeTransparentBackground];
}

- (void)didCancelPop{
    if (self.transparent) [self.toView snc_addTransparentBackground].alpha = 0;
    else [self.view snc_removeTransparentBackground];
    self.toView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, CGRectGetHeight(self.containerView.bounds), 0);
    self.fromView.layer.transform = CATransform3DIdentity;
    NSInteger fromIndex = [self fromIndex];
    NSInteger toIndex = [self toIndex];
    if (fromIndex != NSNotFound && toIndex != NSNotFound) {
        [self.containerView exchangeSubviewAtIndex:fromIndex withSubviewAtIndex:toIndex];
    }
}

@end
