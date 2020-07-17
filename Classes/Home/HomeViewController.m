//
//  HomeViewController.m
//  Tinder
//
//  Created by Sanskar on 26/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "HomeViewController.h"
#import "JSDemoViewController.h"
#import "Base64.h"
#import "UIImageView+AFNetworking.h"

#define screenWidth [UIScreen mainScreen].bounds.size.width

BOOL g_isSwipping = NO;

static const CGFloat UserLikeButtonHorizontalPadding = 80.f;
static const CGFloat UserLikeButtonVerticalPadding = 160.f;
static const CGFloat UserlikeButtonSize=60.f;
@interface HomeViewController ()
{
//    BOOL inAnimation;
   
//    CALayer *waveLayer;
  
    //EGOImageView *profileImageView;
  
    NSMutableArray *myProfileMatches;
    
    IBOutlet UIView *matchesView;
    IBOutlet UIView *visibleView1;
    IBOutlet UIView *visibleView2;
    
    IBOutlet UIView *visibleView3;
    IBOutlet UIView *visibleView4;
    
    IBOutlet EGOImageView *mainImageView;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *nameLabel2;
    IBOutlet UILabel *commonFriends;
    IBOutlet UILabel *picsCount;
    IBOutlet UILabel *commonInterest;
    
    IBOutlet UILabel *lblMutualFriend2;
    IBOutlet UILabel *lblMutualLikes2;
  
    CGFloat xDistanceForSnapShot;
    CGFloat yDistanceForSnapShot;
    
    CGPoint originalPositionOfvw1;
    CGPoint originalPositionOfvw2;
    CGPoint originalPositionOfvw3;
    CGRect originalFrameOfVW1;
    CGRect originalFrameOfVW2;
    CGRect originalFrameOfVW3;
    
    NSInteger lastIndexOfPage;
    NSInteger indexOfPageCalledWithNavigationButtons;
    
    CGFloat lastContentOffset;
}

@property (nonatomic, strong, readonly) IBOutlet EGOImageView *imgvw;
@property (nonatomic, strong) IBOutlet UILabel *decision;
@property (nonatomic, strong) IBOutlet UILabel *liked;
@property (nonatomic, strong) IBOutlet UILabel *nope;
@property (nonatomic, strong) IBOutlet UIButton *likedBtn;
@property (nonatomic, strong) IBOutlet UIButton *nopeBtn;
@property (nonatomic, strong) IBOutlet UILabel *lblNoOfImage;

@property (nonatomic, strong) IBOutlet UIButton *btnLiked;
@property (nonatomic, strong) IBOutlet UIButton *btnNope;
@end

@implementation HomeViewController
@synthesize imgvw;
@synthesize liked;
@synthesize nope;
@synthesize lblNoOfImage;


#pragma mark -
#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark - View cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    g_isSwipping = NO;
    
    [self getLocation];
    [self initialSettingUpHomeView];
    //[self showQuestionViewIfFirstTimeLaunch];
    [self addingAllViewsInSideScroller];
    //[self setupViewControllers];
    
    //Adding Notification Observers
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userDidLoginToXmpp) name:NOTIFICATION_XMPP_LOGGED_IN object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(homeScreenRefresh) name:NOTIFICATION_HOMESCREEN_REFRESH object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(navigateToNewScreenWithInfo:) name:NOTIFICATION_SCREEN_NAVIGATION_BUTTON_CLICKED object:nil];
    
    
    UISwipeGestureRecognizer* swipeleftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(movedLeft:)];
    swipeleftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer* swiperightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(movedRight:)];
    swiperightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [homeScreenView addGestureRecognizer:swipeleftGestureRecognizer];
    [homeScreenView addGestureRecognizer:swiperightGestureRecognizer];
    
    [self fetchfbevents];
    
    if (![USER_DEFAULT boolForKey:@"DownloadImages"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DownloadImages"];
        [self fetchProfilePictures];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     self.navigationController.navigationBarHidden = YES;
}


-(void)showProfilePic
{
    CGSize size = imgPhoto.frame.size;
    /*
    NSMutableDictionary *dic = [UserDefaultHelper sharedObject].facebookUserDetail;
    NSString *strUrl = [[[dic objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
    [imgPhoto setImageWithURL:[NSURL URLWithString:strUrl]];
    */
    [imgPhoto setImageWithURL:[NSURL URLWithString:[User currentUser].profile_pic]];
    
    [imgPhoto.layer setCornerRadius:size.width / 2.0f];
    [imgPhoto.layer setMasksToBounds:YES];
    
}

-(void)initialSettingUpHomeView
{
    lblNoFriendAround.hidden = NO;
    btnInvite.hidden = YES;
    
    [Helper setToLabel:lblNoFriendAround Text:@"Looking for other Krowners" WithFont:SEGOUE_UI FSize:24 Color:[UIColor colorWithRed:202/255.0f green:146/255.0f blue:128/255.0f alpha:1]];
    lblNoFriendAround.textAlignment = NSTextAlignmentCenter;
    
    [visibleView1.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [visibleView1.layer setBorderWidth: 0.7];
    [visibleView2.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [visibleView2.layer setBorderWidth: 0.7];
    [visibleView3.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [visibleView3.layer setBorderWidth: 0.7];
    [visibleView4.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [visibleView4.layer setBorderWidth: 0.7];
    
    [visibleView1.layer setCornerRadius:7.0];
    [visibleView1.layer setMasksToBounds:YES];
    [visibleView2.layer setCornerRadius:7.0];
    [visibleView2.layer setMasksToBounds:YES];
    [visibleView3.layer setCornerRadius:7.0];
    [visibleView3.layer setMasksToBounds:YES];
    [visibleView4.layer setCornerRadius:7.0];
    [visibleView4.layer setMasksToBounds:YES];
    
    // changes by anton
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;

    /*
     
    float offsetX = (screenSize.width - 110) / 2.0f;
    float offsetY = (screenSize.height - 110) / 2.0f;
    
    
    profileImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(offsetX, offsetY, 110, 110)];
 
    profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    profileImageView.clipsToBounds = YES;
    [profileImageView.layer setCornerRadius:55.0f];
    [profileImageView.layer setMasksToBounds:YES];
    
    [homeScreenView addSubview:profileImageView];
    */
    
    viewItsMatched.backgroundColor = [Helper getColorFromHexString:@"#000000" :1.0];

    /*
    waveLayer=[CALayer layer];
    
    float offsetX = (screenSize.width - 10) / 2.0f;
    float offsetY = (screenSize.height - 10) / 2.0f;

    waveLayer.frame = CGRectMake(offsetX, offsetY, 10, 10);
    
    waveLayer.borderWidth =0.2;
    waveLayer.cornerRadius =5.0;
    [homeScreenView.layer addSublayer:waveLayer];
    [waveLayer setHidden:NO];
    */
    
    originalFrameOfVW1 = visibleView1.frame;
    originalFrameOfVW2 = visibleView2.frame;
    originalFrameOfVW3 = visibleView3.frame;
    originalPositionOfvw2 = visibleView2.center;
    originalPositionOfvw3 = visibleView3.center;
    
    self.viewPercentMatch.backgroundColor=[UIColor clearColor];
    
    //[homeScreenView bringSubviewToFront:profileImageView];
    
}

-(void)showQuestionViewIfFirstTimeLaunch
{
    BOOL isQuestionShow=[[NSUserDefaults standardUserDefaults]boolForKey:@"isQuestionShow"];
    if (!isQuestionShow)
    {
        QuestionVC *vcQue=[[QuestionVC alloc]initWithNibName:@"QuestionVC" bundle:nil];
        [self presentViewController:vcQue animated:YES completion:^{
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isQuestionShow"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    }

}



-(void)addingAllViewsInSideScroller
{
    menuVC = [[MenuViewController alloc] init];
    chatVC = [[ChatViewController alloc] init];
    momentsVC = [[MomentsVC alloc]init];
    
    
    int numOfPages = 4; //Fixed by Karol 11/18/2015 [changed 3 -> 4 ]
    
    CGRect frame;
    
    scrollVwContainer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    frame = [self getRectFromPage:TagMenuVIEW];
    [menuVC.view setFrame:frame];
    [scrollVwContainer addSubview:menuVC.view];
    
    frame = [self getRectFromPage:TagChatView];
    [chatVC.view setFrame:frame];
    [scrollVwContainer addSubview:chatVC.view];
    
    frame = [self getRectFromPage:TagMomentsView];
    [momentsVC.view setFrame:frame];
    [scrollVwContainer addSubview:momentsVC.view];
    
    frame = [self getRectFromPage:TagHomeView];
    [homeScreenView setFrame:frame];
    [scrollVwContainer addSubview:homeScreenView];
    
    scrollVwContainer.contentOffset=CGPointMake([UIScreen mainScreen].bounds.size.width*2, 0);
    scrollVwContainer.contentSize = CGSizeMake(scrollVwContainer.frame.size.width * numOfPages, scrollVwContainer.frame.size.height);
    scrollVwContainer.delegate = self;
    scrollVwContainer.showsHorizontalScrollIndicator = NO;
    scrollVwContainer.showsVerticalScrollIndicator = NO;
    //scrollVwContainer.pagingEnabled = No;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    
    NSInteger page = TagHomeView;
//    CGRect frame = scrollVwContainer.frame;
//    frame.origin.x = frame.size.width * page;
//    frame.origin.y = 0;
//    lastContentOffset = frame.size.width * page;
    
    CGRect rect = [self getRectFromPage:page];
    lastContentOffset = rect.origin.x;
    
    
    [scrollVwContainer scrollRectToVisible:rect animated:YES];
    lastIndexOfPage = page;
    indexOfPageCalledWithNavigationButtons = -1;
}

-(CGRect)getRectFromPage:(NSInteger)page
{
    
    //scrollVwContainer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    CGRect frame = scrollVwContainer.frame;
    frame.origin.y = 0;
    
    if (page == TagMenuVIEW) {
        frame.origin.x  = 0;
    }
    if (page == TagHomeView) {
        frame.origin.x = frame.size.width * page - frame.size.width * 0.2f;
    }
    if (page == TagChatView) {
        frame.origin.x = frame.size.width * page - frame.size.width * 0.2f;
        frame.size.width = frame.size.width * 0.8f;
    }
    else if (page == TagMomentsView)
    {
        frame.origin.x = frame.size.width * page - frame.size.width * 0.2f;
    }
    
    return frame;
}

- (void)movedLeft:(UIGestureRecognizer*)recognizer {
    
    if (g_isSwipping) {
        return;
    }
    
    if (lastIndexOfPage == TagHomeView)
    {
        NSDictionary *dictInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:TagChatView] forKey:KeyForScreenNavigation];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_SCREEN_NAVIGATION_BUTTON_CLICKED object:nil userInfo:dictInfo];
        lastIndexOfPage = TagChatView;
        g_isSwipping = YES;
        
        NSArray *arrGestureRecognizers = self.frontCardView.gestureRecognizers;
        if (arrGestureRecognizers.count > 0)
        {
            for (UIGestureRecognizer *gesture in arrGestureRecognizers) {
                [self.frontCardView removeGestureRecognizer:gesture];
            }
            
        }
        UISwipeGestureRecognizer* swiperightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(movedRight:)];
        swiperightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self.frontCardView addGestureRecognizer:swiperightGestureRecognizer];
        
    }
    else if(lastIndexOfPage == TagMenuVIEW)
    {
        NSDictionary *dictInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:TagHomeView] forKey:KeyForScreenNavigation];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_SCREEN_NAVIGATION_BUTTON_CLICKED object:nil userInfo:dictInfo];
        lastIndexOfPage = TagHomeView;
        g_isSwipping = YES;
    }
    
}

- (void)movedRight:(UIGestureRecognizer*)recognizer
{
    if (g_isSwipping)
        return;
    
    if (lastIndexOfPage == TagHomeView)
    {
        NSDictionary *dictInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:TagMenuVIEW] forKey:KeyForScreenNavigation];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_SCREEN_NAVIGATION_BUTTON_CLICKED object:nil userInfo:dictInfo];
        lastIndexOfPage = TagMenuVIEW;
        g_isSwipping = YES;
        NSArray *arrGestureRecognizers = self.frontCardView.gestureRecognizers;
        if (arrGestureRecognizers.count > 0)
        {
            for (UIGestureRecognizer *gesture in arrGestureRecognizers) {
                [self.frontCardView removeGestureRecognizer:gesture];
            }
            
        }
        
        UISwipeGestureRecognizer* swipeleftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(movedLeft:)];
        swipeleftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.frontCardView addGestureRecognizer:swipeleftGestureRecognizer];
        
    }
    else if(lastIndexOfPage == TagChatView)
    {
        NSDictionary *dictInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:TagHomeView] forKey:KeyForScreenNavigation];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_SCREEN_NAVIGATION_BUTTON_CLICKED object:nil userInfo:dictInfo];
        lastIndexOfPage = TagHomeView;
        g_isSwipping = YES;
    }
    
    
}



#pragma mark -
#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    
    if (scrollVwContainer.contentOffset.x == 0) {
        g_isSwipping = NO;
    }

}


-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    //This is additional code to force move to screen if scrollview start automatic decelerating
    if (indexOfPageCalledWithNavigationButtons != -1)
    {
        CGPoint offset = CGPointMake(scrollVwContainer.frame.size.width * indexOfPageCalledWithNavigationButtons, 0);
        [scrollVwContainer setContentOffset:offset animated:YES];
        lastIndexOfPage = indexOfPageCalledWithNavigationButtons;
        indexOfPageCalledWithNavigationButtons = -1;
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    lastContentOffset = scrollView.contentOffset.x;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updatePager];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    indexOfPageCalledWithNavigationButtons = -1;
    if (!decelerate) {
        [self updatePager];
    }
}

- (void)updatePager
{
    int indexOfPage = floorf(scrollVwContainer.contentOffset.x / scrollVwContainer.frame.size.width);
    CGPoint offset = CGPointMake(scrollVwContainer.frame.size.width * indexOfPage , 0);
    [scrollVwContainer setContentOffset:offset animated:YES];
    
    if (lastIndexOfPage != indexOfPage)
    {
        switch (indexOfPage)
        {
            case TagMenuVIEW:
                [APPDELEGATE performSelector:@selector(callNotificationForScreenUpdates:) withObject:NOTIFICATION_MENUSCREEN_REFRESH afterDelay:0.5];
                break;
            case TagHomeView:
                [APPDELEGATE performSelector:@selector(callNotificationForScreenUpdates:) withObject:NOTIFICATION_HOMESCREEN_REFRESH afterDelay:0.5];
                break;
            case TagChatView:
                [APPDELEGATE performSelector:@selector(callNotificationForScreenUpdates:) withObject:NOTIFICATION_CHATSCREEN_REFRESH afterDelay:0.5];
                break;
            case TagMomentsView:
                [APPDELEGATE performSelector:@selector(callNotificationForScreenUpdates:) withObject:NOTIFICATION_MOMENTSCREEN_REFRESH afterDelay:0.5];
                break;
            default:
                break;
        }
    }
    lastIndexOfPage = indexOfPage;
}

#pragma mark - Notification Handler

//Notification To Navigate to other screen
-(void)navigateToNewScreenWithInfo:(NSNotification *)_notificationObj
{
    NSNumber *numPage= [[_notificationObj userInfo] valueForKey:KeyForScreenNavigation];
    int indexOfPage = [numPage intValue];
   
    NSLog(@"Page %d",indexOfPage);
    float valforAnimation = 0.0f;
   
    switch (indexOfPage)
    {
        case TagMenuVIEW:
            [APPDELEGATE performSelector:@selector(callNotificationForScreenUpdates:) withObject:NOTIFICATION_MENUSCREEN_REFRESH afterDelay:0.5];
            //valforAnimation = 0.2f;
            break;
        case TagHomeView:
            [APPDELEGATE performSelector:@selector(callNotificationForScreenUpdates:) withObject:NOTIFICATION_HOMESCREEN_REFRESH afterDelay:0.5];
            break;
        case TagChatView:
            [APPDELEGATE performSelector:@selector(callNotificationForScreenUpdates:) withObject:NOTIFICATION_CHATSCREEN_REFRESH afterDelay:0.5];
            valforAnimation = -0.2f;
            break;
        case TagMomentsView:
            [APPDELEGATE performSelector:@selector(callNotificationForScreenUpdates:) withObject:NOTIFICATION_MOMENTSCREEN_REFRESH afterDelay:0.5];
            break;
        default:
            break;
    }
    
    
    indexOfPageCalledWithNavigationButtons = indexOfPage;
    //CGPoint offset = CGPointMake(scrollVwContainer.frame.size.width * (indexOfPage + valforAnimation), 0);
    CGPoint offset = [self getRectFromPage:indexOfPage].origin;
    if (indexOfPage == 2)
    {
        offset.x -= scrollVwContainer.frame.size.width * 0.2f;
    }
    [scrollVwContainer setContentOffset:offset animated:YES];
    
    
}

//Notification To Refresh Screen
-(void)homeScreenRefresh
{
    if ([User currentUser].profile_pic!=nil)
    {
        //[profileImageView setShowActivity:YES];
        //[profileImageView setImageURL:[NSURL URLWithString:[User currentUser].profile_pic]];
        
        //[imgPhoto setImageWithURL:[NSURL URLWithString:[User currentUser].profile_pic]];
        [self showProfilePic];
    }
    
    if ([[[XmppCommunicationHandler sharedInstance]xmppStream] isConnected])
    {
        [self performSelector:@selector(sendRequestForGetMatches) withObject:nil afterDelay:1];
    }
//    [self performSelector:@selector(startAnimation) withObject:nil];
    
}

//Notification Handler
-(void)userDidLoginToXmpp
{
    [self sendRequestForGetMatches];
}

#pragma mark -
#pragma mark - requestForGetMatches

-(void)sendRequestForGetMatches
{
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    //[paramDict setObject:@"911867532218320" forKeyedSubscript:PARAM_ENT_USER_EVENTID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_FINDMATCHES withParamData:paramDict withBlock:^(id response, NSError *error)
    {
        if (response)
        {
            if ([[response objectForKey:@"errFlag"] intValue]==0)
            {
                NSArray *matches = response[@"matches"];
                if ([matches count] > 0)
                {
                    [self performSelectorOnMainThread:@selector(fetchMatchesData:) withObject:matches waitUntilDone:NO];
                    
                    // Fixed by Karol 11/18/2015 [Added] ---------------------------------------------
                    matches = [NSMutableArray arrayWithArray:[response objectForKey:@"matches"]];
                    
                    if (matches.count)
                    {
                        
                        NSMutableDictionary *dictFriend = [[NSMutableDictionary alloc] init];
                        
                        for (NSDictionary *dictObj in matches)
                        {
                            NSString *fbid = [[dictObj valueForKey:@"firstName"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            
                            if (fbid.length)
                            {
                                NSString *jid = [NSString stringWithFormat:@"%@@%@/%@",[NSString stringWithFormat:@"%@%@",XmppJidPrefix,[dictObj valueForKey:@"fbId"]],CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
                                
                                [dictFriend setObject:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,[dictObj valueForKey:@"fbId"]] forKey:@"friendName"];
                                [dictFriend setObject:jid forKey:@"friendJid"];
                                [dictFriend setObject:[NSNumber numberWithInt:0] forKey:@"messageCount"];
                                // [dictFriend setObject:@"You 're a match! Now say Hi :)" forKey:@"lastMessage"];
                                [dictFriend setObject:@"" forKey:@"lastMessageTime"];
                                [dictFriend setObject:@"Offline" forKey:@"presenceStatus"];
                                [dictFriend setObject:[dictObj valueForKey:@"firstName"] forKey:@"friendDisplayName"];
                                
                                NSString *matchedDate = [dictObj valueForKey:@"ladt"];
                                
                                if (matchedDate.length)
                                {
                                    matchedDate = [[UtilityClass sharedObject]stringFromDateString:matchedDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"MM/dd"];
                                    [dictFriend setObject:[NSString stringWithFormat:@"Matched on %@",matchedDate] forKey:@"lastMessage"];
                                }
                                else
                                {
                                    [dictFriend setObject:[NSString stringWithFormat:@"Matched Just Now"] forKey:@"lastMessage"];
                                }
                                
                                
                                NSData * imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[dictObj valueForKey:@"pPic"]]];
                                
                                if (imgData)
                                {
                                    [dictFriend setObject:imgData forKey:@"friendImage"];
                                }
                                else
                                {
                                    [dictFriend setObject:[NSData dataFromBase64String:@""] forKey:@"friendImage"];
                                }
                                
                                [dictFriend setObject:@"NO" forKey:@"isBlocked"];
                                [[XmppFriendHandler sharedInstance] insertOrUpdateFriendInfoInDatabase:dictFriend];
                            }
                        }
                    }
                    else
                    {
                        [Helper setToLabel:lblNoFriendAround Text:@"Huh?! No one...\n Try changing your settings" WithFont:SEGOUE_UI FSize:17 Color:[UIColor colorWithRed:202/255.0f green:146/255.0f blue:128/255.0f alpha:1]];
                        viewNoPhotoView.hidden = NO;
                        lblNoFriendAround = NO;
 //                       [waveLayer setHidden:YES];
                        
                    }
                    //  ---------------------------------------------
                    g_isSwipping = NO;
                    
                }else{
                    
                    [Helper setToLabel:lblNoFriendAround Text:@"Huh?! No one...\n Try changing your settings" WithFont:SEGOUE_UI FSize:17 Color:[UIColor colorWithRed:202/255.0f green:146/255.0f blue:128/255.0f alpha:1]];
                    //btnInvite.hidden = NO;
                    viewNoPhotoView.hidden = NO;
                    
                    lblNoFriendAround = NO;
//                    [waveLayer setHidden:YES];
                }
            }
            else{
                [Helper setToLabel:lblNoFriendAround Text:@"Huh?! No one...\n Try changing your settings" WithFont:SEGOUE_UI FSize:17 Color:[UIColor colorWithRed:202/255.0f green:146/255.0f blue:128/255.0f alpha:1]];
                //btnInvite.hidden = NO;
                viewNoPhotoView.hidden = NO;
                lblNoFriendAround = NO;

//                [waveLayer setHidden:YES];
                
            }
            
            g_isSwipping = NO;
            
        }else{
            [Helper setToLabel:lblNoFriendAround Text:@"Huh?! No one...\n Try changing your settings" WithFont:SEGOUE_UI FSize:17 Color:[UIColor colorWithRed:202/255.0f green:146/255.0f blue:128/255.0f alpha:1]];
            
            //btnInvite.hidden = NO;
            viewNoPhotoView.hidden = NO;
            lblNoFriendAround = NO;
//            [waveLayer setHidden:YES];
            
        }
    }];
}

-(void)fetchMatchesData:(NSArray*)matches
{
    myProfileMatches  = [[NSMutableArray alloc] initWithArray:matches];
    if(myProfileMatches.count>0)
    {
        NSMutableDictionary *dictForMutal = [myProfileMatches objectAtIndex:0];
        [TinderFBFQL executeFQlForMutualFriendForId:nil andFriendId:[dictForMutal valueForKey:@"fbId"] andDelegate:self];
        [TinderFBFQL executeFQlForMutualLikesForId:nil andFriendId:[dictForMutal valueForKey:@"fbId"] andDelegate:self];
    
        [self setupMatchesView];
        
    }
}

-(void)setupMatchesView
{
   
    self.decision.hidden = YES;
    
    
    if (self.frontCardView) {
        [self.frontCardView removeFromSuperview];
        self.frontCardView = nil;
    }
    if (self.backCardView)
    {
        [self.backCardView removeFromSuperview];
        self.frontCardView = nil;
    }
    
    if ([myProfileMatches count] > 0)
    {
        
        self.frontCardView = [self popPersonViewWithFrame:[self frontCardViewFrame]];
        [scrollVwContainer addSubview:self.frontCardView];
        
        self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]];
        [scrollVwContainer insertSubview:self.backCardView belowSubview:self.frontCardView];
        //[self constructNopeButton];
        //[self constructLikedButton];
        lblNoFriendAround.hidden = YES;
//        [waveLayer setHidden:YES];
        
        /*disable old match ImageView
        mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        mainImageView.clipsToBounds = YES;
        
        [mainImageView setShowActivity:YES];
        [mainImageView setImageURL:[NSURL URLWithString:[match valueForKey:@"pPic"]]];
        [mainImageView setBackgroundColor:[UIColor whiteColor]];
        [mainImageView setPlaceholderImage:[UIImage imageNamed:@"pfImage.png"]];

        
        [Helper setToLabel:nameLabel Text:[NSString stringWithFormat:@"%@, %@", match[@"firstName"], match[@"age"]] WithFont:HELVETICALTSTD_ROMAN FSize:16 Color: BLACK_COLOR] ;
        
        NSString *strMFC=[NSString stringWithFormat:@"%@",match[@"mutualFriendcout"]];
        NSString *strMLC=[NSString stringWithFormat:@"%@",match[@"mutualLikecount"]];
        
        [Helper setToLabel:commonFriends Text:strMFC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color:[UIColor lightGrayColor]];
        [Helper setToLabel:commonInterest Text:strMLC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: [UIColor lightGrayColor]];
        
        [Helper setToLabel:picsCount Text:[NSString stringWithFormat:@"%@", match[@"imgCnt"]] WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR] ;
        picsCount.text=match[@"images"];
        
        self.lblPercentMatch.text=[NSString stringWithFormat:@"%@%%",[match objectForKey:@"matchPercentage"]];
        
        [waveLayer setHidden:YES];
        //[profileImageView setHidden:YES];
        [viewNoPhotoView setHidden:YES];
        
        [btnInvite setHidden:YES];
        [lblNoFriendAround setHidden:YES];
        
        
        [matchesView setHidden:NO];
        [btnInvite setHidden:YES];
        
        
        originalPositionOfvw1 = visibleView1.center;
        visibleView1.hidden = NO;

    
        if ([myProfileMatches count] > 1)
        {
            visibleView2.hidden = NO;
            imgvw.contentMode = UIViewContentModeScaleAspectFill;
            imgvw.clipsToBounds = YES;
            NSDictionary *match1 = [myProfileMatches objectAtIndex:1];
            
            [imgvw setShowActivity:YES];
            [imgvw setImageURL:[NSURL URLWithString:[match1 valueForKey:@"pPic"]]];
            [imgvw setBackgroundColor:[UIColor whiteColor]];
            [imgvw setPlaceholderImage:[UIImage imageNamed:@"pfImage.png"]];
            
            [Helper setToLabel:nameLabel2 Text:[NSString stringWithFormat:@"%@, %@", match1[@"firstName"], match1[@"age"]] WithFont:HELVETICALTSTD_ROMAN FSize:16 Color: BLACK_COLOR] ;
          
            
            NSString *strMFC=[NSString stringWithFormat:@"%@",match1[@"mutualFriendcout"]];
            NSString *strMLC=[NSString stringWithFormat:@"%@",match1[@"mutualLikecount"]];
            
            [Helper setToLabel:lblMutualFriend2 Text:strMFC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: [UIColor lightGrayColor]];
            [Helper setToLabel:lblMutualLikes2 Text:strMLC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: [UIColor lightGrayColor]];
            
            [Helper setToLabel:lblNoOfImage Text:[NSString stringWithFormat:@"%@", match1[@"imgCnt"]] WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR] ;
            lblNoOfImage.text=match1[@"images"];
            
            if ([myProfileMatches count] > 2)
            {
                visibleView3.hidden = NO;
                
                if ([myProfileMatches count] > 3) {
                    visibleView4.hidden = NO;
                }
                else
                {
                    visibleView4.hidden = YES;
                }
            }
            else
            {
                visibleView3.hidden = YES;
                visibleView4.hidden = YES;
            }
        }
        else
        {
           visibleView2.hidden = YES;
           visibleView4.hidden = YES;
           visibleView3.hidden = YES;
        }
             */
    }
    else
    {
        [matchesView setHidden:YES];
        //[btnInvite setHidden:NO];
        viewNoPhotoView.hidden = NO;
//        [waveLayer setHidden:NO];
        //[profileImageView setHidden:NO];
        [viewNoPhotoView setHidden:NO];
//        [self performSelector:@selector(startAnimation) withObject:nil];
    }
         
}

-(void)imageDownloader:(NSString*)url forId:(NSString*)fbid
{
    
    NSString *tmpDir = NSTemporaryDirectory();
    
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:url]
                                                        options:0
                                                       progress:^(NSUInteger receivedSize, long long expectedSize)
     {
         // progression tracking code
     }
                                                      completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
     {
         if (image && finished)
         {
             NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
             NSString *savePath = [tmpDir stringByAppendingPathComponent:fbid];
             [data writeToFile:[savePath stringByAppendingPathExtension:@"jpg"] atomically:YES];
             [self performSelectorOnMainThread:@selector(doneDownloadingImageFor:) withObject:fbid waitUntilDone:NO];
         }
     }];
}

-(void)doneDownloadingImageFor:(NSString*)fbid
{
    static NSInteger count = 0;
    count++;
    if (count <= [myProfileMatches count])
    {
        lblNoFriendAround.hidden = YES;
        NSDictionary *match = [myProfileMatches objectAtIndex:0];
        mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        mainImageView.clipsToBounds = YES;
        
        NSString *savePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:match[@"fbId"]] stringByAppendingPathExtension:@"jpg"];
        
        mainImageView.image = [UIImage imageWithContentsOfFile:savePath];
        [Helper setToLabel:nameLabel Text:[NSString stringWithFormat:@"%@, %@", match[@"firstName"], match[@"age"]] WithFont:HELVETICALTSTD_ROMAN FSize:16 Color: BLACK_COLOR] ;
        
        NSString *strMFC=[NSString stringWithFormat:@"%@",match[@"mutualFriendcout"]];
        NSString *strMLC=[NSString stringWithFormat:@"%@",match[@"mutualLikecount"]];
        
        [Helper setToLabel:commonFriends Text:strMFC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR];
        [Helper setToLabel:commonInterest Text:strMLC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR];
        
        [Helper setToLabel:picsCount Text:[NSString stringWithFormat:@"%@", match[@"imgCnt"]] WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR] ;
        picsCount.text=match[@"images"];
        
        self.lblPercentMatch.text=[NSString stringWithFormat:@"%@%%",[match objectForKey:@"matchPercentage"]];
        
 //       [waveLayer setHidden:YES];
        //[profileImageView setHidden:YES];
        [viewNoPhotoView setHidden:YES];
        
        [btnInvite setHidden:YES];
        [lblNoFriendAround setHidden:YES];
        
        
        [matchesView setHidden:NO];
        [btnInvite setHidden:YES];
        
        
        originalPositionOfvw1 = visibleView1.center;
        visibleView1.hidden = NO;
        
        if (count >= 1 && [myProfileMatches count]>1)
        {
            visibleView2.hidden = NO;
            imgvw.contentMode = UIViewContentModeScaleAspectFill;
            imgvw.clipsToBounds = YES;
            NSDictionary *match1 = [myProfileMatches objectAtIndex:1];
            NSString *savePath1 = [[NSTemporaryDirectory() stringByAppendingPathComponent:match1[@"fbId"]] stringByAppendingPathExtension:@"jpg"];
            
            imgvw.image = [UIImage imageWithContentsOfFile:savePath1];
            
            [Helper setToLabel:nameLabel2 Text:[NSString stringWithFormat:@"%@, %@", match1[@"firstName"], match1[@"age"]] WithFont:HELVETICALTSTD_ROMAN FSize:16 Color: BLACK_COLOR] ;
            
            NSString *strMFC=[NSString stringWithFormat:@"%@",match1[@"mutualFriendcout"]];
            NSString *strMLC=[NSString stringWithFormat:@"%@",match1[@"mutualLikecount"]];
            
            [Helper setToLabel:lblMutualFriend2 Text:strMFC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR];
            [Helper setToLabel:lblMutualLikes2 Text:strMLC WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR];
            
            [Helper setToLabel:lblNoOfImage Text:[NSString stringWithFormat:@"%@", match1[@"imgCnt"]] WithFont:HELVETICALTSTD_LIGHT FSize:19 Color: WHITE_COLOR] ;
            lblNoOfImage.text=match1[@"images"];
            
        }
        else {
            visibleView2.hidden = YES;
        }
        count = 0;
    }
}

//#pragma mark -
//#pragma mark - actionForNopeAndLike
//
//-(IBAction)pan:(UIPanGestureRecognizer*)gs
//{
//    CGPoint curLoc = visibleView1.center;
//    CGPoint translation = [gs translationInView:gs.view.superview];
//    float diff = 0;
//    
//    if (gs.state == UIGestureRecognizerStateBegan)
//    {
//        xDistanceForSnapShot = visibleView1.center.x;
//        yDistanceForSnapShot = visibleView1.center.y;
//    }
//    else if (gs.state == UIGestureRecognizerStateChanged)
//    {
//        
//        if (curLoc.x < originalPositionOfvw1.x)
//        {
//            diff = originalPositionOfvw1.x - curLoc.x;
//            if (diff > 50)
//                [nope setAlpha:1];
//            else {
//                [nope setAlpha:diff/50];
//            }
//            [liked setHidden:YES];
//            [nope setHidden:NO];
//            
//        }
//        else if (curLoc.x > originalPositionOfvw1.x) {
//            diff = curLoc.x - originalPositionOfvw1.x;
//            if (diff > 50)
//                [liked setAlpha:1];
//            else {
//                [liked setAlpha:diff/50];
//            }
//            
//            [liked setHidden:NO];
//            [nope setHidden:YES];
//        }
//        
//        /*
//         gs.view.center = CGPointMake(gs.view.center.x + translation.x,
//         gs.view.center.y + translation.y);
//         [gs setTranslation:CGPointMake(0, 0) inView:self.view];
//         */
//
//        //Updated By Sanskar
//        
//        CGFloat xDistance = [gs translationInView:homeScreenView].x;
//        CGFloat yDistance = [gs translationInView:homeScreenView].y;
//
//        CGFloat rotationStrength = MIN(xDistance / screenWidth, 1);
//        CGFloat rotationAngel = - (CGFloat) (2*M_PI * rotationStrength / 8);
//        CGFloat scaleStrength = 1 - fabsf(rotationStrength) / 8;
//        CGFloat scale = MAX(scaleStrength, 0.93);
//        
//        gs.view.center = CGPointMake(xDistanceForSnapShot + xDistance, yDistanceForSnapShot + yDistance);
//        
//        CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
//        CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
//        gs.view.transform = scaleTransform;
//                
//        CGFloat tran = diff/3000;
//       
//       // NSLog(@"tran %f",tran);
//    
//        if (tran <=0.03) {
//            visibleView2.transform = CGAffineTransformMakeScale(1.0+tran,1.0);
//            visibleView3.transform = CGAffineTransformMakeScale(1.0+tran,1.0);
//        }
//        CGPoint centerForVW2 = CGPointMake(originalPositionOfvw2.x, originalPositionOfvw2.y-diff/50);
//        visibleView2.center = centerForVW2;
//        
//        CGPoint centerForVW3 = CGPointMake(originalPositionOfvw3.x, originalPositionOfvw3.y-diff/50);
//        visibleView3.center = centerForVW3;
//        
//        if (abs(diff) > 50)
//        {
//            
//        }
//    }
//    else if (gs.state == UIGestureRecognizerStateEnded)
//    {
//        if (![nope isHidden] || ![liked isHidden])
//        {
//            visibleView1.transform = CGAffineTransformIdentity;
//            
//            visibleView1.frame = originalFrameOfVW1;
//            visibleView2.frame = originalFrameOfVW2;
//            visibleView3.frame = originalFrameOfVW3;
//            
//            [nope setHidden:YES];
//            [liked setHidden:YES];
//            [visibleView1 setHidden:YES];
//            visibleView1.center = originalPositionOfvw1;
//           
//            [visibleView1 setHidden:NO];
//            diff = curLoc.x - originalPositionOfvw1.x;
//            
//            if (abs(diff) > 50) {
//                
//                UIButton *btn = nil;
//                if (diff > 0) {
//                    btn = self.nopeBtn;
//                }
//                else {
//                    btn = self.likedBtn;
//                }
//                
//                self.decision.text = @"";
//                
//                [self performSelector:@selector(likeDislikeButtonAction:) withObject:btn];
//            }
//        }
//    }
//}

-(void)updateNextProfileView
{
    self.decision.hidden = YES;
    [myProfileMatches removeObjectAtIndex:0];
    if(myProfileMatches.count>0)
    {
//        NSMutableDictionary *dictForMutal=[myProfileMatches objectAtIndex:0];
        //[TinderFBFQL executeFQlForMutualFriendForId:nil andFriendId:[dictForMutal valueForKey:@"fbId"] andDelegate:self];
        //[TinderFBFQL executeFQlForMutualLikesForId:nil andFriendId:[dictForMutal valueForKey:@"fbId"] andDelegate:self];
        
    }
    [self setupMatchesView];
}

//-(IBAction)likeDislikeButtonAction:(UIButton*)sender
//{
//    NSDictionary *profile = [myProfileMatches objectAtIndex:0];
//    
//    if ([[[XmppCommunicationHandler sharedInstance] xmppStream]isConnected])
//    {
//       
//        if (sender.tag == 300) { // Like
//            [self performSelector:@selector(sendInviteAction:) withObject:@{@"fbid": profile[@"fbId"], @"action": [NSNumber numberWithInt:1]}];
//            
//        }
//        else if (sender.tag == 200) { // Dislike
//            [self performSelector:@selector(sendInviteAction:) withObject:@{@"fbid": profile[@"fbId"], @"action": [NSNumber numberWithInt:2]}];
//        }
//        
//        if (self.decision.text.length > 0) {
//            self.decision.hidden = NO;
//            [homeScreenView bringSubviewToFront:self.decision];
//            if (sender.tag == 300) {
//                self.decision.text = @"Liked";
//                self.decision.textColor = [UIColor colorWithRed:0.001 green:0.548 blue:0.002 alpha:1.000];
//            }
//            else {
//                self.decision.text = @"Noped";
//                self.decision.textColor = [UIColor redColor];
//            }
//            [self performSelector:@selector(updateNextProfileView) withObject:nil afterDelay:0];
//        }
//        else {
//            self.decision.text = @"Liked";
//            [self performSelector:@selector(updateNextProfileView) withObject:nil afterDelay:0];
//        }
//    }
//    else
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Please Try Again!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
//        [alert show];
//    }
//
//}

-(void)loadImageForSharedFrnd :(NSArray*)arrayFrnd
{
    commonFriends.text=[NSString stringWithFormat:@"%d",(int)arrayFrnd.count];
}

-(void)loadImageForSharedIntrest:(NSArray*)arrayIntrst
{
    commonInterest.text=[NSString stringWithFormat:@"%d",(int)arrayIntrst.count];
}

-(IBAction)showUserProfile:(id)sender
{
    if ([myProfileMatches count]==0)
    {
        return;
    }
    ProfileVC *vc=[[ProfileVC alloc]initWithNibName:@"ProfileVC" bundle:nil];
    
    NSDictionary *dict=[myProfileMatches objectAtIndex:0];
    User *user=[[User alloc]init];
    user.fbid=[dict objectForKey:@"fbId"];
    user.first_name=[dict objectForKey:@"firstName"];
    user.profile_pic=[dict objectForKey:@"pPic"];
    vc.user=user;
  
    UINavigationController *navVc = [[UINavigationController alloc]initWithRootViewController:vc];
    
    [self presentViewController:navVc animated:YES completion:nil];
       
}

-(void)donePreviewing:(NSNumber*)val
{
    if ([val integerValue] == 0) {
        return;
    }
    NSDictionary *profile = [myProfileMatches objectAtIndex:0];
    [self performSelector:@selector(sendInviteAction:) withObject:@{@"fbid": profile[@"fbId"], @"action": val}];
    [self performSelector:@selector(updateNextProfileView) withObject:nil afterDelay:0];
}

-(void)fetchfbevents
{
    [[FacebookUtility sharedObject] fetchEventsWithCompletionBlock:^(id response, NSError *error)
     {
         if (!error)
         {
             if (response)
             {
                 NSArray *events = [response objectForKey:@"data"];
                 if (events.count > 0)
                 {
                     for (NSDictionary *event in events)
                     {
                         [self fetcheventDetail:[event objectForKey:@"id"]];
                     }
                 }
                 
             }
         }
     }];
    

}

-(void)fetchProfilePictures
{
    [[FacebookUtility sharedObject] fetchProfilePicturesWithCompletionBlock:^(id response, NSError *error)
     {
         if (!error)
         {
             if (response)
             {
                 NSArray *albums = [[response objectForKey:@"albums"] objectForKey:@"data"];
                 if (albums.count > 0)
                 {
                     for (NSDictionary *dict in albums)
                     {
                         if ([[dict objectForKey:@"name"] isEqualToString:@"Profile Pictures"])
                         {
                             [self fetchalbum:[dict objectForKey:@"id"]];
                         }
                     }
                 }
                 
             }
         }
     }];
    
    
}

// Parse album data from Facebook //
-(void)fetchalbum:(NSString *)albumID
{
    [[FacebookUtility sharedObject] fetchImagesWithAlbumID:albumID FBCompletionBlock:^(id response, NSError *error)
     {
         if (!error)
         {
             [self parseAlbum:response];
         }
     }];
    
}

// Parse event data from Facebook //
-(void)fetcheventDetail:(NSString *)eventID
{
    [[FacebookUtility sharedObject] fetchEventDetail:eventID FBCompletionBlock:^(id response, NSError *error)
     {
         if (!error)
         {
             [self parseEvent:response];
         }
     }];

}

// Parse album data from Facebook //
-(void)parseAlbum:(NSDictionary *)FBAlbumDetailDict
{
    
    NSArray *albums = [[FBAlbumDetailDict objectForKey:@"photos"] objectForKey:@"data"];
    int i = 0;
    for (NSDictionary *dict in albums)
    {
        if (i == 5)
        {
            break;
        }
        NSString *url = [dict objectForKey:@"picture"];
        NSURL* aURL = [NSURL URLWithString:url];
        NSData* data = [[NSData alloc] initWithContentsOfURL:aURL];
        UIImage *img = [UIImage imageWithData:data];
        [self saveImageOnServer:img];
        i++;
    }
    
}


// Parse event data from Facebook //
-(void)parseEvent:(NSDictionary*)FBEventDetailDict
{
    NSMutableDictionary *event_dic = [[NSMutableDictionary alloc] init];
    [event_dic setValue:[NSString stringWithFormat:@"%@",[FBEventDetailDict objectForKey:@"id"]] forKey:PARAM_ENT_EVENT_ID];
    [event_dic setValue:[User currentUser].fbid forKey:PARAM_ENT_MEMBER_ID];
    [event_dic setValue:[FBEventDetailDict objectForKey:@"start_time"] forKey:PARAM_ENT_EVENT_START_TIME];
    [event_dic setValue:[[[FBEventDetailDict objectForKey:@"place"] objectForKey:@"location"] objectForKey:@"country"] forKey:PARAM_ENT_EVENT_PLACE_COUNTRY];
    [event_dic setValue:[[[FBEventDetailDict objectForKey:@"place"] objectForKey:@"location"] objectForKey:@"city"] forKey:PARAM_ENT_EVENT_PLACE_CITY];
    [event_dic setValue:[[[FBEventDetailDict objectForKey:@"place"] objectForKey:@"location"] objectForKey:@"latitude"] forKey:PARAM_ENT_EVENT_PLACE_LAT];
    [event_dic setValue:[[[FBEventDetailDict objectForKey:@"place"] objectForKey:@"location"] objectForKey:@"longitude"] forKey:PARAM_ENT_EVENT_PLACE_LONG];
    [event_dic setValue:[[FBEventDetailDict objectForKey:@"place"] objectForKey:@"name"] forKey:PARAM_ENT_EVENT_PLACE_NAME];
    [event_dic setValue:@"12345" forKey:PARAM_ENT_EVENT_ATTENDING];
    [event_dic setValue:@"STREET" forKey:PARAM_ENT_EVENT_PLACE_STREET];
    [event_dic setValue:@"ZIP" forKey:PARAM_ENT_EVENT_PLACE_ZIP];
    [event_dic setValue:@"STATE" forKey:PARAM_ENT_EVENT_PLACE_STATE];
    
    [self saveEventOnServer:event_dic];
    
}

// Save Event on Server
-(void)saveEventOnServer:(NSMutableDictionary *)event
{
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_ADD_EVENT withParamData:event withBlock:^(id response, NSError *error) {
        
        if (response)
        {
            NSLog(@"Response %@",response);
        }
        [[ProgressIndicator sharedInstance] hideProgressIndicator];
        
    }];

}


// Save Image on Server
-(void)saveImageOnServer:(UIImage *)img
{
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:[NSString stringWithFormat:@"1"] forKey:PARAM_ENT_INDEX_ID];
    
    NSData *imageToUpload = UIImageJPEGRepresentation(img, 1.0);
    if (imageToUpload) {
        NSString *strImage=[Base64 encode:imageToUpload];
        if (strImage) {
            [dictParam setObject:strImage forKey:PARAM_ENT_USERIMAGE];
        }
    }
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_UPLOAD_USER_IMAGE withParamData:dictParam withBlock:^(id response, NSError *error) {
        if (response)
        {
            if ([[response objectForKey:@"errFlag"] intValue]==0) {
                NSLog(@"Image saved Successfully");
            }
        }
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
    }];
    
}

-(void)sendInviteAction:(NSDictionary*)params
{
    if ([[[XmppCommunicationHandler sharedInstance] xmppStream] isConnected])
    {
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
        [paramDict setObject:params[@"fbid"]  forKey:PARAM_ENT_INVITEE_FBID];
        [paramDict setObject:flStrForObj(params[@"action"])  forKey:PARAM_ENT_USER_ACTION];
        [paramDict setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
        WebServiceHandler *handler = [[WebServiceHandler alloc] init];
        handler.requestType = eParseKey;
        NSMutableURLRequest * request = [Service parseInviteAction:paramDict];
        [handler placeWebserviceRequestWithString:request Target:self Selector:@selector(inviteActionResponse:)];
        [[XmppCommunicationHandler sharedInstance] SendFriendRequestWithFriendName:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,params[@"fbid"]]];
        
    }
   else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Karmic" message:@"Please Try Again!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)inviteActionResponse:(NSDictionary*)response
{
    NSDictionary * dict = [response objectForKey:@"ItemsList"];
    if ([[dict objectForKey:@"errFlag"]integerValue] ==0 &&[[dict objectForKey:@"errNum"]integerValue] == 55)
    {
        viewItsMatched.hidden = NO;
        [[UserDefaultHelper sharedObject]setItsMatch:[NSMutableDictionary dictionaryWithDictionary:dict]];
        [homeScreenView bringSubviewToFront:viewItsMatched];
        [Helper setToLabel:lblItsMatchedSubText Text:[NSString stringWithFormat:@"You and %@ have liked each other.",dict[@"uName"]] WithFont:HELVETICALTSTD_LIGHT FSize:14 Color:[UIColor whiteColor]];
        lblItsMatchedSubText.textAlignment= NSTextAlignmentCenter;
        RoundedImageView *userImg  = [[RoundedImageView alloc] initWithFrame:CGRectMake(45, 125, 110, 110)];
        [userImg downloadFromURL:[User currentUser].profile_pic withPlaceholder:nil];
        RoundedImageView *FriendImg  = [[RoundedImageView alloc] initWithFrame:CGRectMake(155+20, 125, 110, 110)];
        UIActivityIndicatorView *activityIndicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(50/2-20/2, 46/2-20/2, 20, 20)];
        [FriendImg addSubview:activityIndicator];
        activityIndicator.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
        [activityIndicator startAnimating];
        FriendImg.image =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[Helper removeWhiteSpaceFromURL:dict[@"pPic"]]]]];
        [activityIndicator stopAnimating];
        [viewItsMatched addSubview:userImg];
        [viewItsMatched addSubview:FriendImg];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        if ([[[XmppCommunicationHandler sharedInstance] xmppStream]isConnected])
        {
            [[XmppCommunicationHandler sharedInstance] acceptFriendRequestWithFriendName:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dict[@"uFbId"]] friendDisplayName:dict[@"uName"] friendImageUrl:dict[@"pPic"]];
            [[XmppCommunicationHandler sharedInstance]setCurrentFriendName:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dict[@"uFbId"]]];
        }
        
        NSMutableDictionary *dictFriend = [[NSMutableDictionary alloc] init];
        NSString *jid = [NSString stringWithFormat:@"%@@%@/%@",[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dict[@"uFbId"]],CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
        [dictFriend setObject:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dict[@"uFbId"]] forKey:@"friendName"];
        [dictFriend setObject:jid forKey:@"friendJid"];
        [dictFriend setObject:[NSNumber numberWithInt:0] forKey:@"messageCount"];
        [dictFriend setObject:@"You 're a match! Now say Hi :)" forKey:@"lastMessage"];
        [dictFriend setObject:@"" forKey:@"lastMessageTime"];
        [dictFriend setObject:@"Offline" forKey:@"presenceStatus"];
        [dictFriend setObject:dict[@"uName"] forKey:@"friendDisplayName"];
        [dictFriend setObject:@"NO" forKey:@"isBlocked"];
        NSString *matchedDate = [dict valueForKey:@"ladt"];
        if (matchedDate.length)
        {
            matchedDate = [[UtilityClass sharedObject]stringFromDateString:matchedDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"MM/dd"];
            [dictFriend setObject:[NSString stringWithFormat:@"Matched on %@",matchedDate] forKey:@"lastMessage"];
        }
        else
        {
            [dictFriend setObject:[NSString stringWithFormat:@"Matched Just Now"] forKey:@"lastMessage"];
        }

        
        NSData * imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dict[@"pPic"]]];
        
        if (imgData)
        {
            [dictFriend setObject:imgData forKey:@"friendImage"];
        }
        else
        {
            [dictFriend setObject:[NSData dataFromBase64String:@""] forKey:@"friendImage"];
        }
        
        [[XmppFriendHandler sharedInstance] insertOrUpdateFriendInfoInDatabase:dictFriend];
        
        [[XmppCommunicationHandler sharedInstance] setCurrentFriendName:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dict[@"uFbId"]]];

    }
    else
    {
//        viewItsMatched.hidden = YES;
//        lblNoFriendAround.hidden = YES;
//        
//        [Helper setToLabel:lblNoFriendAround Text:@"Huh?! No one...\n Try changing your settings" WithFont:SEGOUE_UI FSize:17 Color:[UIColor colorWithRed:202/255.0f green:146/255.0f blue:128/255.0f alpha:1]];
//        btnInvite.hidden = YES;
        
    }
    
   /* if (visibleView1.hidden == YES) {
        [Helper setToLabel:lblNoFriendAround Text:@"Huh?! No one... Try changing your settings" WithFont:SEGOUE_UI FSize:17 Color:[UIColor colorWithRed:202/255.0f green:146/255.0f blue:128/255.0f alpha:1]];
        btnInvite.hidden = NO;
        lblNoFriendAround .hidden= NO;
        visibleView2.hidden = NO;
    }
    */
    
//    if (matchesView.hidden == YES) {
//        [Helper setToLabel:lblNoFriendAround Text:@"Huh?! No one...\n Try changing your settings" WithFont:SEGOUE_UI FSize:17 Color:[UIColor colorWithRed:202/255.0f green:146/255.0f blue:128/255.0f alpha:1]];
//        //btnInvite.hidden = NO;
//        viewNoPhotoView.hidden = NO;
//        lblNoFriendAround .hidden= NO;
//        
//        
//        
//    }
}

-(void)getLocation
{
    [[LocationHelper sharedObject]startLocationUpdatingWithBlock:^(CLLocation *newLocation, CLLocation *oldLocation, NSError *error) {
        if (!error) {
            [[LocationHelper sharedObject]stopLocationUpdating];
            [super updateLocation];
        }
    }];
    
}

-(IBAction)btnActionForItsMatchedView :(id)sender
{
    
    UIButton * btn =(UIButton*)sender;
    if (btn.tag ==100) {
        viewItsMatched.hidden = YES;
    }
    else
    {
        NSMutableDictionary * dictMatch=[[UserDefaultHelper sharedObject] itsMatch];
        
        //Adding Friend to Db
        NSMutableDictionary *dictFriend = [[NSMutableDictionary alloc] init];
        
        NSString *jid = [NSString stringWithFormat:@"%@@%@/%@",[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dictMatch[@"uFbId"]],CHAT_SERVER_ADDRESS,CHAT_SERVER_ADDRESS];
        
        [dictFriend setObject:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dictMatch[@"uFbId"]] forKey:@"friendName"];
        [dictFriend setObject:jid forKey:@"friendJid"];
        [dictFriend setObject:[NSNumber numberWithInt:0] forKey:@"messageCount"];
        [dictFriend setObject:@"You 're a match! Now say Hi :)" forKey:@"lastMessage"];
        [dictFriend setObject:@"" forKey:@"lastMessageTime"];
        [dictFriend setObject:@"Offline" forKey:@"presenceStatus"];
        [dictFriend setObject:dictMatch[@"uName"] forKey:@"friendDisplayName"];
        [dictFriend setObject:@"NO" forKey:@"isBlocked"];
       
        NSString *matchedDate = [dictMatch valueForKey:@"ladt"];
        
        if (matchedDate.length)
        {
            matchedDate = [[UtilityClass sharedObject]stringFromDateString:matchedDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"MM/dd"];
            [dictFriend setObject:[NSString stringWithFormat:@"Matched on %@",matchedDate] forKey:@"lastMessage"];
        }
        else
        {
            [dictFriend setObject:[NSString stringWithFormat:@"Matched Just Now"] forKey:@"lastMessage"];
        }
        
        NSData * imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dictMatch[@"pPic"]]];
        
        if (imgData)
        {
            [dictFriend setObject:imgData forKey:@"friendImage"];
        }
        else
        {
            [dictFriend setObject:[NSData dataFromBase64String:@""] forKey:@"friendImage"];
        }
        
        [[XmppFriendHandler sharedInstance] insertOrUpdateFriendInfoInDatabase:dictFriend];
        
        [self performSelectorOnMainThread:@selector(pushToChatViewController:) withObject:dictMatch waitUntilDone:YES];
    }
}

-(void)pushToChatViewController :(NSDictionary *)dict
{
    JSDemoViewController *vc = [[JSDemoViewController alloc] init];
    XmppFriend *xmppFriend = [[XmppFriendHandler sharedInstance]getXmppFriendWithName:[NSString stringWithFormat:@"%@%@",XmppJidPrefix,dict[@"uFbId"]]];
    vc.currentChatObj = xmppFriend;
    [[XmppCommunicationHandler sharedInstance]setCurrentFriendName:xmppFriend.friend_Name];

    [self.navigationController pushViewController:vc animated:YES];
    
}


#pragma mark -
#pragma mark - Animation Methods

/*
-(void)startAnimation
{
//    if ([waveLayer isHidden] || ![homeScreenView window] || inAnimation == YES)
//    {
//        return;
//    }
//    inAnimation = YES;
    //[self waveAnimation:waveLayer];
}
*/
-(void)waveAnimation:(CALayer*)aLayer
{
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.duration = 3;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transformAnimation.removedOnCompletion = YES;
    transformAnimation.fillMode = kCAFillModeRemoved;
    [aLayer setTransform:CATransform3DMakeScale( 10, 10, 1.0)];
    [transformAnimation setDelegate:self];
    
    CATransform3D xform = CATransform3DIdentity;
   // xform = CATransform3DScale(xform, 40, 40, 1.0);
    xform = CATransform3DScale(xform, 32, 32, 1.0);
    transformAnimation.toValue = [NSValue valueWithCATransform3D:xform];
    [aLayer addAnimation:transformAnimation forKey:@"transformAnimation"];
    
    
    UIColor *fromColor = [UIColor colorWithRed:255 green:120 blue:0 alpha:1];
    UIColor *toColor = [UIColor colorWithRed:255 green:120 blue:0 alpha:0.1];
    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    colorAnimation.duration = 3;
    colorAnimation.fromValue = (id)fromColor.CGColor;
    colorAnimation.toValue = (id)toColor.CGColor;
    
    [aLayer addAnimation:colorAnimation forKey:@"colorAnimationBG"];
    
    
    UIColor *fromColor1 = [UIColor colorWithRed:0 green:255 blue:0 alpha:1];
    UIColor *toColor1 = [UIColor colorWithRed:0 green:255 blue:0 alpha:0.1];
    CABasicAnimation *colorAnimation1 = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    colorAnimation1.duration = 3;
    colorAnimation1.fromValue = (id)fromColor1.CGColor;
    colorAnimation1.toValue = (id)toColor1.CGColor;
    
    [aLayer addAnimation:colorAnimation1 forKey:@"colorAnimation"];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
   
 //   [self performSelectorInBackground:@selector(startAnimation) withObject:nil];
}

#pragma mark -
#pragma mark - Mail Methods

-(IBAction)openMail :(id)sender
{
    [super sendMailSubject:@"Krown" toRecipents:[NSArray arrayWithObject:@""] withMessage:@"I am using a new dating app called Krown ! Why don't you try it out?<br/>Install Krown now !<br/><b>Google Play :-</b> <a href=''></a><br/><b></b>"];
}

#pragma mark -
#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 400) { //connection timeout error
        
    }
}

- (IBAction)btnSettingTapped:(id)sender
{
    if (g_isSwipping)
        return;
    
    NSDictionary *dictInfo = nil;
    
    if (lastIndexOfPage == TagHomeView) {
        dictInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:TagMenuVIEW] forKey:KeyForScreenNavigation];
        lastIndexOfPage = TagMenuVIEW;
        g_isSwipping = YES;
        
        NSArray *arrGestureRecognizers = self.frontCardView.gestureRecognizers;
        if (arrGestureRecognizers.count > 0)
        {
            for (UIGestureRecognizer *gesture in arrGestureRecognizers) {
                [self.frontCardView removeGestureRecognizer:gesture];
            }
            
        }
        UISwipeGestureRecognizer* swipeleftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(movedLeft:)];
        swipeleftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.frontCardView addGestureRecognizer:swipeleftGestureRecognizer];
    }
    else if (lastIndexOfPage == TagMenuVIEW)
    {
        dictInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:TagHomeView] forKey:KeyForScreenNavigation];
        lastIndexOfPage = TagHomeView;
        g_isSwipping = YES;
    }
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_SCREEN_NAVIGATION_BUTTON_CLICKED object:nil userInfo:dictInfo];
}

- (IBAction)btnChattingTapped:(id)sender
{
    if (g_isSwipping)
        return;
    g_isSwipping = YES;
    NSDictionary *dictInfo = nil;
    
    if (lastIndexOfPage == TagHomeView)
    {
        dictInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:TagChatView] forKey:KeyForScreenNavigation];
        lastIndexOfPage = TagChatView;
        
        NSArray *arrGestureRecognizers = self.frontCardView.gestureRecognizers;
        if (arrGestureRecognizers.count > 0)
        {
            for (UIGestureRecognizer *gesture in arrGestureRecognizers) {
                [self.frontCardView removeGestureRecognizer:gesture];
            }
            
        }
        UISwipeGestureRecognizer* swiperightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(movedRight:)];
        swiperightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self.frontCardView addGestureRecognizer:swiperightGestureRecognizer];
        
    }
    else if (lastIndexOfPage == TagChatView)
    {
        dictInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:TagHomeView] forKey:KeyForScreenNavigation];
        lastIndexOfPage = TagHomeView;
    }
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_SCREEN_NAVIGATION_BUTTON_CLICKED object:nil userInfo:dictInfo];
}


#pragma mark -
#pragma mark - Memory Mgmt
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// Add by Boris
#pragma mark - MDCSwipeToChooseDelegate Protocol Methods

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view
{
    NSLog(@"FDSADFSA");
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    
    if (direction == MDCSwipeDirectionLeft)
    {
        [self likeDislikeAction:2 profile:self.frontCardView.user];
    }
    else
    {
        [self likeDislikeAction:1 profile:self.frontCardView.user];
    }
    
    // switch card
    self.frontCardView = self.backCardView;
    //
    if ((self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]])) {
        // Fade the back card into view.
        self.backCardView.alpha = 0.f;
        [scrollVwContainer insertSubview:self.backCardView belowSubview:self.frontCardView];
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backCardView.alpha = 1.f;
                         } completion:nil];
    }
}

- (void)setFrontCardView:(UserLikeView *)frontCardView {
    // Keep track of the person currently being chosen.
    // Quick and dirty, just for the purposes of this sample app.
    _frontCardView = frontCardView;
    self.currentPerson = frontCardView.user;
}


- (UserLikeView *)popPersonViewWithFrame:(CGRect)frame {
    if ([myProfileMatches count] == 0) {
        return nil;
    }
    
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 160.f;
    options.onPan = ^(MDCPanState *state){
        CGRect frame = [self backCardViewFrame];
        self.backCardView.frame = CGRectMake(frame.origin.x,
                                             frame.origin.y,
                                             CGRectGetWidth(frame),
                                             CGRectGetHeight(frame));
    };
    
    // Create a personView with the top person in the people array, then pop
    // that person off the stack.
    UserLikeView *personView = [[UserLikeView alloc] initWithFrame:frame
                                                                    user:myProfileMatches[0]
                                                                   options:options];
    [personView.likebutton addTarget:self action:@selector(likeFrontCardView)
                                  forControlEvents:UIControlEventTouchUpInside];
    [personView.dislikebutton addTarget:self action:@selector(nopeFrontCardView)
                    forControlEvents:UIControlEventTouchUpInside];
    
    
    [myProfileMatches removeObjectAtIndex:0];
    return personView;
}

#pragma mark - View Contruction

- (CGRect)frontCardViewFrame {
    CGFloat horizontalPadding = 20.0f;
    CGFloat topPadding = 70.f;
    CGFloat bottomPadding = 20.0f;
    return CGRectMake(homeScreenView.frame.origin.x+horizontalPadding,
                      topPadding,
                      CGRectGetWidth(homeScreenView.frame) - (horizontalPadding * 2),
                      CGRectGetHeight(homeScreenView.frame) - topPadding - bottomPadding);
}

- (CGRect)backCardViewFrame {
    CGRect frontFrame = [self frontCardViewFrame];
    return CGRectMake(frontFrame.origin.x,
                      frontFrame.origin.y,
                      CGRectGetWidth(frontFrame),
                      CGRectGetHeight(frontFrame));
}

// Create and add the "nope" button.
- (void)constructNopeButton {
    self.btnNope= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"DeclineGrey"];
    self.btnNope.frame = CGRectMake(homeScreenView.frame.origin.x + UserLikeButtonHorizontalPadding,
                              CGRectGetMaxY(self.backCardView.frame) - UserLikeButtonVerticalPadding,
                              UserlikeButtonSize,
                              UserlikeButtonSize);
    [self.btnNope setBackgroundImage:image forState:UIControlStateNormal];
    UIImage *image_pressed = [UIImage imageNamed:@"DeclineRed"];
    [self.btnNope setBackgroundImage:image_pressed forState:UIControlStateHighlighted];
    [self.btnNope addTarget:self
               action:@selector(nopeFrontCardView)
     forControlEvents:UIControlEventTouchUpInside];
    //[scrollVwContainer addSubview:self.btnNope];
}

// Create and add the "like" button.
- (void)constructLikedButton {
    self.btnLiked = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"AcceptGrey"];
    self.btnLiked.frame = CGRectMake(CGRectGetMaxX(homeScreenView.frame) - UserlikeButtonSize - UserLikeButtonHorizontalPadding,
                              CGRectGetMaxY(self.backCardView.frame) - UserLikeButtonVerticalPadding,
                              UserlikeButtonSize,
                              UserlikeButtonSize);
    
    
    UIImage *image_pressed = [UIImage imageNamed:@"AcceptGreen"];
    [self.btnLiked setBackgroundImage:image forState:UIControlStateNormal];
    [self.btnLiked setBackgroundImage:image_pressed forState:UIControlStateHighlighted];
    [self.btnLiked addTarget:self
               action:@selector(likeFrontCardView)
     forControlEvents:UIControlEventTouchUpInside];
    //[scrollVwContainer addSubview:self.btnLiked];
}

#pragma mark - Control Events

// Programmatically "nopes" the front card view.
- (void)nopeFrontCardView {
    [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
    //[self likeDislikeAction:2 profile:self.frontCardView.user];
}


- (void)updateUserLikeView {
    [self.frontCardView setFrame:[self frontCardViewFrame]];
    [self.backCardView setFrame:[self backCardViewFrame]];
}


// Programmatically "likes" the front card view.
- (void)likeFrontCardView
{
    [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
    //[self likeDislikeAction:1 profile:self.frontCardView.user];
    
}




-(void)likeDislikeAction:(int)mode profile:(NSDictionary *)profileData{
    
    NSDictionary *profile = profileData;
    if ([[[XmppCommunicationHandler sharedInstance] xmppStream]isConnected]) {

        if (mode == 1) { // Like
            [self performSelector:@selector(sendInviteAction:) withObject:@{@"fbid": profile[@"fbId"], @"action":[NSNumber numberWithInt:1]}];

        } else if (mode == 2) { // Dislike
            [self performSelector:@selector(sendInviteAction:) withObject:@{@"fbid": profile[@"fbId"], @"action":[NSNumber numberWithInt:2]}];
        }

        if (self.decision.text.length > 0) {
            self.decision.hidden = NO;
            [homeScreenView bringSubviewToFront:self.decision];
            if (mode == 1) {
                self.decision.text = @"Liked";
                self.decision.textColor = [UIColor colorWithRed:0.001 green:0.548 blue:0.002 alpha:1.000];
            } else {
                self.decision.text = @"Noped";
                self.decision.textColor = [UIColor redColor];
            }
            //[self performSelector:@selector(updateNextProfileView) withObject:nil afterDelay:0];
        } else {
            self.decision.text = @"Liked";
            //[self performSelector:@selector(updateNextProfileView) withObject:nil afterDelay:0];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Please Try Again!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
    }

}
@end
