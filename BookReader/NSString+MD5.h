//
//  NSString+MD5.h
//  BookReader
//
//  Created by 颜超 on 13-4-2.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (md5)
- (NSString *) md516;
- (NSString *) md532;
@end

#import "NSString+MD5.h"
#import<CommonCrypto/CommonDigest.h>
@implementation NSString (md5)
- (NSString *) md516
{
    NSString *md5String = [self md532];
    NSMutableString *returnString = [NSMutableString string];
    for (int i = 8; i<24; i++) {
        [returnString appendFormat:@"%c",[md5String characterAtIndex:i]];
    }
    return [returnString lowercaseString];
}

- (NSString *) md532
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr),result );
    NSMutableString *hash =[NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}
@end
