//
//  SNCActionSheetTransition.h
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import "SNCTransition.h"

NS_ASSUME_NONNULL_BEGIN

@interface SNCActionSheetTransition : SNCTransition

@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) BOOL   shouldPopWhenTouchTransparentBackground;

@end

NS_ASSUME_NONNULL_END
