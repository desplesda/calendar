//
//  GCCalendarEvent.h
//  GCCalendar
//
//	GUI Cocoa Common Code Library
//
//  Created by Caleb Davenport on 1/23/10.
//  Copyright GUI Cocoa Software 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 GCCalendarEvent is the model object that GCCalendarTiles use to
 draw themselves on the calendar interface.
 
 Event name and description show up as strings in the event tile.
 Start and end times determine the location and height of an event tile.
 Color must be a string from the array returned by [GCCalendar colors]
 All day event determines the placement of the event in the day view
 User Info can be used to store lookup data about the object an event
	represents.  Ex. in CoreData based applications, userInfo could be
	the objectID of a managed object.
 */
@interface GCCalendarEvent : NSObject

@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) NSString *eventDescription;
@property (nonatomic, copy) NSDate *startDate;
@property (nonatomic, copy) NSDate *endDate;
@property (nonatomic, strong) id userInfo;
@property (nonatomic) BOOL allDayEvent;

// If set, this image will be displayed at the right of the title.
@property (nonatomic, strong) UIImage* image;

@property (nonatomic, copy) NSArray* intersectingEvents;
@property (readonly) NSInteger column;
@property (nonatomic, strong) UIColor* color;

- (BOOL) intersectsEvent:(GCCalendarEvent*)otherEvent;

@end
