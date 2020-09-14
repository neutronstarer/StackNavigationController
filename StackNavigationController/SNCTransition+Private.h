//
//  SNCTransition+Private.h
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import "SNCTransition.h"

@class StackNavigationController;

NS_ASSUME_NONNULL_BEGIN

@interface SNCTransition (Private)

@property (nonatomic, weak         ) StackNavigationController *containerNavigationController;
@property (nonatomic, weak         ) UINavigationController    *viewController;
@property (nonatomic, weak,nullable) UINavigationController    *fromViewController;
@property (nonatomic, weak         ) UINavigationController    *toViewController;

@property (nonatomic,copy, nullable) void(^completeBlock) (BOOL finished);
@property (nonatomic,copy, nullable) BOOL(^interactionCancelledBlock) (void);

@end

NS_ASSUME_NONNULL_END
