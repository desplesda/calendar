//
//  GCDatePickerControl.m
//  GCCalendar
//
//	GUI Cocoa Common Code Library
//
//  Created by Caleb Davenport on 1/23/10.
//  Copyright GUI Cocoa Software 2010. All rights reserved.
//

#import "GCDatePickerControl.h"
#import "GCCalendar.h"

#define kSecondsInDay (60 * 60 * 24)

@interface GCDatePickerControl ()
@property (nonatomic) BOOL today;
@end

@implementation GCDatePickerControl

@synthesize date, today;

#pragma mark create and destroy view

- (void)setLeftButtonImage:(UIImage *)leftButtonImage {
    [backButton setImage:leftButtonImage forState:UIControlStateNormal];
}

- (void)setRightButtonImage:(UIImage *)rightButtonImage {
    [forwardButton setImage:rightButtonImage forState:UIControlStateNormal];
}

- (void)setTextColor:(UIColor *)color {
    titleLabel.textColor = color;
}

- (void)setTextShadowColor:(UIColor *)color{
    titleLabel.shadowColor = color;
}

- (void)setBackgroundImage:(UIImage *)image {
    self.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (id)init {
	if(self = [super init]) {
		self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"GCDatePickerControlBackground.png"]];
		
		// left button
		backButton = [[UIButton alloc] init];
		[backButton setImage:[UIImage imageNamed:@"GCDatePickerControlLeft.png"] forState:UIControlStateNormal];
		backButton.showsTouchWhenHighlighted = YES;
		backButton.adjustsImageWhenHighlighted = NO;
		[backButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
		
		// right button
		forwardButton = [[UIButton alloc] init];
		[forwardButton setImage:[UIImage imageNamed:@"GCDatePickerControlRight.png"] forState:UIControlStateNormal];
		forwardButton.showsTouchWhenHighlighted = YES;
		forwardButton.adjustsImageWhenHighlighted = NO;
		[forwardButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
		
		// label
		titleLabel = [[UILabel alloc] init];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.opaque = YES;
		titleLabel.textAlignment = UITextAlignmentCenter;
		titleLabel.shadowColor = [UIColor whiteColor];
		titleLabel.shadowOffset = CGSizeMake(0, 1);
		titleLabel.font = [UIFont boldSystemFontOfSize:20];
		
		[self addSubview:backButton];
		[self addSubview:forwardButton];
		[self addSubview:titleLabel];
		
		self.today = NO;
	}
	
	return self;
}
- (void)dealloc {
	backButton = nil;
	
	forwardButton = nil;
	
	titleLabel = nil;
	
	
}

#pragma mark view notifications
- (CGSize)sizeThatFits:(CGSize)size {
	return CGSizeMake(size.width, 45.0f);
}
- (void)layoutSubviews {
#define kButtonWidth 40
	[super layoutSubviews];
	
	CGRect tempFrame;
	
	tempFrame = CGRectMake(0, 0, kButtonWidth, 45);
	backButton.frame = tempFrame;
	
	tempFrame = CGRectMake(self.frame.size.width - kButtonWidth, 0, kButtonWidth, 45);
	forwardButton.frame = tempFrame;
	
	tempFrame = CGRectMake(kButtonWidth, 0, self.frame.size.width - (kButtonWidth * 2), 45);
	titleLabel.frame = tempFrame;
}

#pragma mark setters
- (void)setDate:(NSDate *)newDate {
	date = newDate;
	
	self.today = [GCCalendar dateIsToday:date];
		
	NSDateComponents *comp = [[NSCalendar currentCalendar] components:
							  (NSWeekdayCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit)
															 fromDate:date];
	
	NSInteger weekday = [comp weekday];
	NSInteger month = [comp month];
	NSInteger year = [comp year];
	NSInteger day = [comp day];
	
	NSArray *weekdayStrings = [[GCCalendar dateFormatter] weekdaySymbols];
	NSArray *monthStrings = [[GCCalendar dateFormatter] shortMonthSymbols];
	
	NSString *toDisplay = [NSString stringWithFormat:@"%@ %@ %d %d", 
							[weekdayStrings objectAtIndex:weekday - 1],
							[monthStrings objectAtIndex:month - 1],
							day, year];
	titleLabel.text = toDisplay;
    
    NSDate *dayBefore = [[NSDate alloc] initWithTimeInterval:-kSecondsInDay sinceDate:date];
    NSDate *dayAfter = [[NSDate alloc] initWithTimeInterval:kSecondsInDay sinceDate:date];
    
    if (self.delegate && [self.delegate datePickerControl:self willChangeToDate:dayBefore] == NO) {
        [self setButton:backButton enabled:NO];
    } else {
        [self setButton:backButton enabled:YES];
    }
    
    if (self.delegate && [self.delegate datePickerControl:self willChangeToDate:dayAfter] == NO) {
        [self setButton:forwardButton enabled:NO];
    } else {
        [self setButton:forwardButton enabled:YES];
    }
    
    
}
- (void)setFrame:(CGRect)newFrame {
	newFrame.size.height = 45;
	super.frame = newFrame;
	
	[self setNeedsLayout];
}
- (void)setToday:(BOOL)newToday {
	today = newToday;
	
	/*if(today) {
		titleLabel.textColor = [UIColor colorWithRed:0
											   green:(88.0/255.0)
												blue:(238.0/255.0)
											   alpha:1.0];
	} else {
		titleLabel.textColor = [UIColor colorWithRed:(48.0/255.0)
											   green:(65.0/255.0)
												blue:(84.0/255.0)
											   alpha:1.0];
	}*/
}

- (void) setButton:(UIButton*)button enabled:(BOOL)enabled {
    if (enabled) {
        button.enabled = YES;
        button.alpha = 1.0;
    } else {
        button.enabled = NO;
        button.alpha = 0.5;
    }
}

#pragma mark button actions
- (void)buttonPressed:(UIButton *)sender {
	if(sender == backButton) {
		NSDate *newDate = [[NSDate alloc] initWithTimeInterval:-kSecondsInDay sinceDate:date];
        if (self.delegate && [self.delegate datePickerControl:self willChangeToDate:newDate] == NO)
            return;
        self.date = newDate;
	} else if(sender == forwardButton) {
		NSDate *newDate = [[NSDate alloc] initWithTimeInterval:kSecondsInDay sinceDate:date];
        if (self.delegate && [self.delegate datePickerControl:self willChangeToDate:newDate] == NO)
            return;
        self.date = newDate;
	}
	
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
