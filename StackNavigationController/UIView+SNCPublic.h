//
//  UIView+SNCPublic.h
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (SNCPublic)

/// Add a view above self as background
- (UIView*)snc_addTransparentBackground;

/// Remove transparent view
- (void)snc_removeTransparentBackground;

@end

NS_ASSUME_NONNULL_END
