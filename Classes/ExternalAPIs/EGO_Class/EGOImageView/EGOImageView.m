//
//  EGOImageView.m
//  EGOImageLoading
//
//  Created by Shaun Harrison on 9/15/09.
//  Copyright (c) 2009-2010 enormego
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGOImageView.h"
#import "EGOImageLoader.h"


@implementation EGOImageView

@synthesize activityIndicator;
@synthesize imageURL, placeholderImage, delegate, isThumbnail;

- (id)initWithPlaceholderImage:(UIImage*)anImage {
	return [self initWithPlaceholderImage:anImage delegate:nil];	
}

- (id)initWithPlaceholderImage:(UIImage*)anImage delegate:(id<EGOImageViewDelegate>)aDelegate {
	if((self = [super initWithImage:anImage])) {
		self.placeholderImage = anImage;
		self.delegate = aDelegate;
		self.isThumbnail = NO;
	}
	
	return self;
}

- (void) setShowActivity:(BOOL)value{
	if(value)
	{
		// Add an activator to show the progress.
		if(activityIndicator == nil)
        {
			self.activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
            
            [self.activityIndicator setColor:RED_STRIP_COLOR];
			[self.activityIndicator hidesWhenStopped];
			self.activityIndicator.center = self.center;
			self.activityIndicator.autoresizingMask = UIViewAutoresizingNone;
			[self addSubview:self.activityIndicator];
		}
	}
	else {
		if(self.activityIndicator)
			[self.activityIndicator removeFromSuperview];
	}

}

- (void)setImageURL:(NSURL *)aURL {
	
	
	[self.activityIndicator startAnimating];
	
	if(imageURL) {
		[[EGOImageLoader sharedImageLoader] removeObserver:self forURL:imageURL];
		[imageURL release];
		imageURL = nil;
	}
	
	if(!aURL) {
		self.image = self.placeholderImage;
		imageURL = nil;
		[self.activityIndicator stopAnimating];
		
		return;
	} else {
		imageURL = [aURL retain];
	}
	
	[[EGOImageLoader sharedImageLoader] removeObserver:self];
	UIImage* anImage = nil;
	if(self.isThumbnail){
		anImage = [[EGOImageLoader sharedImageLoader] thumbnailImageForURL:aURL shouldLoadWithObserver:self];
	}
	else {
		anImage = [[EGOImageLoader sharedImageLoader] imageForURL:aURL shouldLoadWithObserver:self];
	}

	
	
	if(anImage) {
		// Need to create thumbnail for the image other than BookCover.
		
		self.image = anImage;
	} else {
		self.image = self.placeholderImage;
	}
}

#pragma mark -
#pragma mark Image loading

- (void)cancelImageLoad {
	[[EGOImageLoader sharedImageLoader] cancelLoadForURL:self.imageURL];
	[[EGOImageLoader sharedImageLoader] removeObserver:self forURL:self.imageURL];
}

- (void)imageLoaderDidLoad:(NSNotification*)notification {
	if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:self.imageURL]) return;

	UIImage* anImage = [[notification userInfo] objectForKey:@"image"];
	self.image = anImage;
	[self setNeedsDisplay];
	
	if([self.delegate respondsToSelector:@selector(imageViewLoadedImage:)]) {
		[self.delegate imageViewLoadedImage:self];
	}
	
	[self.activityIndicator stopAnimating];
}

- (void)imageLoaderDidFailToLoad:(NSNotification*)notification {
	if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:self.imageURL]) return;
	
	//self.image = self.placeholderImage;
	
	[self.activityIndicator stopAnimating];
	
	if([self.delegate respondsToSelector:@selector(imageViewFailedToLoadImage:error:)]) {
		[self.delegate imageViewFailedToLoadImage:self error:[[notification userInfo] objectForKey:@"error"]];
	}
}


-(void) showActiveindicator{


}

- (void) RefereshActiveIndicatorFram{

  self.activityIndicator.center = self.center;
}

#pragma mark -
- (void)dealloc {
	
#if APPITUDE_DEBUG_LEVEL > 3
	NSLog(@"############################## %@ has been dealloced. ##############################", [[self class] description]);
#endif
	#if TW_DEBUG_LEVEL > 4
	NSLog(@"############################### %@ has been dealloced ###############################", [[self class] description]);
#endif
	[[EGOImageLoader sharedImageLoader] removeObserver:self];
	self.imageURL = nil;
	self.placeholderImage = nil;
	[activityIndicator release];

    [super dealloc];
}

@end
