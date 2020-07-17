//
//  HomeViewController.h
//  Tinder
//
//  Created by Sanskar on 26/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "BaseVC.h"


#import "TinderFBFQL.h"
#import "EGOImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "RoundedImageView.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "ChatViewController.h"
#import "UIImageView+Download.h"
#import "QuestionVC.h"
#import "ProfileVC.h"
#import "MomentsVC.h"
#import "MenuViewController.h"
#import "UserLikeView.h"

extern BOOL g_isSwipping;

@class MenuViewController,MomentsVC,ChatViewController;
@interface HomeViewController : BaseVC< TinderFBFQLDelegate,UIScrollViewDelegate,MDCSwipeToChooseDelegate>
{
    
    IBOutlet UIButton *btnInvite;
    IBOutlet UIView *viewItsMatched;
    IBOutlet UILabel *lblItsMatchedSubText;
    IBOutlet UILabel *lblNoFriendAround;

    IBOutlet UIView *viewNoPhotoView;
    IBOutlet UIImageView *imgPhoto;
    
    IBOutlet UIView *homeScreenView;
    IBOutlet UIScrollView *scrollVwContainer;
   
   
    ChatViewController *chatVC;
    MomentsVC *momentsVC;
    MenuViewController *menuVC;
    
    
}
@property (nonatomic, strong) NSDictionary *currentPerson;
@property (nonatomic, strong) UserLikeView *frontCardView;
@property (nonatomic, strong) UserLikeView *backCardView;


@property(nonatomic,strong)IBOutlet UIView *viewPercentMatch;
@property(nonatomic,strong)IBOutlet UILabel *lblPercentMatch;

-(IBAction)openMail :(id)sender;
-(IBAction)btnActionForItsMatchedView :(id)sender;

- (IBAction)btnChattingTapped:(id)sender;
@end
