//
//  LBDelegateMatrioska.h
//  LBDelegateMatrioska
//
//  Created by Luca Bernardi on 30/05/13.
//  Copyright (c) 2013 Luca Bernardi. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_feature(objc_generics)
#define LB_GENERICS(placeholder) <placeholder>
#define LB_GENERICS_TYPE(placeholder) placeholder
#else
#define LB_GENERICS(placeholder)
#define LB_GENERICS_TYPE(placeholder) id
#endif

@interface NSInvocation (ReturnType)
- (BOOL)methodReturnTypeIsVoid;
@end


@interface LBDelegateMatrioska LB_GENERICS(T) : NSProxy

@property (nonatomic, readonly, copy) NSArray LB_GENERICS(T) *delegates;

- (instancetype)initWithDelegates:(NSArray LB_GENERICS(T) *)delegates;

- (void)addDelegate:(LB_GENERICS_TYPE(T))delegate;
- (void)removeDelegate:(LB_GENERICS_TYPE(T))delegate;

@end
