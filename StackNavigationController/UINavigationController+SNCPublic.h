//
//  UINavigationController+SNCPublic.h
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (SNCPublic)

/// did click back item in navigation bar
@property (nullable,nonatomic,copy) void(^snc_pop)(__kindof UINavigationController *navigationController);

@end

NS_ASSUME_NONNULL_END
