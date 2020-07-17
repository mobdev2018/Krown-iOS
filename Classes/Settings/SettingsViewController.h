//
//  SettingsViewController.h
//  Tinder
//
//  Created by Rahul Sharma on 30/11/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "BaseVC.h"
#import "TinderAppDelegate.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@class RangeSlider;
@class TinderAppDelegate;
@interface SettingsViewController : BaseVC<MFMailComposeViewControllerDelegate,UIActionSheetDelegate>
{
    
    IBOutlet UIView * viewBG;
    IBOutlet UIButton *btnDone;
  
    IBOutlet  UISlider *sliderDistance;
    RangeSlider *slider;
    UILabel *reportLabel;
    
    IBOutlet UIView *viewAge;
    IBOutlet UILabel *lblAgeMin;


 
    TinderAppDelegate * appDelagte;
    IBOutlet UIScrollView * scrollview;
    
    
 
    int Intested_in;
  
    int sex;
   
}
@property (strong, nonatomic) IBOutlet UISwitch *switchDiscovery;
@property (strong, nonatomic) IBOutlet UISwitch *switchMen;
@property (strong, nonatomic) IBOutlet UISwitch *switchWomen;

- (IBAction)discovrySwitched:(UISwitch *)sender;
- (IBAction)menSwitched:(id)sender;
- (IBAction)womenSwitched:(id)sender;

 @property (weak, nonatomic) IBOutlet UILabel *lblDistance;
-(IBAction)sliderChange:(UISlider*)sender;

-(void)saveUpdatedValue;

@end
