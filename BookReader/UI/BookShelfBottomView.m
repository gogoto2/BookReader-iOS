//
//  BookShelfBottomView.m
//  BookReader
//
//  Created by 颜超 on 13-4-18.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "BookShelfBottomView.h"
#import "UIDefines.h"
#import <QuartzCore/QuartzCore.h>

#define DURATION 0.3   // 动画持续时间(秒)

#define EDIT_BUTTON_FRAME                      CGRectMake(10, 4, 48, 32)
#define Finish_BUTTON_FRAME                    CGRectMake(10, 4, 48, 32)
#define DELETE_BUTTON_FRAME                    CGRectMake(MAIN_SCREEN.size.width-60,4,48,32)
#define REFRESH_BUTTON_FRAME                 CGRectMake(MAIN_SCREEN.size.width-110,4,48,32)
#define HISTORY_BUTTON_FRAME                 CGRectMake(MAIN_SCREEN.size.width-60,4,48,32)

@implementation BookShelfBottomView {
    NSMutableArray *buttonArray;
}
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        buttonArray = [[NSMutableArray alloc] init];
        UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
        [backgroundImage setImage:[UIImage imageNamed:@"toolbar_top_bar"]];
        [self addSubview:backgroundImage];
        [self addButtons];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:frame];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setText:@"我的书架"];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:titleLabel];
    }
    return self;
}

- (void)addButtons {
    bottomViewOne = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:bottomViewOne];
    
    bottomViewTwo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:bottomViewTwo];
    [bottomViewTwo setHidden:YES];
    
    NSArray *titles = @[@"编辑", @"更新", @"历史", @"书架" ,@"删除", @"完成"];
    NSArray *rectStrings = @[NSStringFromCGRect(EDIT_BUTTON_FRAME), NSStringFromCGRect(REFRESH_BUTTON_FRAME),NSStringFromCGRect(HISTORY_BUTTON_FRAME),NSStringFromCGRect(HISTORY_BUTTON_FRAME), NSStringFromCGRect(DELETE_BUTTON_FRAME), NSStringFromCGRect(Finish_BUTTON_FRAME)];
    NSArray *selectorStrings = @[@"editButtonClick", @"refreshButtonClick", @"historyButtonClick", @"shelfButtonClick", @"deleteButtonClick", @"finishButtonClick"];
    
#define UIIMAGE(x) [UIImage imageNamed:x]
    NSArray *images = @[UIIMAGE(@"search_btn"), UIIMAGE(@"search_btn"), UIIMAGE(@"search_btn"), UIIMAGE(@"search_btn"),UIIMAGE(@"search_btn"), UIIMAGE(@"search_btn")];
    NSArray *highlightedImages = @[UIIMAGE(@"search_btn_hl"), UIIMAGE(@"search_btn_hl"), UIIMAGE(@"search_btn_hl"), UIIMAGE(@"search_btn_hl"), UIIMAGE(@"search_btn_hl"), UIIMAGE(@"search_btn_hl")];
    
    NSAssert(titles.count == rectStrings.count && rectStrings.count == selectorStrings.count && selectorStrings.count == images.count && images.count == highlightedImages.count, @"titles.count, rectStrings.count, selectorStrings.count, images.count, highlightedImages.count can't match each other...");
    
    for (int i = 0; i < 6; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setBackgroundImage:images[i] forState:UIControlStateNormal];
        [button setBackgroundImage:highlightedImages[i] forState:UIControlStateHighlighted];
        [button setTag:i];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button setFrame: CGRectFromString(rectStrings[i])];
        [button addTarget:self action:NSSelectorFromString(selectorStrings[i]) forControlEvents:UIControlEventTouchUpInside];
        if ([titles[i] isEqualToString:@"完成"]) {
            [button setBackgroundColor:[UIColor greenColor]];
            [button.layer setCornerRadius:6];
            [button.layer setBorderWidth:1.0];
            [button.layer setBorderColor:[UIColor grayColor].CGColor];
            [button.layer setMasksToBounds:YES];
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [bottomViewTwo addSubview:button];
        } else if ([titles[i] isEqualToString:@"删除"]) {
            [button setBackgroundColor:[UIColor redColor]];
            [button.layer setCornerRadius:6];
            [button.layer setBorderWidth:1.0];
            [button.layer setBorderColor:[UIColor grayColor].CGColor];
            [button.layer setMasksToBounds:YES];
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [bottomViewTwo addSubview:button];
        } else {
            [bottomViewOne addSubview:button];
        }
        if (i==3) {
            [button setHidden:YES];
        }
        [buttonArray addObject:button];
    }
}


- (void)finishButtonClick {
    [bottomViewOne setHidden:NO];
    [bottomViewTwo setHidden:YES];
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = DURATION;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"cube";
    animation.subtype = kCATransitionFromBottom;
    NSUInteger green = [[self subviews] indexOfObject:bottomViewOne];
    NSUInteger blue = [[self subviews] indexOfObject:bottomViewTwo];
    [self exchangeSubviewAtIndex:green withSubviewAtIndex:blue];
    [[self layer] addAnimation:animation forKey:@"animation"];
    
    [self invokeDelegateMethod:kBottomViewButtonFinishEditing];
}

- (void)editButtonClick {
    [bottomViewOne setHidden:YES];
    [bottomViewTwo setHidden:NO];
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = DURATION;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"cube";
    animation.subtype = kCATransitionFromTop;
    NSUInteger green = [[self subviews] indexOfObject:bottomViewOne];
    NSUInteger blue = [[self subviews] indexOfObject:bottomViewTwo];
    [self exchangeSubviewAtIndex:green withSubviewAtIndex:blue];
    [[self layer] addAnimation:animation forKey:@"animation"];
    
    [self invokeDelegateMethod:kBottomViewButtonEdit];
}

- (void)deleteButtonClick {
    [self invokeDelegateMethod:kBottomViewButtonDelete];
}

- (void)historyButtonClick {
    UIButton *historyButton = (UIButton *)[buttonArray objectAtIndex:2];
    [historyButton setHidden:YES];
    UIButton *shelfButton = (UIButton *)[buttonArray objectAtIndex:3];
    [shelfButton setHidden:NO];
    [self invokeDelegateMethod:kBottomViewButtonBookHistoroy];
}

- (void)refreshButtonClick {
    [self invokeDelegateMethod:kBottomViewButtonRefresh];
}

- (void)shelfButtonClick {
    UIButton *historyButton = (UIButton *)[buttonArray objectAtIndex:2];
    [historyButton setHidden:NO];
    UIButton *shelfButton = (UIButton *)[buttonArray objectAtIndex:3];
    [shelfButton setHidden:YES];
    [self invokeDelegateMethod:kBottomViewButtonShelf];
}

- (void)invokeDelegateMethod:(BottomViewButtonType)type {
    if ([self.delegate respondsToSelector:@selector(bottomButtonClicked:)]) {
        [self.delegate performSelector:@selector(bottomButtonClicked:) withObject:@(type)];
    }
}

@end
