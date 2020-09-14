//
//  UIView+SNCPublic.m
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import <objc/runtime.h>
#import "UIView+SNCPublic.h"
#import "NSObject+SNCPrivate.h"

@interface SNCTransparentView: UIView

@end

@implementation SNCTransparentView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.alpha = 0;
    self.backgroundColor = [UIColor blackColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.translatesAutoresizingMaskIntoConstraints = YES;
    return self;
}

@end

@implementation UIView (SNCPublic)

- (void)setSnc_transparentView:(SNCTransparentView *)snc_transparentView{
    objc_setAssociatedObject(self, @selector(snc_transparentView), ({
        NSHashTable *v = [NSHashTable weakObjectsHashTable];
        [v addObject:snc_transparentView];
        v;
    }), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SNCTransparentView *)snc_transparentView{
    return [objc_getAssociatedObject(self, @selector(snc_transparentView)) anyObject];
}

- (UIView*)snc_addTransparentBackground{
    SNCTransparentView *view = [self snc_transparentView];
    if (!view) {
        view = ({
            SNCTransparentView *v = [[SNCTransparentView alloc] init];
            v;
        });
        [self setSnc_transparentView:view];
    }
    if (!self.superview) return view;
    [self.superview insertSubview:view belowSubview:self];
    view.frame = self.superview.bounds;
    return view;
}

- (void)snc_removeTransparentBackground {
    SNCTransparentView *view = [self snc_transparentView];
    if (!view) return;
    [view removeFromSuperview];
    [self setSnc_transparentView:nil];
}

- (void)snc_original_didMoveToSuperview{
    UIView *view = [self snc_transparentView];
    if (!view) return;
    if (!self.superview) {
        [view removeFromSuperview];
        return;
    }
    [self.superview insertSubview:view belowSubview:self];
    view.frame = self.superview.bounds;
}

+ (void)load{
    [self snc_swizzleOrignalMethod:@selector(didMoveToSuperview) alteredMethod:@selector(snc_original_didMoveToSuperview)];
}

@end
