//
//  UIViewController+SNCPrivate.h
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StackNavigationController;
@class SNCTransition;

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (SNCPrivate)

@property (nonatomic, weak, nullable) StackNavigationController *snc_navigationController;
@property (nonatomic, strong        ) SNCTransition             *snc_transition;

@end

NS_ASSUME_NONNULL_END
