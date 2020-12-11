//
//  SNCTransition.h
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StackNavigationController;

NS_ASSUME_NONNULL_BEGIN

/// SNCTransition can be treat as union of transitionContext and transitioning a view controller has one
@interface SNCTransition : NSObject

#pragma --
#pragma -- controller property

/// Current view is transparent,  be careful to use transparent effect,  it will take a performance problem, default NO.
@property (nonatomic, assign                  ) BOOL                      transparent;

/// Stacker navigation controller search in view controllers from top to bottom and make visiable view controller which 's transtion do not  `resignStatusBarController`  as the status bar controller.
/// Default NO.
@property (nonatomic, assign                  ) BOOL                      resignStatusBarController;

/// Like resignStatusBarController
/// Default NO.
@property (nonatomic, assign                  ) BOOL                      resignRotationController;

/// Only active If current view controller is at the top
/// Is interactive disabled
/// Default NO.
@property (nonatomic, assign                  ) BOOL                      interactivePopGestureRecognizerDisabled;

/// Expected transtion duration, transition will take `expectedTransitionDuration` to animate if user not define
@property (nonatomic, assign                  ) NSTimeInterval            expectedTransitionDuration;

#pragma --
#pragma -- transition context

/// Animation duration
@property (nonatomic, assign, readonly        ) NSTimeInterval                     animationDuration;

/// Current associated view controller
/// Relationship is one-to-one,  a transition <---->a view controller
@property (nonatomic, weak, readonly          ) UINavigationController    *viewController;

/// Stack navigation controller
@property (nonatomic, weak, readonly          ) StackNavigationController *containerNavigationController;

/// If push, `fromViewController` may be prev view controller or nil;  If pop, `fromViewController` is  current `viewController`
@property (nonatomic, weak, readonly, nullable) UINavigationController    *fromViewController;

/// If push, `toViewController` is `viewController` of this transtion, If pop, `toViewController` is prev view controller
@property (nonatomic, weak, readonly          ) UINavigationController    *toViewController;

/// View of `containerNavigationController`
@property (nonatomic, readonly                ) UIView                    *containerView;

/// View of `viewController`
@property (nonatomic, readonly                ) UIView                    *view;

/// View of `fromViewController`
@property (nonatomic, readonly                ) UIView                    *fromView;

/// View of `toViewController`
@property (nonatomic, readonly                ) UIView                    *toView;

/// Interaction is cancelled
@property (nonatomic, readonly                ) BOOL                      interactionCancelled;

/// Current viewController's view did move to superview
- (void)didMoveToSuperview;

/// Start transtion. sub class should override this method and call super and call `complete:` when transition complete
- (void)startTransition:(NSTimeInterval)duration NS_SWIFT_NAME(startTransition(_:));

/// Must call this method when transition complete
/// @param finished is transition finished
/// @return success
- (BOOL)complete:(BOOL)finished  NS_SWIFT_NAME(complete(_:));

@end

NS_ASSUME_NONNULL_END
