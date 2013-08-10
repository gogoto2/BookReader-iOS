//
//  UIButton+BookReader.h
//  BookReader
//
//  Created by ZoomBin on 13-5-8.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BookReaderButtonStyleLeft = 0,
    BookReaderButtonStyleRight = 1,
    BookReaderButtonStyleNormal = 2,
    BookReaderButtonStyleBack = 3,
}BookReaderButtonStyle;

typedef enum {
    BookReaderBookStoreBottomButtonStyleRecomend = 0,
    BookReaderBookStoreBottomButtonStyleCatagory = 1,
    BookReaderBookStoreBottomButtonStyleRank = 2,
    BookReaderBookStoreBottomButtonStyleSearch = 3,
}BookReaderBookStoreBottomButtonStyle;

typedef enum {
    BookReaderBookStoreBottomButtonStyleAll = 0,
    BookReaderBookStoreBottomButtonStyleNew = 1,
    BookReaderBookStoreBottomButtonStyleHot = 2,
}BookReaderBookStoreRankButtonStyle;

@interface UIButton (BookReader)
+ (UIButton *)addButtonWithFrame:(CGRect)frame andStyle:(BookReaderButtonStyle)style;

+ (UIButton *)createButtonWithFrame:(CGRect)frame;
- (void)cooldownButtonFrame:(CGRect)frame andEnableCooldown:(BOOL)cooldown;
+ (UIButton *)fontButton:(CGRect)frame;

- (void)setDisabled:(BOOL)disabled;
- (void)startCoolDownDuration:(NSTimeInterval)delay;

+ (UIButton *)bookStoreBottomButtonWithFrame:(CGRect)frame andStyle:(BookReaderBookStoreBottomButtonStyle)style;
+ (UIButton *)navigationBackButton;

@end
