//
//  SNCConvenientTransition.h
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import <StackNavigationController/SNCTransition.h>
#import <StackNavigationController/UIView+SNCPublic.h>

NS_ASSUME_NONNULL_BEGIN

@interface SNCConvenientTransition : SNCTransition

@property (nonatomic, assign) UIViewAnimationOptions animationOptions;

- (void)willPush;

- (void)pushing;

- (void)didPush;

- (void)didCancelPush;

- (void)willPop;

- (void)poping;

- (void)didPop;

- (void)didCancelPop;

@end

NS_ASSUME_NONNULL_END
