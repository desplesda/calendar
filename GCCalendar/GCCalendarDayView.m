//
//  GCCalendarDayView.m
//  GCCalendar
//
//	GUI Cocoa Common Code Library
//
//  Created by Caleb Davenport on 1/23/10.
//  Copyright GUI Cocoa Software 2010. All rights reserved.
//

#import "GCCalendarDayView.h"
#import "GCCalendarTileView.h"
#import "GCCalendarViewController.h"
#import "GCCalendarEvent.h"
#import "GCCalendar.h"

#define kTileLeftSide 52.0f
#define kTileRightSide 10.0f

#define kTopLineBuffer 11.0
#define kSideLineBuffer 50.0
#define kHalfHourDiff 44.0

static NSArray *timeStrings;

@interface GCCalendarAllDayView : UIView {
	NSArray *events;
}

- (id)initWithEvents:(NSArray *)a;
- (BOOL)hasEvents;

@end

@implementation GCCalendarAllDayView
- (id)initWithEvents:(NSArray *)a {
	if (self = [super init]) {
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"allDayEvent == YES"];
		events = [a filteredArrayUsingPredicate:pred];
		
		NSInteger eventCount = 0;
		for (GCCalendarEvent *e in events) {
			if (eventCount < 5) {
				GCCalendarTileView *tile = [[GCCalendarTileView alloc] init];
				tile.event = e;
				[self addSubview:tile];
				
				eventCount++;
			}
		}
	}
	
	return self;
}
- (void)dealloc {
	events = nil;
	
}
- (BOOL)hasEvents {
	return ([events count] != 0);
}
- (CGSize)sizeThatFits:(CGSize)size {
	CGSize toReturn = CGSizeMake(0, 0);
	
	if ([self hasEvents]) {
		NSInteger eventsCount = ([events count] > 5) ? 5 : [events count];
		toReturn.height = (5 * 2) + (27 * eventsCount) + (eventsCount - 1);
	}
	
	return toReturn;
}
- (void)layoutSubviews {
	CGFloat start_y = 5.0f;
	CGFloat height = 27.0f;
	
	for (UIView *view in self.subviews) {
		// get calendar tile and associated event
		GCCalendarTileView *tile = (GCCalendarTileView *)view;
		
		tile.frame = CGRectMake(kTileLeftSide,
								start_y,
								self.frame.size.width - kTileLeftSide - kTileRightSide,
								height);
		
		start_y += (height + 1);
	}
}
- (void)drawRect:(CGRect)rect {
	// grab current graphics context
	CGContextRef g = UIGraphicsGetCurrentContext();
	
	// fill white background
	CGContextSetRGBFillColor(g, 1.0, 1.0, 1.0, 1.0);
	CGContextFillRect(g, self.frame);
	
	// draw border line
	CGContextMoveToPoint(g, 0, self.frame.size.height);
	CGContextAddLineToPoint(g, self.frame.size.width, self.frame.size.height);
	
	// draw all day text
	UIFont *numberFont = [UIFont boldSystemFontOfSize:12.0];
	[[UIColor blackColor] set];
	NSString *text = [[NSBundle mainBundle] localizedStringForKey:@"ALL_DAY" value:@"" table:@"GCCalendar"];
	CGRect textRect = CGRectMake(6, 10, 40, [text sizeWithFont:numberFont].height);
	[text drawInRect:textRect withFont:numberFont];
	
	// stroke the path
	CGContextStrokePath(g);
}
@end

@interface GCCalendarTodayView : UIView {
	NSArray *events;
    __weak GCCalendarDayView *_dayView;
}

- (id)initWithEvents:(NSArray *)a dayView:(GCCalendarDayView*)dayView;
- (BOOL)hasEvents;
+ (CGFloat)yValueForTime:(CGFloat)time;

@end

@implementation GCCalendarTodayView
- (id)initWithEvents:(NSArray *)a dayView:(GCCalendarDayView *)dayView {
	if (self = [super init]) {
        
        _dayView = dayView;
        
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"allDayEvent == NO"];
		events = [a filteredArrayUsingPredicate:pred];
		
		for (GCCalendarEvent *e in events) {
			GCCalendarTileView *tile = [[GCCalendarTileView alloc] init];
			tile.event = e;
			[self addSubview:tile];
		}
        
        self.backgroundColor = [UIColor clearColor];
	}
	
	return self;
}
- (BOOL)hasEvents {
	return ([events count] != 0);
}
- (void)dealloc {
	events = nil;
	
}
- (void)layoutSubviews {
	for (UIView *view in self.subviews) {
		// get calendar tile and associated event
		GCCalendarTileView *tile = (GCCalendarTileView *)view;
		
        NSDateComponents *components;
		components = tile.event.startDateComponents;
		NSInteger startHour = [components hour];
		NSInteger startMinute = [components minute];
		
		components = tile.event.endDateComponents;
		NSInteger endHour = [components hour];
		NSInteger endMinute = [components minute];
		
		CGFloat startPos = kTopLineBuffer + startHour * 2 * kHalfHourDiff - 2;
		startPos += (startMinute / 60.0) * (kHalfHourDiff * 2.0);
		startPos = floor(startPos);
		
		CGFloat endPos = kTopLineBuffer + endHour * 2 * kHalfHourDiff + 3;
		endPos += (endMinute / 60.0) * (kHalfHourDiff * 2.0);
		endPos = floor(endPos);
        
        NSInteger columnWidth = (self.bounds.size.width - kTileLeftSide - kTileRightSide) / tile.event.intersectingEvents.count;
        NSInteger columnNumber = tile.event.column;
		
		tile.frame = CGRectMake(kTileLeftSide + (columnWidth * columnNumber),
								startPos, 
								columnWidth,
								endPos - startPos);
	}
}
- (void)drawRect:(CGRect)rect {
    // grab current graphics context
	CGContextRef g = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(g, _dayView.outsideHoursColor.CGColor);
	
	// fill morning hours light grey
	CGFloat morningHourMax = [GCCalendarTodayView yValueForTime:(CGFloat)8];
	CGRect morningHours = CGRectMake(0, 0, self.frame.size.width, morningHourMax - 1);	
	CGContextFillRect(g, morningHours);

	// fill evening hours light grey
	CGFloat eveningHourMax = [GCCalendarTodayView yValueForTime:(CGFloat)20];
	CGRect eveningHours = CGRectMake(0, eveningHourMax - 1, self.frame.size.width, self.frame.size.height - eveningHourMax + 1);
	CGContextFillRect(g, eveningHours);
	
	// fill day hours white
    
    CGContextSetFillColorWithColor(g, _dayView.officeHoursColor.CGColor);
    
	CGRect dayHours = CGRectMake(0, morningHourMax - 1, self.frame.size.width, eveningHourMax - morningHourMax);
	CGContextFillRect(g, dayHours);
	
	// draw hour lines
	CGContextSetShouldAntialias(g, NO);
	const CGFloat solidPattern[2] = {1.0, 0.0};
	CGContextSetStrokeColorWithColor(g, _dayView.hourMarkerColor.CGColor);
	CGContextSetLineDash(g, 0, solidPattern, 2);
	for (NSInteger i = 0; i < 25; i++) {
		CGFloat yVal = [GCCalendarTodayView yValueForTime:(CGFloat)i];
		CGContextMoveToPoint(g, kSideLineBuffer, yVal);
		CGContextAddLineToPoint(g, self.frame.size.width, yVal);
	}
	CGContextStrokePath(g);
	
	// draw half hour lines
	CGContextSetShouldAntialias(g, NO);
	const CGFloat dashPattern[2] = {1.0, 1.0};
    
	CGContextSetStrokeColorWithColor(g, _dayView.hourMarkerColor.CGColor);
	
    CGContextSetLineDash(g, 0, dashPattern, 2);
	for (NSInteger i = 0; i < 24; i++) {
		CGFloat time = (CGFloat)i + 0.5f;
		CGFloat yVal = [GCCalendarTodayView yValueForTime:time];
		CGContextMoveToPoint(g, kSideLineBuffer, yVal);
		CGContextAddLineToPoint(g, self.frame.size.width, yVal);
	}
	CGContextStrokePath(g);
	
	// draw hour numbers
	CGContextSetShouldAntialias(g, YES);
	[_dayView.timeColor set];
	UIFont *numberFont = [UIFont boldSystemFontOfSize:14.0];
	for (NSInteger i = 0; i < 25; i++) {
		CGFloat yVal = [GCCalendarTodayView yValueForTime:(CGFloat)i];
		NSString *number = [timeStrings objectAtIndex:i];
		CGSize numberSize = [number sizeWithFont:numberFont];
		if(i == 12) {
			[number drawInRect:CGRectMake(kSideLineBuffer - 7 - numberSize.width, 
										  yVal - floor(numberSize.height / 2) - 1,
										  numberSize.width,
										  numberSize.height)
					  withFont:numberFont
				 lineBreakMode:UILineBreakModeTailTruncation
					 alignment:UITextAlignmentRight];
		} else {
			[number drawInRect:CGRectMake(0, 
										  yVal - floor(numberSize.height / 2) - 1,
										  kSideLineBuffer - 18 - 10,
										  numberSize.height)
					  withFont:numberFont
				 lineBreakMode:UILineBreakModeTailTruncation
					 alignment:UITextAlignmentRight];
		}
	}
	
	// draw am / pm text
	CGContextSetShouldAntialias(g, YES);
	[_dayView.AMPMColor set];
	UIFont *textFont = [UIFont systemFontOfSize:12.0];
	for (NSInteger i = 0; i < 25; i++) {
		NSString *text = nil;
		if (i < 12) {
			text = @"AM";
		}
		else if (i > 12) {
			text = @"PM";
		}
		if (i != 12) {
			CGFloat yVal = [GCCalendarTodayView yValueForTime:(CGFloat)i];
			CGSize textSize = [text sizeWithFont:textFont];
			[text drawInRect:CGRectMake(kSideLineBuffer - 7 - textSize.width,
										yVal - (textSize.height / 2),
										textSize.width, 
										textSize.height)
					withFont:textFont];
		}
	}
}
+ (CGFloat)yValueForTime:(CGFloat)time {
	return kTopLineBuffer + (88.0f * time);;
}
@end

@implementation GCCalendarDayView

@synthesize date;

#pragma mark create and destroy view
+ (void)initialize {
	if(self == [GCCalendarDayView class]) {
		timeStrings = @[@"12",
						@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11",
						@"Noon",
						@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12"];
	}
}
- (id)initWithCalendarView:(GCCalendarViewController *)view {
	if (self = [super init]) {
		dataSource = view.dataSource;
        
        self.outsideHoursColor = [UIColor colorWithRed:(242.0 / 255.0) green:(242.0 / 255.0) blue:(242.0 / 255.0) alpha:1.0];
        
        self.officeHoursColor = [UIColor whiteColor];
        self.hourMarkerColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        
        self.timeColor = [UIColor blackColor];
        self.AMPMColor = [UIColor darkGrayColor];
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
	}
	
	return self;
}
- (void)reloadData {
	// get new events for date
	events = [dataSource calendarEventsForDate:date];
    
    // sort the events by start date
    events = [events sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES]]];
    
    // figure out which events intersect (yay, O(n^2))
    for (GCCalendarEvent* event in events) {
        
        NSMutableArray* intersectingEvents = [NSMutableArray array];
        
        for (GCCalendarEvent* otherEvent in events) {
            if ([event intersectsEvent:otherEvent])
                [intersectingEvents addObject:otherEvent];
        }
        
        
        event.intersectingEvents = intersectingEvents;
    }
    
    // Remove intersecting events from the list if two events do not intersect with each other
    for (GCCalendarEvent* event in events){
        NSMutableArray* intersectingEvents = [NSMutableArray arrayWithArray:event.intersectingEvents];
        NSMutableArray* intersectingEventsToRemove = [NSMutableArray array];
        
        for (GCCalendarEvent* otherEvent in intersectingEvents) {
            BOOL intersecting = YES;
            for (GCCalendarEvent* intersectingOtherEvent in intersectingEvents) {
                if ([otherEvent intersectsEvent:intersectingOtherEvent] == NO) {
                    intersecting = NO;
                    break;
                }
            }
            if (intersecting == NO) {
                [intersectingEventsToRemove addObject:otherEvent];
                break;
            }
            
        }
        
        [intersectingEvents removeObjectsInArray:intersectingEventsToRemove];
        
        event.intersectingEvents = intersectingEvents;
    }
    
    // Reload theming info
    if ([dataSource respondsToSelector:@selector(outsideHoursColor)])
        self.outsideHoursColor = [dataSource outsideHoursColor];
    
    if ([dataSource respondsToSelector:@selector(hourMarkerColor)])
        self.hourMarkerColor = [dataSource hourMarkerColor];
    
    if ([dataSource respondsToSelector:@selector(timeColor)])
        self.timeColor = [dataSource timeColor];
    
    if ([dataSource respondsToSelector:@selector(hourMarkerColor)])
        self.AMPMColor = [dataSource AMPMColor];
    
    if ([dataSource respondsToSelector:@selector(officeHoursColor)])
        self.officeHoursColor = [dataSource officeHoursColor];
    

    
	// drop all subviews
	[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	// create all day view
	allDayView = [[GCCalendarAllDayView alloc] initWithEvents:events];
	[allDayView sizeToFit];
	allDayView.frame = CGRectMake(0, 0, self.frame.size.width, allDayView.frame.size.height);
	allDayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self addSubview:(UIView *)allDayView];
	
	// create scroll view
	scrollView = [[UIScrollView alloc] init];
	scrollView.frame = CGRectMake(0, allDayView.frame.size.height, self.frame.size.width,
								  self.frame.size.height - allDayView.frame.size.height);
	scrollView.contentSize = CGSizeMake(self.frame.size.width, 2156);
	scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	[self addSubview:scrollView];
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    scrollView.backgroundColor = [UIColor clearColor];
    
    
    scrollView.contentInset = UIEdgeInsetsMake(-[GCCalendarTodayView yValueForTime:7.9], 0, -[GCCalendarTodayView yValueForTime:2], 0);
	
	// create today view
	todayView = [[GCCalendarTodayView alloc] initWithEvents:events dayView:self];
	todayView.frame = CGRectMake(0, 0, self.frame.size.width, 2156);
	todayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[scrollView addSubview:todayView];
}

- (void)setContentOffset:(CGPoint)contentOffset {
    scrollView.contentOffset = contentOffset;
}

- (CGPoint)contentOffset {
	return scrollView.contentOffset;
}

- (void) scrollToHour:(CGFloat)hour animated:(BOOL)animated {
    [scrollView setContentOffset:CGPointMake(0, [GCCalendarTodayView yValueForTime:hour]) animated:animated];
}

-(void)scrollToHour:(CGFloat)hour {
    [self scrollToHour:hour animated:NO];
}

@end