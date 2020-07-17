//
//  MenuViewController.h
//  Tinder
//
//  Created by Sanskar on 26/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "BaseVC.h"

#import "SettingsViewController.h"
#import "AppSettingsViewController.h"
#import "Helper.h"
#import "HomeViewController.h"
#import "UIImageView+Download.h"
#import "QuestionVC.h"
#import "ProfileVC.h"
#import <AVFoundation/AVFoundation.h>

@interface MenuViewController : BaseVC<UIActionSheetDelegate,UIScrollViewDelegate>
{
    
}
-(IBAction)btnAction:(id)sender;
@property (assign, nonatomic) BOOL BackBool;

@end

@interface UIImage (Blur)
-(UIImage *)boxblurImageWithBlur:(CGFloat)blur;
@end