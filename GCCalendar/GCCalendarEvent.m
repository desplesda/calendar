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
		
	}
	
	return self;
}

- (BOOL) intersectsEvent:(GCCalendarEvent*)otherEvent {
    
    NSTimeInterval myStartDateTime = self.startDate.timeIntervalSinceReferenceDate;
    NSTimeInterval myEndDateTime = self.endDate.timeIntervalSinceReferenceDate;
    
    NSTimeInterval theirStartDateTime = otherEvent.startDate.timeIntervalSinceReferenceDate;
    NSTimeInterval theirEndDateTime = otherEvent.endDate.timeIntervalSinceReferenceDate;

    if (myEndDateTime == theirStartDateTime || myStartDateTime == theirEndDateTime)
        return NO;
        
    return (myStartDateTime <= theirEndDateTime) && (myEndDateTime >= theirStartDateTime);
}

- (NSInteger)column {
    return [self.intersectingEvents indexOfObject:self];
}


@end
