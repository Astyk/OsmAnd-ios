//
//  OACollatorStringMatcher.m
//  OsmAnd
//
//  Created by Alexey Kulish on 21/12/2016.
//  Copyright © 2016 OsmAnd. All rights reserved.
//

#import "OACollatorStringMatcher.h"


@implementation OACollatorStringMatcher
{
    StringMatcherMode _mode;
    NSString *_part;
}


- (instancetype)initWithPart:(NSString *)part mode:(StringMatcherMode)mode
{
    self = [super init];
    if (self)
    {
        _part = [part lowercaseStringWithLocale:[NSLocale currentLocale]];
        _mode = mode;
    }
    return self;
}

- (BOOL) matches:(NSString *)name
{
    return [self.class cmatches:name part:_part mode:_mode];
}


+ (BOOL) cmatches:(NSString *)base part:(NSString *)part mode:(StringMatcherMode)mode
{
    switch (mode)
    {
        case CHECK_CONTAINS:
            return [self.class ccontains:base part:part];
        case CHECK_EQUALS_FROM_SPACE:
            return [self.class cstartsWith:base theStart:part checkBeginning:YES checkSpaces:YES equals:YES];
        case CHECK_STARTS_FROM_SPACE:
            return [self.class cstartsWith:base theStart:part checkBeginning:YES checkSpaces:YES equals:NO];
        case CHECK_STARTS_FROM_SPACE_NOT_BEGINNING:
            return [self.class cstartsWith:base theStart:part checkBeginning:NO checkSpaces:YES equals:NO];
        case CHECK_ONLY_STARTS_WITH:
            return [self.class cstartsWith:base theStart:part checkBeginning:YES checkSpaces:NO equals:NO];
    }
    return false;
}


/**
 * Check if part contains in base
 *
 * @param part String to search
 * @param base String where to search
 * @return true if part is contained in base
 */
+ (BOOL) ccontains:(NSString *)base part:(NSString *)part
{
    //		int pos = 0;
    //		if (part.length() > 3) {
    //			// improve searching by searching first 3 characters
    //			pos = cindexOf(collator, pos, part.substring(0, 3), base);
    //			if (pos == -1) {
    //				return false;
    //			}
    //		}
    //		pos = cindexOf(collator, pos, part, base);
    //		if (pos == -1) {
    //			return false;
    //		}
    //		return true;
    
    if (base.length <= part.length)
        return [base localizedCompare:part] == 0;
    
    for (int pos = 0; pos <= base.length - part.length + 1; pos++)
    {
        NSString *temp = [base substringFromIndex:pos];
        
        for (NSInteger length = temp.length; length >= 0; length--)
        {
            NSString *temp2 = [temp substringToIndex:length];
            if ([temp2 localizedCompare:part])
                return YES;
        }
    }
    
    return NO;
}

+ (int) cindexOf:(int)start part:(NSString *)part base:(NSString *)base
{
    for (int pos = start; pos <= base.length - part.length; pos++)
    {
        if ([[base substringWithRange:NSMakeRange(pos, part.length)] localizedCompare:part] == 0)
            return pos;
    }
    return -1;
}

/**
 * Checks if string starts with another string.
 * Special check try to find as well in the middle of name
 *
 * @param searchIn
 * @param theStart
 * @return true if searchIn starts with token
 */
+ (BOOL) cstartsWith:(NSString *)searchInParam theStart:(NSString *)theStart checkBeginning:(BOOL)checkBeginning checkSpaces:(BOOL)checkSpaces equals:(BOOL)equals
{
    NSString *searchIn = [searchInParam lowercaseStringWithLocale:[NSLocale currentLocale]];
    NSInteger startLength = theStart.length;
    NSInteger searchInLength = searchIn.length;
    if (startLength == 0)
        return YES;

    if (startLength > searchInLength)
        return NO;

    // simulate starts with for collator
    if (checkBeginning)
    {
        BOOL starts = [[searchIn substringToIndex:startLength] localizedCompare:theStart] == 0;
        if (starts)
        {
            if (equals)
            {
                if (startLength == searchInLength || [self.class isSpace:[searchIn characterAtIndex:startLength]])
                {
                    return YES;
                }
            }
            else
            {
                return YES;
            }
        }
    }
    if (checkSpaces)
    {
        for (int i = 1; i <= searchInLength - startLength; i++)
        {
            if ([self.class isSpace:[searchIn characterAtIndex:i - 1]] && ![self.class isSpace:[searchIn characterAtIndex:i]])
            {
                if ([[searchIn substringWithRange:NSMakeRange(i, startLength)] localizedCompare:theStart] == 0)
                {
                    if (equals)
                    {
                        if (i + startLength == searchInLength || [self.class isSpace:[searchIn characterAtIndex:i + startLength]])
                        {
                            return YES;
                        }
                    }
                    else
                    {
                        return true;
                    }
                }
            }
        }
    }
    return NO;
}

+ (BOOL) isSpace:(unichar) c
{
    return ![[NSCharacterSet letterCharacterSet] characterIsMember:c] && ![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:c];
}

@end
