//
//  SNCConvenientTransition.m
//  StackNavigationController
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

#import "SNCConvenientTransition.h"

@implementation SNCConvenientTransition

- (void)didMoveToSuperview{
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view.superview addConstraints:@[
        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view.superview attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view.superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view.superview attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view.superview attribute:NSLayoutAttributeTop multiplier:1 constant:0],
    ]];
    [super didMoveToSuperview];
}

- (void)startTransition:(NSTimeInterval)duration{
    BOOL push = self.viewController == self.toViewController;
    if (push) [self willPush];
    else [self willPop];
    [UIView animateWithDuration:duration delay:0 options:self.animationOptions animations:^{
        if (push) [self pushing];
        else [self poping];
    } completion:^(BOOL finished) {
        [self complete:!self.interactionCancelled && finished];
    }];
    [super startTransition:duration];
}

- (void)complete:(BOOL)finished{
    BOOL push = self.viewController == self.toViewController;
    if (finished){
        if (push) [self didPush];
        else [self didPop];
    }else{
        if (push) [self didCancelPush];
        else [self didCancelPop];
    }
    [super complete:finished];
}

- (void)willPush{
    
}

- (void)pushing{
    
}

- (void)didPush{
    
}

- (void)didCancelPush{
    
}

- (void)willPop{
    
}

- (void)poping{
    
}

- (void)didPop{
    
}

- (void)didCancelPop{
    
}

@end
