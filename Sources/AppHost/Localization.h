//
//  Localization.h
//  OsmAnd
//
//  Created by Alexey Pelykh on 3/18/14.
//  Copyright (c) 2014 OsmAnd. All rights reserved.
//

#ifndef OsmAnd_Localization_h
#define OsmAnd_Localization_h

#import <Foundation/Foundation.h>

#pragma GCC diagnostic ignored "-Wformat-security"

#define OALocalizedString(defaultValue, ...) \
    _OALocalizedString(false, defaultValue, ##__VA_ARGS__)

#define OALocalizedStringUp(defaultValue, ...) \
    _OALocalizedString(true, defaultValue, ##__VA_ARGS__)

static inline NSString* _OALocalizedString(BOOL upperCase, NSString* defaultValue, ...)
{
    NSArray *arr = [defaultValue componentsSeparatedByString:@" "];
    NSString *key;
    for (NSString *s in arr)
        if (s.length > 0 && [s characterAtIndex:0] != '%')
        {
            key = s;
            break;
        }

    NSString *res;
    if (key)
    {
        NSString *newValue = [defaultValue stringByReplacingOccurrencesOfString:key withString:NSLocalizedString(key, nil)];
        va_list args;
        va_start(args, defaultValue);
        if (upperCase)
            res = [[[NSString alloc] initWithFormat:newValue arguments:args] uppercaseStringWithLocale:[NSLocale currentLocale]];
        else
            res = [[NSString alloc] initWithFormat:newValue arguments:args];
        
        va_end(args);
    }
    else
    {
        va_list args;
        va_start(args, defaultValue);
        if (upperCase)
            res = [[[NSString alloc] initWithFormat:NSLocalizedString(defaultValue, nil) arguments:args] uppercaseStringWithLocale:[NSLocale currentLocale]];
        else
            res = [[NSString alloc] initWithFormat:NSLocalizedString(defaultValue, nil) arguments:args];

        va_end(args);
    }
    
    return res;
}

/*
#define OALocalizedString(defaultValue) \
    _OALocalizedString(defaultValue, __FILE__, __LINE__, __PRETTY_FUNCTION__)
inline NSString* _OALocalizedString(NSString* defaultValue, const char* file, unsigned int line, const char* prettyFunction)
{
    NSString* key = [NSString stringWithFormat:@"%s(%d):'%@'", prettyFunction, line, defaultValue];
    NSString* comment = [NSString stringWithFormat:@"%s:%d:%s:'%@'", file, line, prettyFunction, defaultValue];
    return NSLocalizedStringWithDefaultValue(key, nil, [NSBundle mainBundle], defaultValue, comment);
}
*/
#endif
