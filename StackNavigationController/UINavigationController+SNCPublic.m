//
//  UINavigationController+SNCPublic.m
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import <objc/runtime.h>

#import "NSObject+SNCPrivate.h"
#import "StackNavigationController.h"
#import "UINavigationController+SNCPublic.h"
#import "UIViewController+SNCPublic.h"

@implementation UINavigationController (SNCPublic)

- (void)setSnc_pop:(void (^)(__kindof UINavigationController *))snc_pop{
    objc_setAssociatedObject(self, @selector(snc_pop), snc_pop, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)(__kindof UINavigationController *))snc_pop{
    return objc_getAssociatedObject(self, @selector(snc_pop));
}

- (BOOL)snc_original_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
    if (self.snc_pop){
        self.snc_pop(self);
        return NO;
    }
    if (!self.snc_navigationController){
        return [self snc_original_navigationBar:navigationBar shouldPopItem:item];
    }
    [self.snc_navigationController popViewControllerAnimated:YES];
    return NO;
}

- (NSArray*)snc_original_viewControllers{
    if (!self.snc_navigationController){
        return [self snc_original_viewControllers];
    }
    return [self.snc_navigationController viewControllers];
}

- (void)snc_original_setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers{
    [self setViewControllers:viewControllers animated:NO];
}

- (void)snc_original_setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated{
    if (!self.snc_navigationController){
         [self snc_original_setViewControllers:viewControllers animated:animated];
         return;
     }
     [self.snc_navigationController setViewControllers:viewControllers animated:animated completion:nil];
}

- (void)snc_original_pushViewController:(__kindof UIViewController *)viewController animated:(BOOL)animated{
    if (!self.snc_navigationController){
        [self snc_original_pushViewController:viewController animated:animated];
        return;
    }
    [self.snc_navigationController pushViewController:viewController animated:animated completion:nil];
}

- (nullable __kindof UIViewController *)snc_original_popViewControllerAnimated:(BOOL)animated{
    if (!self.snc_navigationController){
        return [self snc_original_popViewControllerAnimated:animated];
    }
    return [self.snc_navigationController popViewControllerAnimated:animated completion:nil];
}

- (nullable NSArray<__kindof UIViewController *> *)snc_original_popToRootViewControllerAnimated:(BOOL)animated{
    if (!self.snc_navigationController){
        return [self snc_original_popToRootViewControllerAnimated:animated];
    }
    return [self.snc_navigationController popToRootViewControllerAnimated:animated completion:nil];
}

- (nullable NSArray<__kindof UIViewController *> *)snc_original_popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (!self.snc_navigationController){
        return [self snc_original_popToViewController:viewController animated:animated];
    }
    return [self.snc_navigationController popToViewController:viewController animated:animated completion:nil];
}

- (BOOL)snc_original_prefersStatusBarHidden{
    if (!self.snc_navigationController){
        return [self snc_original_prefersStatusBarHidden];
    }
    if (!self.topViewController){
        return [self snc_original_prefersStatusBarHidden];
    }
    return [self.topViewController prefersStatusBarHidden];
}

- (UIStatusBarStyle)snc_original_preferredStatusBarStyle{
    if (!self.snc_navigationController){
        return [self snc_original_preferredStatusBarStyle];
    }
    if (!self.topViewController){
        return [self snc_original_preferredStatusBarStyle];
    }
    return [self.topViewController preferredStatusBarStyle];
}

- (UIStatusBarAnimation)snc_original_preferredStatusBarUpdateAnimation{
    if (!self.snc_navigationController){
        return [self snc_original_preferredStatusBarUpdateAnimation];
    }
    if (!self.topViewController){
        return [self snc_original_preferredStatusBarUpdateAnimation];
    }
    return [self.topViewController preferredStatusBarUpdateAnimation];
}

- (BOOL)snc_original_shouldAutorotate{
    if (!self.snc_navigationController){
        return [self snc_original_shouldAutorotate];
    }
    if (!self.topViewController){
        return [self snc_original_shouldAutorotate];
    }
    return [self.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)snc_original_supportedInterfaceOrientations{
    if (!self.snc_navigationController){
        return [self snc_original_supportedInterfaceOrientations];
    }
    if (!self.topViewController){
        return [self snc_original_supportedInterfaceOrientations];
    }
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)snc_original_preferredInterfaceOrientationForPresentation{
    if (!self.snc_navigationController){
        return [self snc_original_preferredInterfaceOrientationForPresentation];
    }
    if (!self.topViewController){
        return [self snc_original_preferredInterfaceOrientationForPresentation];
    }
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

+ (void)load{
    [self snc_swizzleOrignalMethod:@selector(viewControllers) alteredMethod:@selector(snc_original_viewControllers)];
    [self snc_swizzleOrignalMethod:@selector(navigationBar:shouldPopItem:) alteredMethod:@selector(snc_original_navigationBar:shouldPopItem:)];
    [self snc_swizzleOrignalMethod:@selector(setViewControllers:) alteredMethod:@selector(snc_original_setViewControllers:)];
    [self snc_swizzleOrignalMethod:@selector(setViewControllers:animated:) alteredMethod:@selector(snc_original_setViewControllers:animated:)];
    [self snc_swizzleOrignalMethod:@selector(pushViewController:animated:) alteredMethod:@selector(snc_original_pushViewController:animated:)];
    [self snc_swizzleOrignalMethod:@selector(popViewControllerAnimated:) alteredMethod:@selector(snc_original_popViewControllerAnimated:)];
    [self snc_swizzleOrignalMethod:@selector(popToRootViewControllerAnimated:) alteredMethod:@selector(snc_original_popToRootViewControllerAnimated:)];
    [self snc_swizzleOrignalMethod:@selector(popToViewController:animated:) alteredMethod:@selector(snc_original_popToViewController:animated:)];
    [self snc_swizzleOrignalMethod:@selector(prefersStatusBarHidden) alteredMethod:@selector(snc_original_prefersStatusBarHidden)];
    [self snc_swizzleOrignalMethod:@selector(preferredStatusBarStyle) alteredMethod:@selector(snc_original_preferredStatusBarStyle)];
    [self snc_swizzleOrignalMethod:@selector(preferredStatusBarUpdateAnimation) alteredMethod:@selector(snc_original_preferredStatusBarUpdateAnimation)];
    [self snc_swizzleOrignalMethod:@selector(shouldAutorotate) alteredMethod:@selector(snc_original_shouldAutorotate)];
    [self snc_swizzleOrignalMethod:@selector(supportedInterfaceOrientations) alteredMethod:@selector(snc_original_supportedInterfaceOrientations)];
    [self snc_swizzleOrignalMethod:@selector(preferredInterfaceOrientationForPresentation) alteredMethod:@selector(snc_original_preferredInterfaceOrientationForPresentation)];
}

@end
