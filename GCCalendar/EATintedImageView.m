//
//  EATintedImageView.m
//  EventApp
//
//  Created by Jon Manning on 28/08/12.
//  Copyright (c) 2012 Secret Lab. All rights reserved.
//

#import "EATintedImageView.h"

@implementation EATintedImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) drawRect:(CGRect)area
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    [self.image drawInRect:self.bounds];
    
    if (self.overlayColor) {
        CGContextSetBlendMode (context, kCGBlendModeHue);
        CGContextSetFillColor(context, CGColorGetComponents(self.overlayColor.CGColor));
        CGContextFillRect (context, self.bounds);
    }
    CGContextRestoreGState(context);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
