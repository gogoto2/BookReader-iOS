//
//  NSUserDefaults+BookReader.h
//  BookReader
//
//  Created by zhangbin on 8/2/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UserDefaultKeyFontSize @"font_size"
#define UserDefaultKeyFontName @"font_name"
#define UserDefaultKeyFont @"font"
#define UserDefaultKeyBright @"bright"
#define UserDefaultKeyBackground @"background"
#define UserDefaultKeyNotFirstRead @"not_first_read"
#define UserDefaultKeyScreen @"screen"
#define UserDefaultKeyPage  @"page"

//屏幕
#define UserDefaultScreenLandscape @"reading_landscape"
#define UserDefaultScreenPortrait @"reading_portrait"

//字体大小
#define UserDefaultFontSizeMax @23
#define UserDefaultFontSizeMin @19

//字体名
#define UserDefaultSystemFont @"Arial"
#define UserDefaultFoundFont @"FZLTHJW--GB1-0"
#define UserDefaultNorthFont @"FZBWKSJW--GB1-0"

//翻页
#define UserDefaultRealPage @"real"  //仿真
#define UserDefaultSimplePage   @"simple" //简约

@interface NSUserDefaults (BookReader)

+ (void)brSetObject:(id)object ForKey:(id)key;
+ (id)brObjectForKey:(id)key;
+ (UIColor *)brBackgroundColorWithIndex:(NSInteger)index;
+ (UIColor *)brTextColorWithIndex:(NSInteger)index;
+ (void)brReset;


@end
