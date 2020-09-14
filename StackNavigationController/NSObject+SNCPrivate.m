//
//  NSObject+SNCPrivate.m
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import <objc/runtime.h>

#import "NSObject+SNCPrivate.h"

@implementation NSObject (SNCPrivate)

+ (BOOL)snc_swizzleOrignalMethod:(SEL)orignalMethod alteredMethod:(SEL)altertedMethod{
    Method origMethod = class_getInstanceMethod(self, orignalMethod);
    Method altMethod  = class_getInstanceMethod(self, altertedMethod);
    if (!orignalMethod) return NO;
    if (!altertedMethod) return NO;
    class_addMethod(self, orignalMethod, class_getMethodImplementation(self, orignalMethod), method_getTypeEncoding(origMethod));
    class_addMethod(self, altertedMethod, class_getMethodImplementation(self, altertedMethod), method_getTypeEncoding(altMethod));
    method_exchangeImplementations(class_getInstanceMethod(self, orignalMethod), class_getInstanceMethod(self, altertedMethod));
    return YES;
}

@end
