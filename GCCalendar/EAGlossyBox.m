//
//  EAGlossyBox.m
//  EventApp
//
//  Created by Jon Manning on 29/08/12.
//  Copyright (c) 2012 Secret Lab. All rights reserved.
//

#import "EAGlossyBox.h"
#import <QuartzCore/QuartzCore.h>

@interface EAGlossyBox () {
    UIImageView* _glossImage;
}

@end

@implementation EAGlossyBox

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 5;
        self.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
        self.layer.borderWidth = 1;
        
        
        _glossImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Calendar-Tile-Gloss-Pattern"]];
        [self addSubview:_glossImage];
        self.clipsToBounds = YES;
        
    }
    return self;
}

- (void)setColor:(UIColor *)color {
    self.backgroundColor = color;
}

- (void)layoutSubviews {
    _glossImage.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(_glossImage.bounds));
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
