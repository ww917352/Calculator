//
//  Calculator.m
//  Calculator
//
//  Created by Yi Zhu on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Calculator.h"

@interface Calculator ()

@property (nonatomic, strong) NSMutableArray *programTree;

@end

@implementation Calculator

@synthesize programTree = _programTree;

- (id)program {
    return [self.programTree copy];
}

- (NSMutableArray *)programTree {
    if (!_programTree) {
        _programTree = [[NSMutableArray alloc] init];
    }
    return _programTree;
}

+ (BOOL)isUnaryOperator:(NSString *)name {
    return ([name isEqualToString:@"sin"] || [name isEqualToString:@"cos"] || [name isEqualToString:@"sqrt"] || [name isEqualToString:@"log"]);
}

+ (BOOL)isBinaryOperator:(NSString *)name {
    return ([name isEqualToString:@"+"] || [name isEqualToString:@"-"] || [name isEqualToString:@"*"] || [name isEqualToString:@"/"]);
}

+ (BOOL)isOperator:(NSString *)name {
    return ([self isUnaryOperator:name] || [self isBinaryOperator:name]);
}

+ (BOOL)isOpenBranch:(NSArray *)branch {
    BOOL result = NO;
    
    if ([branch count] == 0) {
        result = YES;
    }
    else if ([branch count] == 2) {
        id operator = [branch objectAtIndex:0];
        if ([operator isKindOfClass:[NSString class]] && [self isBinaryOperator:operator]) {
            result = YES;
        }
    }
    return result;
}

+ (id)topElementOfBranch:(NSArray *)branch {
    id result = nil;
    if ([branch count] > 0) {
        result = [branch objectAtIndex:0];
    }
    return result;
}

- (void)addOperand:(double)number {
    NSMutableArray *lastBranch = [self.programTree lastObject];
    if (!lastBranch) {
        lastBranch = [[NSMutableArray alloc] init];
        [lastBranch addObject:[NSNumber numberWithDouble:number]];
        [self.programTree addObject:lastBranch];
    }
    else if ([lastBranch count] == 0)
        [lastBranch addObject:[NSNumber numberWithDouble:number]];
    else if ([Calculator isOpenBranch:lastBranch]) {
        [lastBranch addObject:[NSMutableArray arrayWithObject:[NSNumber numberWithDouble:number]]];
    }
}

- (void)addVariable:(NSString *)variable {
    if (![Calculator isOperator:variable]) {
        NSMutableArray *lastBranch = [self.programTree lastObject];
        if (!lastBranch) {
            lastBranch = [[NSMutableArray alloc] init];
            [lastBranch addObject:variable];
            [self.programTree addObject:lastBranch];
        }
        else if ([lastBranch count] == 0)
            [lastBranch addObject:variable];
        else if ([Calculator isOpenBranch:lastBranch]) {
            [lastBranch addObject:[NSMutableArray arrayWithObject:variable]];
        }
    }
}

- (void)addOperator:(NSString *)operator {
    NSMutableArray *lastBranch = [self.programTree lastObject];
    if ([Calculator isUnaryOperator:operator]) {
        if (lastBranch && ![Calculator isOpenBranch:lastBranch]) {
            NSMutableArray *newTopBranch = [[NSMutableArray alloc] init];
            [newTopBranch addObject:operator];
            [newTopBranch addObject:lastBranch];
            [self.programTree removeLastObject];
            [self.programTree addObject:newTopBranch];
            int programTreeSize = [self.programTree count];
            if (programTreeSize > 1) {
                NSMutableArray *parentBranch = [self.programTree objectAtIndex:(programTreeSize - 2)];
                [parentBranch removeLastObject];
                [parentBranch addObject:newTopBranch];
            }
       }
    }
    else if ([Calculator isBinaryOperator:operator]) {
        if (lastBranch && ![Calculator isOpenBranch:lastBranch]) {
            NSMutableArray *newTopBranch = [[NSMutableArray alloc] init];
            [newTopBranch addObject:operator];
            [newTopBranch addObject:lastBranch];
            [self.programTree removeLastObject];
            [self.programTree addObject:newTopBranch];
            int programTreeSize = [self.programTree count];
            if (programTreeSize > 1) {
                NSMutableArray *parentBranch = [self.programTree objectAtIndex:(programTreeSize - 2)];
                [parentBranch removeLastObject];
                [parentBranch addObject:newTopBranch];
            }
        }      
    }
    else if ([operator isEqualToString:@"("]) {
        if (!lastBranch) {
            lastBranch = [[NSMutableArray alloc] init];
            [self.programTree addObject:lastBranch];
        }
        else if ([Calculator isOpenBranch:lastBranch]) {
            NSMutableArray *newBranch =  [[NSMutableArray alloc] init];
            [lastBranch addObject:newBranch];
            [self.programTree addObject:newBranch];
        }      
    }
    else if ([operator isEqualToString:@")"]) {
        if (![Calculator isOpenBranch:lastBranch]) {
            [self.programTree removeLastObject];
        }      
    }
}

- (void)undo {
    int programTreeSize = [self.programTree count];
    if (programTreeSize > 0) {
        NSMutableArray *lastBranch = [self.programTree lastObject];
        if ([lastBranch count] == 0) {
            if (programTreeSize > 1) {
                NSMutableArray *parentBranch = [self.programTree objectAtIndex:(programTreeSize - 2)];
                [parentBranch removeLastObject];
                [self.programTree removeLastObject];
            }
        }
        else if ([lastBranch count] == 1) { 
            [lastBranch removeLastObject];
        }
        else if ([lastBranch count] == 2) {
            NSMutableArray *operandBranch = [lastBranch lastObject];
            [self.programTree removeLastObject];
            [self.programTree addObject:operandBranch];
            if (programTreeSize > 1) {
                NSMutableArray *parentBranch = [self.programTree objectAtIndex:(programTreeSize - 2)];
                [parentBranch removeLastObject];
                [parentBranch addObject:operandBranch];
            }
        }
        else if ([lastBranch count] == 3) {
            NSMutableArray *operandBranch = [lastBranch lastObject];
            if ([operandBranch isKindOfClass:[NSMutableArray class]]) {
                [self.programTree addObject:operandBranch];
                [self undo];
            }
            else
                [lastBranch removeLastObject];
        }
    }
}

+ (void)collectVariablesInBranch:(NSArray *)branch ToSet:(NSMutableArray *)variableArray{
    id firstObject = nil;
    
    if ([branch count] > 0) {
        firstObject = [branch objectAtIndex:0];
    }
    
    if (firstObject && [firstObject isKindOfClass:[NSString class]]) {
        if (![self isOperator:firstObject] && ![variableArray containsObject:firstObject])
            [variableArray addObject:firstObject];
        else if ([self isUnaryOperator:firstObject])
            [self collectVariablesInBranch:[branch lastObject] ToSet:variableArray];
        else if ([self isBinaryOperator:firstObject]) {
            [self collectVariablesInBranch:[branch objectAtIndex:1] ToSet:variableArray];
            if ([branch count] == 3)
                [self collectVariablesInBranch:[branch lastObject] ToSet:variableArray];
        }
    }
}

+ (NSArray *)setOfVariablesInProgram:(id)program {
    NSMutableArray *result = [[NSMutableArray alloc] init];
 
    if ([program isKindOfClass:[NSArray class]] && [program count] > 0) {
        [self collectVariablesInBranch:[program firstObject] ToSet:result];
    }
    
    return [result copy];
}

+ (id)evaluateProgramBranch:(NSArray *)branch withVariableValuation:(NSDictionary *)valuation {
    id result = nil;
    
    id firstObject = [branch objectAtIndex:0];
    
    if ([branch count] == 1) {
        if ([firstObject isKindOfClass:[NSNumber class]]) {
            result = firstObject;
        }
        else if ([firstObject isKindOfClass:[NSString class]] && ![self isOperator:firstObject]) {
            id value = [valuation valueForKey:firstObject];
            if (value && [value isKindOfClass:[NSNumber class]]) {
                result = value;
            }
            else {
                result = [NSNumber numberWithDouble:0];
            }
        }
        else {
            result = @"ERROR: invalid program format";
        }
    }
    else if ([branch count] == 2) {
        if ([firstObject isKindOfClass:[NSString class]]) {
            if ([firstObject isEqualToString:@"sin"]) {
                id operand = [self evaluateProgramBranch:[branch lastObject] withVariableValuation:valuation];
                if ([operand isKindOfClass:[NSNumber class]]) {
                    result = [NSNumber numberWithDouble:(sin(M_PI * [operand doubleValue] / 180))];
                }
                else
                    result = operand;
            }
            else if ([firstObject isEqualToString:@"cos"]) {
                id operand = [self evaluateProgramBranch:[branch lastObject] withVariableValuation:valuation];
                if ([operand isKindOfClass:[NSNumber class]]) {
                    result = [NSNumber numberWithDouble:(cos(M_PI * [operand doubleValue] / 180))];
                }
                else
                    result = operand;
            }
            else if ([firstObject isEqualToString:@"sqrt"]) {
                id operand = [self evaluateProgramBranch:[branch lastObject] withVariableValuation:valuation];
                if ([operand isKindOfClass:[NSNumber class]]) {
                    if ([operand doubleValue] >= 0)
                        result = [NSNumber numberWithDouble:(sqrt([operand doubleValue]))];
                    else
                        result = @"ERROR: square root of a negative";
                }
                else
                    result = operand;
            }
            else if ([firstObject isEqualToString:@"log"]) {
                id operand = [self evaluateProgramBranch:[branch lastObject] withVariableValuation:valuation];
                if ([operand isKindOfClass:[NSNumber class]]) {
                    if ([operand doubleValue] > 0)
                        result = [NSNumber numberWithDouble:(log([operand doubleValue]))];
                    else
                        result = @"ERROR: logarithm of a non-positive";
                }
                else
                    result = operand;
            }
            else {
                result = @"ERROR: invalid operator";
            }
        }
        else {
            result = @"ERROR: invalid program format";
        }
    }
    else if ([branch count] == 3) {
        if ([firstObject isKindOfClass:[NSString class]]) {
            if ([firstObject isEqualToString:@"+"]) {
                id operand1 = [self evaluateProgramBranch:[branch objectAtIndex:1] withVariableValuation:valuation];
                id operand2 = [self evaluateProgramBranch:[branch lastObject] withVariableValuation:valuation];
                if ([operand1 isKindOfClass:[NSNumber class]] && [operand2 isKindOfClass:[NSNumber class]]) {
                    result  = [NSNumber numberWithDouble:([operand1 doubleValue] + [operand2 doubleValue])];
                }
                else if (![operand1 isKindOfClass:[NSNumber class]])
                    result = operand1;
                else
                    result = operand2;
            }
            else if ([firstObject isEqualToString:@"-"]) {
                id operand1 = [self evaluateProgramBranch:[branch objectAtIndex:1] withVariableValuation:valuation];
                id operand2 = [self evaluateProgramBranch:[branch lastObject] withVariableValuation:valuation];
                if ([operand1 isKindOfClass:[NSNumber class]] && [operand2 isKindOfClass:[NSNumber class]]) {
                    result  = [NSNumber numberWithDouble:([operand1 doubleValue] - [operand2 doubleValue])];
                }
                else if (![operand1 isKindOfClass:[NSNumber class]])
                    result = operand1;
                else
                    result = operand2;
            }
            else if ([firstObject isEqualToString:@"*"]) {
                id operand1 = [self evaluateProgramBranch:[branch objectAtIndex:1] withVariableValuation:valuation];
                id operand2 = [self evaluateProgramBranch:[branch lastObject] withVariableValuation:valuation];
                if ([operand1 isKindOfClass:[NSNumber class]] && [operand2 isKindOfClass:[NSNumber class]]) {
                    result  = [NSNumber numberWithDouble:([operand1 doubleValue] * [operand2 doubleValue])];
                }
                else if (![operand1 isKindOfClass:[NSNumber class]])
                    result = operand1;
                else
                    result = operand2;
            }
            else if ([firstObject isEqualToString:@"/"]) {
                id operand1 = [self evaluateProgramBranch:[branch objectAtIndex:1] withVariableValuation:valuation];
                id operand2 = [self evaluateProgramBranch:[branch lastObject] withVariableValuation:valuation];
                if ([operand1 isKindOfClass:[NSNumber class]] && [operand2 isKindOfClass:[NSNumber class]]) {
                    double divisor = [operand2 doubleValue];
                    if (divisor)
                        result  = [NSNumber numberWithDouble:([operand1 doubleValue] / divisor)];
                    else
                        result = @"ERROR: divide by zero";
                }
                else if (![operand1 isKindOfClass:[NSNumber class]])
                    result = operand1;
                else
                    result = operand2;
            }
            else {
                result = @"ERROR: invalid operator";
            }
        }
        else {
            result = @"ERROR: invalid program format";
        }
    }
    else {
        result = @"ERROR: invalid program format";
    }
    
    return result;
}

+ (id)evaluateProgram:(id)program withVariableValuation:(NSDictionary *)valuation {
    id result = nil;
    
    if ([program isKindOfClass:[NSArray class]]) {
        if ([program count] == 0) {
            result = @"WARNING: The program is empty.";
        }
        else if ([program count] == 1 && ![self isOpenBranch:[program lastObject]]) {
            id branch = [program lastObject];
            result = [self evaluateProgramBranch:branch withVariableValuation:valuation];
        }
        else {
            result = @"ERROR: The program is partially constructed.";
        }
    }
    else {
        result = @"ERROR: Unknown program format.";
    }
    
    return result;
}

+ (id)evaluateProgram:(id)program {
    return [self evaluateProgram:program withVariableValuation:nil];
}

- (NSNumber *)performOperation:(NSString *)operator {
    NSNumber *result = nil;
    
    [self addOperator:operator];
    id resultOrError = [Calculator evaluateProgram:self.program];
    
    if ([resultOrError isKindOfClass:[NSNumber class]])
        result = resultOrError;
    
    return result;
}

- (void)reset {
    [self.programTree removeAllObjects];
}

+ (NSString *)descriptionOfBranch:(NSArray *)branch inProgram:(NSArray *)program{
    NSString *description;
    
    if ([program containsObject:branch] && [program objectAtIndex:0] != branch)
        description = @"(";
    else
        description = @"";
    
    id firstObject = nil;
    
    if ([branch count] > 0) {
        firstObject = [branch objectAtIndex:0];
    }
    
    if (firstObject) {
        if ([firstObject isKindOfClass:[NSNumber class]] && [branch count] == 1) {
            description = [description stringByAppendingFormat:@"%g", [firstObject doubleValue]];
        }
        else if ([firstObject isKindOfClass:[NSString class]]) {
            if (![self isOperator:firstObject]) {
                description = [description stringByAppendingString:firstObject];
            }
            else if ([self isUnaryOperator:firstObject]) {
                NSString *operand = [self descriptionOfBranch:[branch lastObject] inProgram:program];
                description = [description stringByAppendingFormat:@"%@(%@)", firstObject, operand];
            }
            else if ([firstObject isEqualToString:@"+"]) {
                NSString *operand = [self descriptionOfBranch:[branch objectAtIndex:1] inProgram:program];
                description  = [description stringByAppendingFormat:@"%@%@", operand, firstObject];
                if ([branch count] == 3) {
                    operand = [self descriptionOfBranch:[branch lastObject] inProgram:program];
                    description  = [description stringByAppendingFormat:@"%@", operand];
                }
            }
            else if ([firstObject isEqualToString:@"-"]) {
                NSString *operand = [self descriptionOfBranch:[branch objectAtIndex:1] inProgram:program];
                description  = [description stringByAppendingFormat:@"%@%@", operand, firstObject];
                if ([branch count] == 3) {
                    NSArray *branchOfOperand = [branch lastObject];
                    operand = [self descriptionOfBranch:branchOfOperand inProgram:program];
                    id topElement = [self topElementOfBranch:branchOfOperand];
                    if (![program containsObject:branchOfOperand] && topElement && [topElement isKindOfClass:[NSString class]] && ([topElement isEqualToString:@"+"] || [topElement isEqualToString:@"-"]))
                        description  = [description stringByAppendingFormat:@"(%@)", operand];
                    else
                        description  = [description stringByAppendingFormat:@"%@", operand];
                }
            }
            else if ([firstObject isEqualToString:@"*"]) {
                NSArray *branchOfOperand = [branch objectAtIndex:1];
                NSString *operand = [self descriptionOfBranch:branchOfOperand inProgram:program];
                id topElement = [self topElementOfBranch:branchOfOperand];
                if (![program containsObject:branchOfOperand] && topElement && [topElement isKindOfClass:[NSString class]] && ([topElement isEqualToString:@"+"] || [topElement isEqualToString:@"-"]))
                    description  = [description stringByAppendingFormat:@"(%@)%@", operand, firstObject];
                else
                    description  = [description stringByAppendingFormat:@"%@%@", operand, firstObject];
                if ([branch count] == 3) {
                    branchOfOperand = [branch lastObject];
                    operand = [self descriptionOfBranch:branchOfOperand inProgram:program];
                    topElement = [self topElementOfBranch:branchOfOperand];
                    if (![program containsObject:branchOfOperand] && topElement && [topElement isKindOfClass:[NSString class]] && ([topElement isEqualToString:@"+"] || [topElement isEqualToString:@"-"]))
                        description  = [description stringByAppendingFormat:@"(%@)", operand];
                    else
                        description  = [description stringByAppendingFormat:@"%@", operand];
                }
            }
            else if ([firstObject isEqualToString:@"/"]) {
                NSArray *branchOfOperand = [branch objectAtIndex:1];
                NSString *operand = [self descriptionOfBranch:branchOfOperand inProgram:program];
                id topElement = [self topElementOfBranch:branchOfOperand];
                if (![program containsObject:branchOfOperand] && topElement && [topElement isKindOfClass:[NSString class]] && ([topElement isEqualToString:@"+"] || [topElement isEqualToString:@"-"]))
                    description  = [description stringByAppendingFormat:@"(%@)%@", operand, firstObject];
                else
                    description  = [description stringByAppendingFormat:@"%@%@", operand, firstObject];
                if ([branch count] == 3) {
                    branchOfOperand = [branch lastObject];
                    operand = [self descriptionOfBranch:branchOfOperand inProgram:program];
                    topElement = [self topElementOfBranch:branchOfOperand];
                    if (![program containsObject:branchOfOperand] && topElement && [topElement isKindOfClass:[NSString class]] && [self isBinaryOperator:topElement])
                        description  = [description stringByAppendingFormat:@"(%@)", operand];
                    else
                        description  = [description stringByAppendingFormat:@"%@", operand];
                }
            }
        }
    }
    
    return description;
}

+ (NSString *)descriptionOfProgram:(id)program {
    NSString *description = @"";
    
    if ([program isKindOfClass:[NSArray class]] && [program count] > 0) {
        description = [self descriptionOfBranch:[program firstObject] inProgram:program];
    }
    
    return description;
}

@end
