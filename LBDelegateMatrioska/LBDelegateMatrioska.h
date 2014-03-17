//
//  LBDelegateMatrioska.h
//  LBDelegateMatrioska
//
//  Created by Luca Bernardi on 30/05/13.
//  Copyright (c) 2013 Luca Bernardi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (ReturnType)
- (BOOL)methodReturnTypeIsVoid;
@end


@interface LBDelegateMatrioska : NSProxy

@property (readonly, nonatomic, strong) NSArray *delegates;

- (instancetype)initWithDelegates:(NSArray *)delegates;

- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;

@end