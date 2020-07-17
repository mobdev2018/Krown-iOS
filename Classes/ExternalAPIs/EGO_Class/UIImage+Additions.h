//
//  UIImage+Additions.h
//  Mobnotes
//
//  Created by Om Prakash on 2/24/10.
//  Copyright 2010 B24. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UIImage (RoundedCorner)
+(void)load;
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;
- (void)addRoundedRectToPathCustom:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight;
@end

@interface UIImage (Alpha)
+(void)load;
- (BOOL)hasAlpha;
- (UIImage *)imageWithAlpha;
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize;
- (CGImageRef)newBorderMaskCustom:(NSUInteger)borderSize size:(CGSize)size;
@end


@interface UIImage(Resize)
+ (void) load;
- (UIImage*) scaleToSize:(CGSize)size;
- (UIImage*)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage*) grayscaleImage;

- (UIImage*)croppedImage:(CGRect)bounds;
- (UIImage*)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage*)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage*)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImageCustom:(CGSize)newSize
                      transform:(CGAffineTransform)transform
                 drawTransposed:(BOOL)transpose
           interpolationQuality:(CGInterpolationQuality)quality;
- (CGAffineTransform)transformForOrientationCustom:(CGSize)newSize;

@end
