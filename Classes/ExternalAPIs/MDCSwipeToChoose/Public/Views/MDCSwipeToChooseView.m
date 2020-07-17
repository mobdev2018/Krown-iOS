//
// MDCSwipeToChooseView.m
//
// Copyright (c) 2014 to present, Brian Gesiak @modocache
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "MDCSwipeToChooseView.h"
#import "MDCSwipeToChoose.h"
#import "MDCGeometry.h"
#import "UIView+MDCBorderedLabel.h"
#import "UIColor+MDCRGB8Bit.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const MDCSwipeToChooseViewHorizontalPadding = 10.f;
static CGFloat const MDCSwipeToChooseViewTopPadding = 20.f;
static CGFloat const MDCSwipeToChooseViewImageTopPadding = 100.f;
static CGFloat const MDCSwipeToChooseViewLabelWidth = 65.f;

@interface MDCSwipeToChooseView ()
@property (nonatomic, strong) MDCSwipeToChooseViewOptions *options;
@end

@implementation MDCSwipeToChooseView

#pragma mark - Object Lifecycle

- (instancetype)initWithFrame:(CGRect)frame options:(MDCSwipeToChooseViewOptions *)options {
    self = [super initWithFrame:frame];
    if (self) {
        _options = options ? options : [MDCSwipeToChooseViewOptions new];
        [self setupView];
        [self constructImageView];
        [self constructBlurView];
        [self constructUserInfoView];
        [self constructLikedView];
        [self constructNopeView];
        [self setupButtons];
        [self setupSwipeToChoose];
        [self addFacebookView:frame];
    }
    return self;
}

#pragma mark - Internal Methods

- (void)setupView {
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 14.0f;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 3.0f;
    self.layer.borderColor = [UIColor colorWith8BitRed:139.f
                                                 green:144.f
                                                  blue:150.f
                                                 alpha:1.f].CGColor;
}

- (void)constructImageView {
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    
    [self addSubview:_imageView];
}

- (void)constructUserInfoView {
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.frame = CGRectMake(20, self.bounds.size.height-70, 200, 40);
    [self addSubview:_nameLabel];
}

- (void)constructBlurView {
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.visualEffectView.frame = CGRectMake(0, self.bounds.size.height-90, self.bounds.size.width, 90);
    [self addSubview:self.visualEffectView];
}

- (void)constructLikedView {
    CGFloat yOrigin = (self.options.likedImage ? MDCSwipeToChooseViewImageTopPadding : MDCSwipeToChooseViewTopPadding);

    CGRect frame = CGRectMake(MDCSwipeToChooseViewHorizontalPadding,
                              yOrigin,
                              CGRectGetMidX(self.imageView.bounds),
                              MDCSwipeToChooseViewLabelWidth);
    if (self.options.likedImage) {
        self.likedView = [[UIImageView alloc] initWithImage:self.options.likedImage];
        self.likedView.frame = frame;
        self.likedView.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        self.likedView = [[UIView alloc] initWithFrame:frame];
//        [self.likedView constructBorderedLabelWithText:self.options.likedText
//                                                 color:self.options.likedColor
//                                                 angle:self.options.likedRotationAngle];
    }
    self.likedView.alpha = 0.f;
    [self.imageView addSubview:self.likedView];
}

- (void)constructNopeView {
    CGFloat width = CGRectGetMidX(self.imageView.bounds);
    CGFloat xOrigin = CGRectGetMaxX(self.imageView.bounds) - width - MDCSwipeToChooseViewHorizontalPadding;
    CGFloat yOrigin = (self.options.nopeImage ? MDCSwipeToChooseViewImageTopPadding : MDCSwipeToChooseViewTopPadding);
    CGRect frame = CGRectMake(xOrigin,
                              yOrigin,
                              width,
                              MDCSwipeToChooseViewLabelWidth);
    if (self.options.nopeImage) {
        self.nopeView = [[UIImageView alloc] initWithImage:self.options.nopeImage];
        self.nopeView.frame = frame;
        self.nopeView.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        self.nopeView = [[UIView alloc] initWithFrame:frame];
//        [self.nopeView constructBorderedLabelWithText:self.options.nopeText
//                                                color:self.options.nopeColor
//                                                angle:self.options.nopeRotationAngle];
    }
    self.nopeView.alpha = 0.f;
    [self.imageView addSubview:self.nopeView];
}

- (void)setupButtons
{
    _likebutton = [[UIButton alloc] init];
    [_likebutton setFrame:CGRectMake(CGRectGetMidX(self.imageView.bounds) + 10 , self.bounds.size.height-160, 70.0f , 70.0f )];
    [_likebutton setBackgroundImage:[UIImage imageNamed:@"AcceptGrey"] forState:UIControlStateNormal];
    [_likebutton setBackgroundImage:[UIImage imageNamed:@"AcceptGreen"] forState:UIControlStateSelected];
    [self addSubview:_likebutton];
    
    _dislikebutton = [[UIButton alloc] init];
    [_dislikebutton setFrame:CGRectMake(CGRectGetMidX(self.imageView.bounds) - 80, self.bounds.size.height-160, 70.0f , 70.0f )];
    [_dislikebutton setBackgroundImage:[UIImage imageNamed:@"DeclineGrey"] forState:UIControlStateNormal];
    [_dislikebutton setBackgroundImage:[UIImage imageNamed:@"DeclineRed"] forState:UIControlStateSelected];
    [self addSubview:_dislikebutton];

}
- (void)setupSwipeToChoose {
    MDCSwipeOptions *options = [MDCSwipeOptions new];
    options.delegate = self.options.delegate;
    options.threshold = self.options.threshold;

    __block UIView *likedImageView = self.likedView;
    __block UIView *nopeImageView = self.nopeView;
    __block UIButton *likeButton = self.likebutton;
    __block UIButton *dislikeButton = self.dislikebutton;
    
    __weak MDCSwipeToChooseView *weakself = self;
    options.onPan = ^(MDCPanState *state) {
        if (state.direction == MDCSwipeDirectionNone) {
            likedImageView.alpha = 0.f;
            nopeImageView.alpha = 0.f;
            dislikeButton.selected = NO;
            likeButton.selected = NO;
        } else if (state.direction == MDCSwipeDirectionLeft) {
            likedImageView.alpha = 0.f;
            nopeImageView.alpha = state.thresholdRatio;
            dislikeButton.selected = YES;
            likeButton.selected = NO;
        } else if (state.direction == MDCSwipeDirectionRight) {
            likedImageView.alpha = state.thresholdRatio;
            nopeImageView.alpha = 0.f;
            likeButton.selected = YES;
            dislikeButton.selected = NO;
        }

        if (weakself.options.onPan) {
            weakself.options.onPan(state);
        }
    };

    [self mdc_swipeToChooseSetup:options];
}

-(void)addFacebookView:(CGRect)frame
{
    CGRect rect = frame;
    
    float margin = 3.5f;
    
    // background
    rect.origin = CGPointMake(margin, margin);
    rect.size.width -= margin * 2;
    rect.size.height = rect.size.width * 80.0f/ 675.0f;
    
    UIImageView *imgBg = [[UIImageView alloc] initWithFrame:rect];
    imgBg.image = [UIImage imageNamed:@"FacebookInfoHolder"];
    [self addSubview:imgBg];
    
    // facebook icon
    rect.origin = CGPointMake(margin + 8, margin + 6.0f);
    float height = rect.size.height - 12.0f;
    rect.size = CGSizeMake(height, height);
    
    UIImageView *imgFacebookIcon = [[UIImageView alloc] initWithFrame:rect];
    imgFacebookIcon.image = [UIImage imageNamed:@"facebook"];
    [self addSubview:imgFacebookIcon];
    
    // facebook event label
    rect.origin.x = rect.origin.x + rect.size.width + 4;
    rect.origin.y = margin + 6.0f;
    rect.size.width = frame.size.width - rect.origin.x - margin - 8;
    
    _facebookLabel = [[UILabel alloc] initWithFrame:rect];
    _facebookLabel.text = @"Attending The Great Gatsby Party + 3";
    [_facebookLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [self addSubview:_facebookLabel];
    
    
}

@end
