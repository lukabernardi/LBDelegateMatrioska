//
//  LBDelegateMatrioska.m
//  LBDelegateMatrioska
//
//  Created by Luca Bernardi on 30/05/13.
//  Copyright (c) 2013 Luca Bernardi. All rights reserved.
//

#import "LBDelegateMatrioska.h"

@implementation NSInvocation (ReturnType)

- (BOOL)methodReturnTypeIsVoid
{
    return (([self.methodSignature methodReturnLength] == 0) ? YES : NO);
}

@end


@interface LBDelegateMatrioska ()
@property (nonatomic, strong) NSPointerArray *mutableDelegates;
@end


@implementation LBDelegateMatrioska

- (instancetype)initWithDelegates:(NSArray *)delegates
{
    _mutableDelegates = [NSPointerArray weakObjectsPointerArray];
    [delegates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_mutableDelegates addPointer:(void *)obj];
    }];
    
    return self;
}


#pragma mark - Public interface

- (NSArray *)delegates
{
    return [self.mutableDelegates allObjects];
}


- (void)addDelegate:(id)aDelegate
{
    NSParameterAssert(aDelegate);
    [self.mutableDelegates addPointer:(void *)aDelegate];
}

- (void)removeDelegate:(id)aDelegate
{
    NSParameterAssert(aDelegate);
    
    NSUInteger index = 0;
    for (id delegate in self.mutableDelegates) {
        if (delegate == aDelegate) {
            [self.mutableDelegates removePointerAtIndex:index];
            break;
        }
        index++;
    }
}

#pragma mark - NSProxy

- (void)forwardInvocation:(NSInvocation *)invocation
{
    // If the invoked method return void I can safely call all the delegates
    // otherwise I just invoke it on the first delegate that
    // respond to the given selector
    if ([invocation methodReturnTypeIsVoid]) {
        for (id delegate in self.mutableDelegates) {
            if ([delegate respondsToSelector:invocation.selector]) {
                [invocation invokeWithTarget:delegate];
            }
        }
    } else {
        id firstResponder = [self p_firstResponderToSelector:invocation.selector];
        [invocation invokeWithTarget:firstResponder];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    id firstResponder = [self p_firstResponderToSelector:sel];
    if (firstResponder) {
        return [firstResponder methodSignatureForSelector:sel];
    }
    return nil;
}

#pragma mark - NSObject

- (BOOL)respondsToSelector:(SEL)aSelector
{
    id firstResponder = [self p_firstResponderToSelector:aSelector];
    return (firstResponder ? YES : NO);
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    id firstConformed = [self p_firstConformedToProtocol:aProtocol];
    return (firstConformed ? YES : NO);
}

#pragma mark - Private

- (id)p_firstResponderToSelector:(SEL)aSelector
{
    for (id delegate in self.mutableDelegates) {
        if ([delegate respondsToSelector:aSelector]) {
            return delegate;
        }
    }
    return nil;
}

- (id)p_firstConformedToProtocol:(Protocol *)protocol
{
    for (id delegate in self.mutableDelegates) {
        if ([delegate conformsToProtocol:protocol]) {
            return delegate;
        }
    }
    return nil;
}

@end
