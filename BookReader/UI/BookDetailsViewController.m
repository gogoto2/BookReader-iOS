//
//  BookDetailViewController.m
//  BookReader
//
//  Created by 颜超 on 13-3-27.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "BookDetailsViewController.h"
#import "BookReader.h"
#import "ServiceManager.h"
#import "UIViewController+HUD.h"
#import "Book.h"
#import "UIImageView+AFNetworking.h"
#import "GiftViewController.h"
#import "AppDelegate.h"
#import "UIButton+BookReader.h"
#import "SubscribeViewController.h"
#import "BookShelfViewController.h"
#import "BookReaderDefaultsManager.h"
#import "UIColor+BookReader.h"
#import <QuartzCore/QuartzCore.h>

#define INFOTABLEVIEWTAG     10001
#define BOOKRECOMMANDTAG     10002

@implementation BookDetailsViewController
{
    NSString *bookid;
    Book *bookObj;
    int currentIndex;
    UITextField *commitField;
    UIScrollView *scrollView;
    UITableView *infoTableView;
    UITableView *recommandTableView;
    
    NSMutableArray *infoArray;
    NSMutableArray *authorBookArray;
    NSMutableArray *sameTypeBookArray;
    BOOL bFav;
}

- (id)initWithBook:(NSString *)uid
{
    self = [super init];
    if (self) {
        bookid = uid;
        infoArray = [[NSMutableArray alloc] init];
        
        authorBookArray = [[NSMutableArray alloc] init];
        sameTypeBookArray = [[NSMutableArray alloc] init];
        bFav = NO;
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (bookObj == nil) {
        [self displayHUD:@"加载中..."];
        [ServiceManager bookDetailsByBookId:bookid andIntro:@"1" withBlock:^(Book *obj, NSError *error) {
            if(error) {
                [self displayHUDError:nil message:NETWORK_ERROR];
            }else {
                bookObj = obj;
                [self hideHUD:YES];
                [self initBookDetailUI];
            }
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor mainBackgroundColor]];
	// Do any additional setup after loading the view.
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setFrame: CGRectMake(10, 4, 48, 32)];
    [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

- (void)initBookDetailUI {
    UIView *firstBkgView = [[UIView alloc] initWithFrame:CGRectMake(5, 50, self.view.bounds.size.width-5*2, 180)];
    [firstBkgView.layer setCornerRadius:4];
    [firstBkgView.layer setMasksToBounds:YES];
    [firstBkgView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:firstBkgView];
    
    UIImageView *bookCover = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 90, 120)];
    NSURL *url = [NSURL URLWithString:bookObj.coverURL];
    UIImageView *tmpImageView = bookCover;
    [bookCover setImageWithURLRequest:[NSURLRequest requestWithURL:url] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [tmpImageView setImage:image];
        bookObj.cover = UIImageJPEGRepresentation(image, 1.0);
        dispatch_async(dispatch_get_main_queue(), ^{
            [firstBkgView addSubview:tmpImageView];
        });
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"error: %@", error);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)];
    [titleLabel setText:bookObj.name];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:titleLabel];
    
    UILabel *bookNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, firstBkgView.bounds.size.width-100, 30)];
    [bookNameLabel setText:[@"\t\t" stringByAppendingString:bookObj.name]];
    [bookNameLabel setBackgroundColor:[UIColor clearColor]];
    [firstBkgView addSubview:bookNameLabel];
    
    NSArray *labelTitles = @[@"\t\t作者:\t\t", @"\t\t类别:\t\t", @"\t\t字数:\t\t", @"\t\t更新时间:\t\t"];
    NSArray *labelNames = @[bookObj.author,bookObj.category,bookObj.words,bookObj.lastUpdate];
    
    for (int i = 0; i<[labelNames count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 30+20*i, firstBkgView.bounds.size.width-100, 20)];
        [label setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:220.0/255.0 alpha:1.0]];
        [label setTextColor:[UIColor grayColor]];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setText:[NSString stringWithFormat:@"%@%@",labelTitles[i],labelNames[i]]];
        [firstBkgView addSubview:label];
    }
    //1:送钻石 2:送鲜花 3:打赏 4:月票 5:投评价
    NSArray *buttonTitles = @[@"阅读",@"收藏",@"送钻石",@"送鲜花",@"打赏",@"投月票",@"投评价"];
    NSArray *imageNames = @[@"gift_demand" , @"gift_flower" ,@"gift_money" ,@"gift_monthticket" ,@"gift_comment"];
    for (int i=0; i<[buttonTitles count]; i++) {
        UIButton *button = nil;
        if (i>=2) {
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(5*(i-2)+290/5*(i-2), 150, 290/5, 20)];
            [button setImage:[UIImage imageNamed:imageNames[i-2]] forState:UIControlStateNormal];
        }else {
            button = [UIButton createButtonWithFrame:CGRectMake(110+100*i, 120, 80, 20)];
            [button setTitle:buttonTitles[i] forState:UIControlStateNormal];
        }
        [button setTag:i];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [firstBkgView addSubview:button];
    }
    if ([ServiceManager userID]!=nil) {
        [ServiceManager existsFavouriteWithBookID:bookid withBlock:^(NSString *result, NSError *error) {
            if (error) {
                
            } else {
                if ([result intValue]==1) {
                    bFav = YES;
                    UIButton *button = (UIButton *)[self.view viewWithTag:1];
                    [button setEnabled:NO];
                    [button setTitle:@"已收藏" forState:UIControlStateNormal];
                }
            }
        }];
    }
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 244, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height - 244)];
    [scrollView setContentSize:CGSizeMake(MAIN_SCREEN.size.width, scrollView.frame.size.height*1.8)];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:scrollView];
    
    UITextView *shortdescribeTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0,MAIN_SCREEN.size.width-10*2 , 120)];
    [shortdescribeTextView setText:bookObj.describe];
    [shortdescribeTextView setEditable:NO];
    [scrollView addSubview:shortdescribeTextView];
    
    infoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 130, MAIN_SCREEN.size.width, 140) style:UITableViewStylePlain];
    [infoTableView setDelegate:self];
    [infoTableView setTag:INFOTABLEVIEWTAG];
    [infoTableView setDataSource:self];
    [scrollView addSubview:infoTableView];
    [self loadCommitList];
    
    UIButton *sendCommitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sendCommitButton setFrame:CGRectMake(10, infoTableView.frame.origin.y+infoTableView.frame.size.height, MAIN_SCREEN.size.width-20, 30)];
    [sendCommitButton setTitle:@"发布评论" forState:UIControlStateNormal];
    [sendCommitButton addTarget:self action:@selector(sendCommitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:sendCommitButton];
    
    recommandTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, sendCommitButton.frame.origin.y + sendCommitButton.frame.size.height, MAIN_SCREEN.size.width, 140) style:UITableViewStylePlain];
    [recommandTableView setDelegate:self];
    [recommandTableView setTag:BOOKRECOMMANDTAG];
    [recommandTableView setDataSource:self];
    [scrollView addSubview:recommandTableView];
    
    [self loadAuthorOtherBook];
    [self loadSameType];
}

- (void)loadAuthorOtherBook
{
    [ServiceManager otherBooksFromAuthor:bookObj.authorID andCount:@"5" withBlock:^(NSArray *result, NSError *error) {
        if (error)
        {
            
        }
        else
        {
            if ([authorBookArray count]>0) {
                [authorBookArray removeAllObjects];
            }
            for (int i = 0 ; i<[result count]; i++) {
                Book *obj = [result objectAtIndex:i];
                if([obj.uid integerValue]!=[bookid integerValue])
                {
                    [authorBookArray addObject:obj];
                }
            }
            [recommandTableView reloadData];
        }
    }];
}

- (void)loadSameType
{
    [ServiceManager bookRecommand:bookObj.categoryID andCount:@"5" withBlock:^(NSArray *result, NSError *error) {
        if (error) {
            
        }
        else
        {
            if ([sameTypeBookArray count]>0) {
                [sameTypeBookArray removeAllObjects];
            }
            for (int i = 0 ; i<[result count]; i++) {
                Book *obj = [result objectAtIndex:i];
                if([obj.uid integerValue]!=[bookid integerValue])
                {
                    [sameTypeBookArray addObject:obj];
                }
            }
            [recommandTableView reloadData];
        }
    }];
}

- (void)sendCommitButtonClicked
{
    if ([self checkLogin] == NO)
        return;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入评论内容"
                                                    message:@"评论内容在此输入"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"发送", nil];
    commitField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
    [commitField setBackgroundColor:[UIColor whiteColor]];
    [alert addSubview:commitField];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
        [ServiceManager disscussWithBookID:bookid andContent:commitField.text withBlock:^(NSString *result, NSError *error)
         {
             if (error)
             {
                 
             }
             else
             {
                 [self showAlertWithMessage:result];
                 [self loadCommitList];
             }
         }];
    }
}

- (void)loadCommitList
{
    if ([infoArray count]>0)
    {
        [infoArray removeAllObjects];
    }
    [ServiceManager bookDiccusssListByBookId:bookid size:@"10" andIndex:@"1" withBlock:^(NSArray *result, NSError *error)
     {
         if (error)
         {
             
         }
         else
         {
             if ([result count]==10)
             {
                 [self addFootView];
                 currentIndex++;
             }
             [infoArray addObjectsFromArray:result];
             [infoTableView reloadData];
         }
     }];
}

- (void)pushToSubscribeView
{
    SubscribeViewController *childViewController = [[SubscribeViewController alloc] initWithBookId:bookObj andOnline:YES];
    [self.navigationController pushViewController:childViewController animated:YES];
}

- (void)buttonClicked:(id)sender
{
    switch ([sender tag]) {
        case 0:
            [self pushToSubscribeView];
            break;
        case 1:
            [self addFav];
            break;
        case 2:
            [self pushToGiftViewWithIndex:@"0"];
            break;
        case 3:
            [self pushToGiftViewWithIndex:@"1"];
            break;
        case 4:
            [self pushToGiftViewWithIndex:@"2"];
            break;
        case 5:
            [self pushToGiftViewWithIndex:@"3"];
            break;
        case 6:
            [self pushToGiftViewWithIndex:@"4"];
            break;
        default:
            break;
            //1:送钻石 2:送鲜花 3:打赏 4:月票 5:投评价
    }
}

- (void)pushToGiftViewWithIndex:(NSString *)index {
    if ([self checkLogin]) {
        GiftViewController *giftViewController = [[GiftViewController alloc] initWithIndex:index andBookObj:bookObj];
        [self.navigationController pushViewController:giftViewController animated:YES];
    }
}

- (BOOL)checkLogin
{
    if ([ServiceManager userID]==nil)
    {
        [self displayHUDError:nil message:@"您尚未登录!"];
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)addFav
{
    [self displayHUD:@"请稍等..."];
    if ([self checkLogin]) {
        [ServiceManager addFavouriteWithBookID:bookid andValue:YES withBlock:^(NSString *resultMessage,NSString *result, NSError *error) {
            if (!error)
            {
                if ([result isEqualToString:SUCCESS_FLAG]) {
                    bFav = YES;
                    UIButton *button = (UIButton *)[self.view viewWithTag:1];
                    [button setEnabled:NO];
                    [button setTitle:@"已收藏" forState:UIControlStateNormal];
                }
                [self displayHUDError:nil message:resultMessage];
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNeedRefreshBookShelf];
            } else {
                [self displayHUDError:nil message:NETWORK_ERROR];
            }
        }];
    }
}

- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
}

- (void)backButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == INFOTABLEVIEWTAG)
    {
        return [infoArray count];
    }
    else if (section == 0)
    {
        return [authorBookArray count];
    }
    else
    {
        return [sameTypeBookArray count];
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == BOOKRECOMMANDTAG)
    {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == INFOTABLEVIEWTAG)
    {
        return 50;
    }
    return 30;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == BOOKRECOMMANDTAG)
    {
        if (section == 0)
        {
            return @"作者书籍";
        }
        else
        {
            return @"同类推荐";
        }
    }
    return @"评论";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (tableView.tag == INFOTABLEVIEWTAG)
    {
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCell"];
            Commit *obj = [infoArray objectAtIndex:[indexPath row]];
            
            UITextView *messageTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height)];
            [messageTextView setEditable:NO];
            [messageTextView setText:[[NSString stringWithFormat:@"%@:%@\n%@",obj.userName,obj.content,obj.insertTime] stringByReplacingOccurrencesOfString:@"<p>" withString:@""]];
            [cell.contentView addSubview:messageTextView];
        }
    } else {
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCell"];
            if ([indexPath section]==0)
            {
                Book *obj = [authorBookArray objectAtIndex:[indexPath row]];
                cell.textLabel.text = obj.name;
            } else {
                Book *obj = [sameTypeBookArray objectAtIndex:[indexPath row]];
                cell.textLabel.text = obj.name;
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == BOOKRECOMMANDTAG)
    {
        if ([indexPath section] == 0)
        {
            Book *book = [authorBookArray objectAtIndex:[indexPath row]];
            BookDetailsViewController *childViewController = [[BookDetailsViewController alloc]initWithBook:book.uid];
            [self.navigationController pushViewController:childViewController animated:YES];
        }else
        {
            Book *book = [sameTypeBookArray objectAtIndex:[indexPath row]];
            BookDetailsViewController *childViewController = [[BookDetailsViewController alloc]initWithBook:book.uid];
            [self.navigationController pushViewController:childViewController animated:YES];
        }
    }
}

- (void)addFootView
{
    UIView *footview = [[UIView alloc]initWithFrame:CGRectMake(-4, 0, 316, 26)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(-4, 0, 316, 26)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [button setTitle:@"查看更多..." forState:UIControlStateNormal];
    [button.titleLabel setTextAlignment:UITextAlignmentCenter];
    [button addTarget:self action:@selector(getMore) forControlEvents:UIControlEventTouchUpInside];
    [footview addSubview:button];
    [infoTableView setTableFooterView:footview];
}

- (void)getMore
{
    [self displayHUD:@"加载中..."];
    [ServiceManager bookDiccusssListByBookId:bookid size:@"10" andIndex:[NSString stringWithFormat:@"%d",currentIndex] withBlock:^(NSArray *result, NSError *error)
     {
         if (error)
         {
             [self displayHUDError:nil message:NETWORK_ERROR];
         }else
         {
             if ([infoArray count]==0)
             {
                 [infoTableView setTableFooterView:nil];
             }
             [infoArray addObjectsFromArray:result];
             currentIndex++;
             [infoTableView reloadData];
             [self hideHUD:YES];
         }
     }];
}

@end
