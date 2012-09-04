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

@synthesize startDateComponents = _startDateComponents;
@synthesize endDateComponents = _endDateComponents;

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

- (void)setStartDate:(NSDate *)startDate {
    _startDate = startDate;
    _startDateComponents = nil;
}

- (void)setEndDate:(NSDate *)endDate {
    _endDate = endDate;
    _endDateComponents = nil;
}

- (NSDateComponents *)startDateComponents {
    if (_startDateComponents == nil) {
    _startDateComponents = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit |
                                              NSMinuteCalendarUnit)
                                    fromDate:self.startDate];
    }
    return _startDateComponents;
}

- (NSDateComponents *)endDateComponents {
    if (_endDateComponents == nil) {
        _endDateComponents = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit |
                                                                         NSMinuteCalendarUnit)
                                                               fromDate:self.endDate];
    }
    return _endDateComponents;
}

@end
