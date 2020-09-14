//
//  StackNavigationController.h
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import <StackNavigationController/SNCFadeTransition.h>
#import <StackNavigationController/SNCAlertTransition.h>
#import <StackNavigationController/SNCActionSheetTransition.h>
#import <StackNavigationController/SNCPresentTransition.h>
#import <StackNavigationController/SNCPushTransition.h>
#import <StackNavigationController/SNCConvenientTransition.h>
#import <StackNavigationController/SNCCurtainTransition.h>
#import <StackNavigationController/SNCTransition.h>
#import <StackNavigationController/UINavigationController+SNCPublic.h>
#import <StackNavigationController/UIView+SNCPublic.h>
#import <StackNavigationController/UIViewController+SNCPublic.h>
#import <UIKit/UIKit.h>

//! Project version number for StackNavigationController.
FOUNDATION_EXPORT double StackNavigationControllerVersionNumber;

//! Project version string for StackNavigationController.
FOUNDATION_EXPORT const unsigned char StackNavigationControllerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <StackNavigationController/PublicHeader.h>


NS_ASSUME_NONNULL_BEGIN

@interface StackNavigationController : UIViewController

@property (nonatomic, nullable, readonly) UIViewController *topViewController;

@property (nonatomic, nullable, readonly) NSArray<UIViewController *> *viewControllers;

- (instancetype)initWithNavigationControllerClass:(nullable Class)navigationControllerClass NS_SWIFT_NAME(init(navigationControllerClass:));

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController NS_SWIFT_NAME(init(rootViewController:));

- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers NS_SWIFT_NAME(init(viewControllers:));

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers NS_SWIFT_NAME(setViewController(_:));
- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated NS_SWIFT_NAME(setViewControllers(_:animated:));
- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated completion:(void(^_Nullable)(BOOL finished))completion NS_SWIFT_NAME(setViewControllers(_:animated:completion:));
- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers duration:(NSTimeInterval)duration completion:(void(^_Nullable)(BOOL finished))completion NS_SWIFT_NAME(setViewControllers(_:duration:completion:));


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated NS_SWIFT_NAME(pushViewController(_:animated:));
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^_Nullable)(BOOL finished))completion NS_SWIFT_NAME(pushViewController(_:animated:completion:));
- (void)pushViewController:(UIViewController *)viewController duration:(NSTimeInterval)duration completion:(void(^_Nullable)(BOOL finished))completion NS_SWIFT_NAME(pushViewController(_:duration:completion:));

- (void)pushReplaceViewController:(UIViewController *)viewController animated:(BOOL)animated NS_SWIFT_NAME(pushReplaceViewController(_:animated:));
- (void)pushReplaceViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^_Nullable)(BOOL finished))completion NS_SWIFT_NAME(pushReplaceViewController(_:animated:completion:));
- (void)pushReplaceViewController:(UIViewController *)viewController duration:(NSTimeInterval)duration completion:(void(^_Nullable)(BOOL finished))completion NS_SWIFT_NAME(pushReplaceViewController(_:duration:completion:));

- (void)pushViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated NS_SWIFT_NAME(pushViewControllers(_:animated:));
- (void)pushViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated completion:(void(^_Nullable)(BOOL finished))completion NS_SWIFT_NAME(pushViewControllers(_:animated:completion:));
- (void)pushViewControllers:(NSArray<UIViewController *> *)viewControllers duration:(NSTimeInterval)duration completion:(void(^_Nullable)(BOOL finished))completion NS_SWIFT_NAME(pushViewControllers(_:duration:completion:));

- (nullable UIViewController *)popViewControllerAnimated:(BOOL)animated NS_SWIFT_NAME(popViewController(animated:));
- (nullable UIViewController *)popViewControllerAnimated:(BOOL)animated completion:(void(^_Nullable)(BOOL finished))completion NS_SWIFT_NAME(popViewController(animated:completion:));
- (nullable UIViewController *)popViewControllerWithDuration:(NSTimeInterval)duration completion:(void(^_Nullable)(BOOL finished))completion NS_SWIFT_NAME(popViewController(duration:completion:));

- (nullable NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated NS_SWIFT_NAME(popToRootViewController(animated:));
- (nullable NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated completion:(void(^_Nullable)(BOOL finished))completion NS_SWIFT_NAME(popToRootViewController(animated:completion:));
- (nullable NSArray<UIViewController *> *)popToRootViewControllerWithDuration:(NSTimeInterval)duration completion:(void(^_Nullable)(BOOL finished))completion NS_SWIFT_NAME(popToRootViewController(duration:completion:));


- (nullable NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated NS_SWIFT_NAME(popToViewController(_:animated:));
- (nullable NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^_Nullable)(BOOL finished))completion NS_SWIFT_NAME(popToViewController(_:animated:completion:));
- (nullable NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController duration:(NSTimeInterval)duration completion:(void(^_Nullable)(BOOL finished))completion NS_SWIFT_NAME(popToViewController(_:duration:completion:));

@end

NS_ASSUME_NONNULL_END
