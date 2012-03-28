//
//  Calculator.h
//  Calculator
//
//  Created by Yi Zhu on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Calculator : NSObject

@property (nonatomic, strong, readonly) id program;

- (void) addOperand:(double)number;
- (void) addOperator:(NSString *)operator;
- (void) addVariable:(NSString *)variable;
- (void) undo;

- (id) performOperation:(NSString *)operator;
- (void) reset;

+ (BOOL) isUnaryOperator:(NSString *)name;
+ (BOOL) isBinaryOperator:(NSString *)name;
+ (BOOL) isOperator:(NSString *)name;

+ (NSArray *) setOfVariablesInProgram:(id)program;

+ (id) evaluateProgram:(id)program withVariableValuation:(NSDictionary *)valuation;
+ (id) evaluateProgram:(id)program;

+ (NSString *) descriptionOfProgram:(id)program;

@end
