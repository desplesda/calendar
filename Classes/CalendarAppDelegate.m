//
//  CalendarAppDelegate.m
//  Calendar
//
//  Created by Caleb Davenport on 1/23/10.
//  Copyright GUI Cocoa Software 2010. All rights reserved.
//

#import "CalendarAppDelegate.h"

@implementation CalendarAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// create calendar view
	GCCalendarPortraitView *calendar = [[GCCalendarPortraitView alloc] init];
	calendar.dataSource = self;
	calendar.delegate = self;
	calendar.hasAddButton = YES;
	
	// create navigation view
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:calendar];
	
	// create tab controller
	tabController = [[UITabBarController alloc] init];
	tabController.viewControllers = @[nav];
	
	// setup window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window addSubview:tabController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
	window = nil;
	
	tabController = nil;
	
}

#pragma mark GCCalendarDataSource
- (NSArray *)calendarEventsForDate:(NSDate *)date {
	NSMutableArray *events = [NSMutableArray array];
	
	NSDateComponents *components = [[NSCalendar currentCalendar] components:
									(NSWeekdayCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit)
																   fromDate:date];
	[components setSecond:0];

	// create 5 calendar events that aren't all day events
	for (NSInteger i = 0; i < 5; i++) {
		GCCalendarEvent *event = [[GCCalendarEvent alloc] init];
		event.color = [[GCCalendar colors] objectAtIndex:i];
		event.allDayEvent = NO;
		event.eventName = [event.color capitalizedString];
		event.eventDescription = event.eventName;
		
		[components setHour:12 + i];
		[components setMinute:0];
		
		event.startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
		
		[components setMinute:50];
		
		event.endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
		
		[events addObject:event];
	}


	GCCalendarEvent *evt = [[GCCalendarEvent alloc] init];
	evt.color = [[GCCalendar colors] objectAtIndex:1];
	evt.allDayEvent = NO;
	evt.eventName = @"Test event";
	evt.eventDescription = @"Description for test event. This is intentionnaly too long to stay on a single line.";
	[components setHour:18];
	[components setMinute:0];
	evt.startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
	[components setHour:20];
	evt.endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
	[events addObject:evt];
     
    evt = [[GCCalendarEvent alloc] init];
	evt.eventName = @"Test event";
	evt.eventDescription = @"Description for test event. This is intentionnaly too long to stay on a single line.";
	[components setHour:17];
	[components setMinute:0];
	evt.startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
	[components setHour:20];
	evt.endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
	[events addObject:evt];
	
    evt = [[GCCalendarEvent alloc] init];
	evt.eventName = @"Test event";
	[components setHour:19];
	[components setMinute:0];
	evt.startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
	[components setHour:20];
    [components setMinute:30];
	evt.endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
	[events addObject:evt];
    
	// create an all day event
	GCCalendarEvent *event = [[GCCalendarEvent alloc] init];
	event.allDayEvent = YES;
	event.eventName = @"All Day Event";
	[events addObject:event];
	
	return events;
}

#pragma mark GCCalendarDelegate
- (void)calendarTileTouchedInView:(GCCalendarViewController *)view withEvent:(GCCalendarEvent *)event {
	NSLog(@"Touch event %@", event.eventName);
}
- (void)calendarViewAddButtonPressed:(GCCalendarViewController *)view {
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
