//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Yi Zhu on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "Calculator.h"

@interface CalculatorViewController ()

@property (nonatomic) BOOL userIsEnteringANumber;
@property (nonatomic, strong) Calculator *calculator;
@property (nonatomic) BOOL isInErrorMode;
@property (nonatomic, strong) NSString *currentNumberOrVariable;
@property (nonatomic, strong) NSString *currentProgramDescription;
@property (nonatomic) BOOL waitingForVariableValues;
@property (nonatomic, strong) NSMutableArray *variablesToBeValuated;
@property (nonatomic, strong) NSMutableDictionary *valuation;

@end

@implementation CalculatorViewController
@synthesize display = _display;
@synthesize userIsEnteringANumber = _userIsEnteringANumber;
@synthesize calculator = _calculator;
@synthesize isInErrorMode = _isInErrorMode;
@synthesize currentNumberOrVariable = _currentNumberOrVariable;
@synthesize currentProgramDescription = _currentProgramDescription;
@synthesize waitingForVariableValues = _waitingForVariableValues;
@synthesize variablesToBeValuated = _variablesToBeValuated;
@synthesize valuation = _valuation;

- (NSString *)currentNumberOrVariable {
    if (!_currentNumberOrVariable)
        _currentNumberOrVariable = @"";
    return _currentNumberOrVariable;
}

- (NSString *)currentProgramDescription {
    if (!_currentProgramDescription)
        _currentProgramDescription = @"";
    return _currentProgramDescription;
}

- (NSMutableArray *)variablesToBeValuated {
    if (!_variablesToBeValuated)
        _variablesToBeValuated = [[NSMutableArray alloc] init];
    return _variablesToBeValuated;
}

- (NSMutableDictionary *)valuation {
    if (!_valuation)
        _valuation = [[NSMutableDictionary alloc] init];
    return _valuation;
}

- (Calculator *)calculator {
    if (!_calculator) {
        _calculator = [[Calculator alloc] init];
    }
    return _calculator;
}

- (void)updateDisplayWithProgramDescription:(NSString *)description AndNumberOrVariable:(NSString *)numberOrVariable {
    if (description) {
        self.currentProgramDescription = description;
    }
    if (numberOrVariable) {
        self.currentNumberOrVariable = numberOrVariable;
    }
    else {
        self.currentNumberOrVariable = @"0";
    }
    
    if ([self.currentNumberOrVariable isEqualToString:@"0"] && ![self.currentProgramDescription isEqualToString:@""])
        self.display.text = [self.currentProgramDescription stringByAppendingString:@""];
    else
        self.display.text = [self.currentProgramDescription stringByAppendingString:self.currentNumberOrVariable];
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *currentDigit = sender.currentTitle;
    
    if ([currentDigit isEqualToString:@"<"]) {
        if (!self.isInErrorMode) {
            if (!self.waitingForVariableValues && [self.currentNumberOrVariable isEqualToString:@"0"]) {
                [self.calculator undo];
                [self updateDisplayWithProgramDescription:[Calculator descriptionOfProgram:self.calculator.program] AndNumberOrVariable:@"0"];
            }
            else if (self.currentNumberOrVariable.length <= 1) {
                [self updateDisplayWithProgramDescription:nil AndNumberOrVariable:@"0"];
                self.userIsEnteringANumber = NO;
            }
            else if (self.display.text.length == 2 && [self.display.text rangeOfString:@"-"].location != NSNotFound) {
                [self updateDisplayWithProgramDescription:nil AndNumberOrVariable:@"0"];
                self.userIsEnteringANumber = NO;
            }
            else {
                [self updateDisplayWithProgramDescription:nil AndNumberOrVariable:[self.currentNumberOrVariable substringToIndex:(self.currentNumberOrVariable.length - 1)]];
                self.userIsEnteringANumber = YES;
            }
        }
    }
    else if ([currentDigit isEqualToString:@"∏"]) {
        [self updateDisplayWithProgramDescription:nil AndNumberOrVariable:[NSString stringWithFormat:@"%g", M_PI]];
        self.userIsEnteringANumber = NO;
        self.isInErrorMode = NO;
    }
    else if ([currentDigit isEqualToString:@"X"] || [currentDigit isEqualToString:@"Y"] || [currentDigit isEqualToString:@"Z"]) {
        if (!self.waitingForVariableValues) {
            [self updateDisplayWithProgramDescription:nil AndNumberOrVariable:currentDigit];
            self.userIsEnteringANumber = NO;
            self.isInErrorMode = NO;      
        }
    }
    else if ([currentDigit isEqualToString:@"+ / -"]) {
        NSString *numberText = self.currentNumberOrVariable;
        if (!self.isInErrorMode && ([numberText rangeOfString:@"1"].location != NSNotFound || [numberText rangeOfString:@"2"].location != NSNotFound || [numberText rangeOfString:@"3"].location != NSNotFound || [numberText rangeOfString:@"4"].location != NSNotFound || [numberText rangeOfString:@"5"].location != NSNotFound || [numberText rangeOfString:@"6"].location != NSNotFound || [numberText rangeOfString:@"7"].location != NSNotFound || [numberText rangeOfString:@"8"].location != NSNotFound || [numberText rangeOfString:@"9"].location != NSNotFound)) {
            if ([numberText rangeOfString:@"-"].location != 0) {
                [self updateDisplayWithProgramDescription:nil AndNumberOrVariable:[@"-" stringByAppendingString:numberText]];
            }
            else{
                [self updateDisplayWithProgramDescription:nil AndNumberOrVariable:[numberText substringFromIndex:1]];
            }
        }
    }
    else if ([currentDigit isEqualToString:@"("] || [currentDigit isEqualToString:@")"]) {
        if (!self.waitingForVariableValues) {
            [self.calculator addOperator:currentDigit];
            id program = self.calculator.program;
            [self updateDisplayWithProgramDescription:[Calculator descriptionOfProgram:program] AndNumberOrVariable:self.currentNumberOrVariable];
        }
    }
    else if (!self.userIsEnteringANumber) {
        if (![currentDigit isEqualToString:@"0"]) {
            self.userIsEnteringANumber = YES;
        }
        
        if ([currentDigit isEqualToString:@"."]) {
            [self updateDisplayWithProgramDescription:nil AndNumberOrVariable:@"0."];
        }
        else {
            [self updateDisplayWithProgramDescription:nil AndNumberOrVariable:currentDigit];
        }
        
        self.isInErrorMode = NO;
    }
    else if (self.userIsEnteringANumber) {
        if (![currentDigit isEqualToString:@"."] || [self.currentNumberOrVariable rangeOfString:@"."].location == NSNotFound) {
            [self updateDisplayWithProgramDescription:nil AndNumberOrVariable:[self.currentNumberOrVariable stringByAppendingString:currentDigit]];
        }
    }
}

- (IBAction)clearPressed {
    self.userIsEnteringANumber = NO;
    self.isInErrorMode = NO;
    self.waitingForVariableValues = NO;
    [self.variablesToBeValuated removeAllObjects];
    [self.valuation removeAllObjects];
    self.display.text = @"0";
    self.currentNumberOrVariable = @"";
    self.currentProgramDescription = @"";
    [self.calculator reset];
}

- (IBAction)operatorPressed:(UIButton *)sender {
    if (self.isInErrorMode)
        return;
    
    self.userIsEnteringANumber = NO;
    
    if (!self.waitingForVariableValues && ![sender.currentTitle isEqualToString:@"("]) {
        if ([self.currentNumberOrVariable isEqualToString:@"X"] || [self.currentNumberOrVariable isEqualToString:@"Y"] || [self.currentNumberOrVariable isEqualToString:@"Z"]) {
            [self.calculator addVariable:self.currentNumberOrVariable];
        }
        else {
            [self.calculator addOperand:[self.currentNumberOrVariable doubleValue]];
        }
    }
    
    id program = self.calculator.program;
    
    if ([sender.currentTitle isEqualToString:@"="]) {
        id result;
        
        if (!self.waitingForVariableValues) {
            self.variablesToBeValuated = [[Calculator setOfVariablesInProgram:program] mutableCopy];
            if ([self.variablesToBeValuated count] == 0)
                result = [Calculator evaluateProgram:program];
            else {
                self.waitingForVariableValues = YES;
            }
        }
        else {
            [self.valuation setObject:[NSNumber numberWithDouble:[self.currentNumberOrVariable doubleValue]] forKey:[self.variablesToBeValuated objectAtIndex:0]];
            [self.variablesToBeValuated removeObjectAtIndex:0];
            if ([self.variablesToBeValuated count] == 0) {
                self.waitingForVariableValues = NO;
                result = [Calculator evaluateProgram:program withVariableValuation:self.valuation];
            }
        }
  
        if (result && [result isKindOfClass:[NSNumber class]]) {
            [self updateDisplayWithProgramDescription:@"" AndNumberOrVariable:[NSString stringWithFormat:@"%g", [result doubleValue]]];
        }
        else if ([result isKindOfClass:[NSString class]]) {
            [self updateDisplayWithProgramDescription:result AndNumberOrVariable:nil];
            self.isInErrorMode = YES;
        }
        else if (self.waitingForVariableValues)
            [self updateDisplayWithProgramDescription:[[self.variablesToBeValuated objectAtIndex:0] stringByAppendingString:@" = "] AndNumberOrVariable:@"0"];
        else {
            [self updateDisplayWithProgramDescription:@"Unkown error." AndNumberOrVariable:nil];
            self.isInErrorMode = YES;
        }
        
        if (!self.waitingForVariableValues)
            [self.calculator reset];
    }
    else if (!self.waitingForVariableValues) {
        [self.calculator addOperator:sender.currentTitle];
        program = self.calculator.program;
        [self updateDisplayWithProgramDescription:[Calculator descriptionOfProgram:program] AndNumberOrVariable:nil];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
