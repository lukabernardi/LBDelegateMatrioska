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

- (NSArray *)delegates
{
    return [self.mutableDelegates allObjects];
}

#pragma mark - NSProxy

- (void)forwardInvocation:(NSInvocation *)invocation
{
    // If the invoked method return void I can safely call all the delegates
    // otherwise I just invoke it on the first delegate that
    // respond to the given selector
    if ([invocation methodReturnTypeIsVoid]) {
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:invocation.selector]) {
                [invocation invokeWithTarget:delegate];
            }
        }
    } else {
        id firstResponder = [self _firstResponderToSelector:invocation.selector];
        [invocation invokeWithTarget:firstResponder];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    id firstResponder = [self _firstResponderToSelector:sel];
    if (firstResponder) {
        return [firstResponder methodSignatureForSelector:sel];
    }
    return nil;
}

#pragma mark - NSObject

- (BOOL)respondsToSelector:(SEL)aSelector
{
    id firstResponder = [self _firstResponderToSelector:aSelector];
    return (firstResponder ? YES : NO);
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    id firstConformed = [self _firstConformedToProtocol:aProtocol];
    return (firstConformed ? YES : NO);
}

#pragma mark -

- (id)_firstResponderToSelector:(SEL)aSelector
{
    __block id firstResponder = nil;
    
    NSArray *delegates = [_mutableDelegates allObjects];

    [delegates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:aSelector]) {
            firstResponder = obj;
            *stop = YES;
        }
    }];
    
    return firstResponder;
}

- (id)_firstConformedToProtocol:(Protocol *)protocol
{
    __block id firstConformed = nil;
    [[self.mutableDelegates allObjects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj conformsToProtocol:protocol]) {
            firstConformed = obj;
            *stop = YES;
        }
    }];
    return firstConformed;
}

@end
