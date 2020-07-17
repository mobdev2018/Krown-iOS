//
//  UserLikeScreen.m
//  Krown
//
//  Created by Boris on 11/12/15.
//  Copyright © 2015 AppDupe. All rights reserved.
//

#import "UserLikeView.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "UIImageView+Download.h"

@interface UserLikeView ()
@property (nonatomic, strong) UIView *informationView;
@end
@implementation UserLikeView
#pragma mark - Object Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
                       user:(NSDictionary *)user
                      options:(MDCSwipeToChooseViewOptions *)options {
    self = [super initWithFrame:frame options:options];
    if (self) {
        _user = user;
        
        //[self.imageView setImageWithURL:[NSURL URLWithString:[user valueForKey:@"pPic"]]];
        NSString *strSex = [user valueForKey:@"sex"];
        NSString *placeholderImageName = @"man.jpg";
        if ([strSex isEqual:@"2"])
        {
            placeholderImageName = @"woman.jpg";
        }
        UIImage *imgPlaceholder = [UIImage imageNamed:placeholderImageName];
        [self.imageView setImageWithURL:[NSURL URLWithString:[user valueForKey:@"pPic"]] placeholderImage:imgPlaceholder];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleBottomMargin;
        self.imageView.autoresizingMask = self.autoresizingMask;
        [Helper setToLabel:self.nameLabel Text:[NSString stringWithFormat:@"%@, %@", _user[@"firstName"], _user[@"age"]] WithFont:HELVETICALTSTD_ROMAN FSize:20 Color: BLACK_COLOR] ;
    }
    return self;
}

@end
