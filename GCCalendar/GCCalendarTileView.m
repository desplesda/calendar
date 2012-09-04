//
//  GCCalendarTile.m
//  GCCalendar
//
//	GUI Cocoa Common Code Library
//
//  Created by Caleb Davenport on 1/23/10.
//  Copyright GUI Cocoa Software 2010. All rights reserved.
//

#import "GCCalendarTileView.h"
#import "GCCalendarEvent.h"
#import "GCCalendar.h"
#import "EAGlossyBox.h"
#import <QuartzCore/QuartzCore.h>

#define TILE_SIDE_PADDING 6

@implementation GCCalendarTileView

@synthesize event;

- (id)init {
	if (self = [super init]) {
		self.clipsToBounds = YES;
		self.userInteractionEnabled = YES;
		self.multipleTouchEnabled = NO;
		
		titleLabel = [[UILabel alloc] init];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
		titleLabel.font = [UIFont systemFontOfSize:13.0f];
        titleLabel.numberOfLines = 0;
		
		descriptionLabel = [[UILabel alloc] init];
		descriptionLabel.backgroundColor = [UIColor clearColor];
		descriptionLabel.textColor = [UIColor whiteColor];
		descriptionLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
		descriptionLabel.font = [UIFont systemFontOfSize:12.0f];
		descriptionLabel.lineBreakMode = UILineBreakModeWordWrap;
		descriptionLabel.numberOfLines = 0;
        
        badgeImageView = [[UIImageView alloc] init];
		
		backgroundView = [[EAGlossyBox alloc] initWithFrame:CGRectZero];
		backgroundView.alpha = 0.90f;
		
		[self addSubview:backgroundView];
        [self addSubview:badgeImageView];
		[self addSubview:titleLabel];
		[self addSubview:descriptionLabel];
        
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
	}
	
	return self;
}
- (void)dealloc {
	self.event = nil;
}

- (void)setEvent:(GCCalendarEvent *)e {
	event = e;
	
    
	// set bg image
    backgroundView.color = event.color;
	
	// set title
    titleLabel.text = event.eventName;
                       
	descriptionLabel.text = event.eventDescription;
    
    if (event.eventDescription == nil)
        descriptionLabel.hidden = YES;
    else
        descriptionLabel.hidden = NO;
    
    if (event.image) {
        badgeImageView.image = event.image;
    }
	
	[self setNeedsDisplay];
}
- (void)layoutSubviews {
	CGRect myBounds = CGRectInset(self.bounds, 0, 3);
    
    
	backgroundView.frame = CGRectInset(myBounds, 1, 1);
    
    [badgeImageView sizeToFit];
    badgeImageView.frame = CGRectMake(myBounds.size.width - badgeImageView.bounds.size.width - TILE_SIDE_PADDING, myBounds.origin.y+3, badgeImageView.bounds.size.width, badgeImageView.bounds.size.height);
    
    NSInteger titleWidth = myBounds.size.width - TILE_SIDE_PADDING * 2;
    
    CGSize stringSize = CGSizeZero;
    
    CGRect titleRect = CGRectMake(TILE_SIDE_PADDING, myBounds.origin.y+3, titleWidth, myBounds.size.height-10);
    if (event.image)
        titleRect.size.width -= (badgeImageView.bounds.size.width + 3);
    
    if (event.eventDescription) {
        stringSize = [titleLabel.text sizeWithFont:titleLabel.font];
    } else {
        stringSize = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:titleRect.size];
    }
    
    titleRect.size = stringSize;
    
	titleLabel.frame = titleRect;
	
	if (event.allDayEvent) {
		descriptionLabel.frame = CGRectZero;
	}
	else {
		descriptionLabel.frame = CGRectMake(TILE_SIDE_PADDING,
											titleLabel.frame.size.height + 2,
											myBounds.size.width - TILE_SIDE_PADDING * 2,
											myBounds.size.height - 14 - titleLabel.frame.size.height);
	}
}

#pragma mark touch handling
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)e {
	// show touch-began state
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)e {
	
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)e {
	UITouch *touch = [touches anyObject];
	
	if ([self pointInside:[touch locationInView:self] withEvent:nil]) {
		[self touchesCancelled:touches withEvent:e];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:__GCCalendarTileTouchNotification
															object:self];
	}
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)e {
	// show touch-end state
}

@end
