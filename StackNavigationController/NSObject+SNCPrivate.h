//
//  NSObject+SNCPrivate.h
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SNCPrivate)

+ (BOOL)snc_swizzleOrignalMethod:(SEL)orignalMethod alteredMethod:(SEL)altertedMethod;

@end

NS_ASSUME_NONNULL_END
