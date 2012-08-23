//
//  GCCalendarEvent.m
//  GCCalendar
//
//	GUI Cocoa Common Code Library
//
//  Created by Caleb Davenport on 1/23/10.
//  Copyright GUI Cocoa Software 2010. All rights reserved.
//

#import "GCCalendarEvent.h"

@implementation GCCalendarEvent

- (id)init {
	if (self = [super init]) {
		self.color = @"GREY";
	}
	
	return self;
}

- (BOOL) intersectsEvent:(GCCalendarEvent*)otherEvent {
    
    NSTimeInterval myStartDateTime = self.startDate.timeIntervalSinceReferenceDate;
    NSTimeInterval myEndDateTime = self.endDate.timeIntervalSinceReferenceDate;
    
    NSTimeInterval theirStartDateTime = otherEvent.startDate.timeIntervalSinceReferenceDate;
    NSTimeInterval theirEndDateTime = otherEvent.endDate.timeIntervalSinceReferenceDate;
    
    return (myStartDateTime <= theirEndDateTime) && (myEndDateTime >= theirStartDateTime);
}

- (NSInteger)column {
    return [self.intersectingEvents indexOfObject:self];
}


@end
