//
//  UserLikeScreen.h
//  Krown
//
//  Created by Boris on 11/12/15.
//  Copyright © 2015 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDCSwipeToChoose.h"
#import "Helper.h"

@interface UserLikeView : MDCSwipeToChooseView
@property (nonatomic, strong, readonly) NSDictionary *user;
- (instancetype)initWithFrame:(CGRect)frame
                       user:(NSDictionary *)user
                      options:(MDCSwipeToChooseViewOptions *)options;
@end
