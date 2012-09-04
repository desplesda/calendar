//
//  GCCalendarPortraitView.m
//  GCCalendar
//
//	GUI Cocoa Common Code Library
//
//  Created by Caleb Davenport on 1/23/10.
//  Copyright GUI Cocoa Software 2010. All rights reserved.
//

#import "GCCalendarPortraitViewController.h"
#import "GCCalendarDayView.h"
#import "GCCalendarTileView.h"
#import "GCDatePickerControl.h"
#import "GCCalendar.h"

#define kAnimationDuration 0.3f

@interface GCCalendarPortraitViewController ()
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) GCCalendarDayView *dayView;

- (void)reloadDayAnimated:(BOOL)animated context:(void *)context;
@end

@implementation GCCalendarPortraitViewController

@synthesize date, dayView, hasAddButton;

#pragma mark calendar actions
- (void)calendarShouldReload:(NSNotification *)notif {
	viewDirty = YES;
}
- (void)calendarTileTouch:(NSNotification *)notif {
	if (delegate != nil) {
		GCCalendarTileView *tile = [notif object];
		[delegate calendarTileTouchedInView:self withEvent:[tile event]];
	}
}

#pragma mark GCDatePickerControl actions
- (void)datePickerDidChangeDate:(GCDatePickerControl *)picker {
	NSTimeInterval interval = [date timeIntervalSinceDate:picker.date];
	
	self.date = picker.date;
	
	[[NSUserDefaults standardUserDefaults] setObject:date forKey:@"GCCalendarDate"];
	
	[self reloadDayAnimated:YES context:(__bridge void *)([NSNumber numberWithInt:interval])];
}

#pragma mark button actions
- (void)today {
    
    CGFloat hour;
	
    if (dayPicker.delegate && [dayPicker.delegate datePickerControl:dayPicker willChangeToDate:[NSDate date]] == NO) {
        dayPicker.date = [[NSUserDefaults standardUserDefaults] objectForKey:@"start_date"];
        hour = 9;
        
    } else {
        dayPicker.date = [NSDate date];
        NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents* components = [calendar components:NSHourCalendarUnit fromDate:[NSDate date]];
        hour = [components hour];
        

    }
    
	self.date = dayPicker.date;
	
	[[NSUserDefaults standardUserDefaults] setObject:date forKey:@"GCCalendarDate"];
	
	[self reloadDayAnimated:NO context:NULL];
    
    
    [self.dayView scrollToHour:hour - 0.5 animated:YES];
    
}
- (void)add {
	if (delegate != nil) {
		[delegate calendarViewAddButtonPressed:self];
	}
}

#pragma mark custom setters
- (void)setHasAddButton:(BOOL)b {
	hasAddButton = b;
	
	if (hasAddButton) {
		UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																				target:self
																				action:@selector(add)];
		self.navigationItem.rightBarButtonItem = button;
	}
	else {
		self.navigationItem.rightBarButtonItem = nil;
	}
}

#pragma mark view notifications

- (void)viewDidLoad {
        
    viewDirty = YES;
    viewVisible = NO;
    
    self.date = [[NSUserDefaults standardUserDefaults] objectForKey:@"GCCalendarDate"];
	if (date == nil) {
		self.date = [NSDate date];
	}
	
	// setup day picker
	dayPicker = [[GCDatePickerControl alloc] init];
	dayPicker.frame = CGRectMake(0, 0, self.view.frame.size.width, 0);
	dayPicker.autoresizingMask = UIViewAutoresizingNone;
	dayPicker.date = date;
    dayPicker.delegate = self;
	[dayPicker addTarget:self action:@selector(datePickerDidChangeDate:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:dayPicker];
	
	// setup initial day view
	dayView = [[GCCalendarDayView alloc] initWithCalendarView:self];
	dayView.frame = CGRectMake(0,
							   dayPicker.frame.size.height,
							   self.view.frame.size.width,
							   self.view.frame.size.height - dayPicker.frame.size.height);
	dayView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
	[self.view addSubview:dayView];
	
	// setup today button
	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Now"
															   style:UIBarButtonItemStylePlain
															  target:self
															  action:@selector(today)];
	self.navigationItem.leftBarButtonItem = button;
    
    if ([dataSource respondsToSelector:@selector(datePickerLeftButtonImage)])
        [dayPicker setLeftButtonImage:[dataSource datePickerLeftButtonImage]];
    
    if ([dataSource respondsToSelector:@selector(datePickerLeftButtonImage)])
        [dayPicker setRightButtonImage:[dataSource datePickerRightButtonImage]];
    
    if ([dataSource respondsToSelector:@selector(datePickerBackgroundImage)])
        [dayPicker setBackgroundImage:[dataSource datePickerBackgroundImage]];
    
    if ([dataSource respondsToSelector:@selector(datePickerTextColor)])
        [dayPicker setTextColor:[dataSource datePickerTextColor]];
    
    if ([dataSource respondsToSelector:@selector(datePickerTextShadowColor)])
        [dayPicker setTextShadowColor:[dataSource datePickerTextShadowColor]];
    

    
    
        
}

- (void)loadView {
	[super loadView];
	
	
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(calendarTileTouch:)
                                                 name:__GCCalendarTileTouchNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(calendarShouldReload:)
                                                 name:GCCalendarShouldReloadNotification
                                               object:nil];
	
	if (viewDirty) {
		[self reloadDayAnimated:NO context:NULL];
		viewDirty = NO;
	}
	
	viewVisible = YES;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.dayView scrollToHour:[[NSUserDefaults standardUserDefaults] floatForKey:@"start_time"]];
    });

}
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	viewVisible = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

#pragma mark view animation functions
- (void)reloadDayAnimated:(BOOL)animated context:(void *)context {
	if (animated) {
		NSTimeInterval interval = [(__bridge NSNumber *)context doubleValue];
		
		// block user interaction
		dayPicker.userInteractionEnabled = NO;
		
		// setup next day view
		GCCalendarDayView *nextDayView = [[GCCalendarDayView alloc] initWithCalendarView:self];
		CGRect initialFrame = dayView.frame;
		if (interval < 0) {
			initialFrame.origin.x = initialFrame.size.width;
		}
		else if (interval > 0) {
			initialFrame.origin.x = 0 - initialFrame.size.width;
		}
		else {
			return;
		}
		nextDayView.frame = initialFrame;
		nextDayView.date = date;
		[nextDayView reloadData];
		nextDayView.contentOffset = dayView.contentOffset;

		[self.view addSubview:nextDayView];
		
		[UIView beginAnimations:nil context:(__bridge void *)(nextDayView)];
		[UIView setAnimationDuration:kAnimationDuration];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		CGRect finalFrame = dayView.frame;
		if(interval < 0) {
			finalFrame.origin.x = 0 - finalFrame.size.width;
		} else if(interval > 0) {
			finalFrame.origin.x = finalFrame.size.width;
		}
		nextDayView.frame = dayView.frame;
		dayView.frame = finalFrame;
		[UIView commitAnimations];
	}
	else {
		CGPoint contentOffset = dayView.contentOffset;
		dayView.date = date;
		[dayView reloadData];
		dayView.contentOffset = contentOffset;
	}
}
- (void)animationDidStop:(NSString *)animationID 
				finished:(NSNumber *)finished 
				 context:(void *)context {
	
	GCCalendarDayView *nextDayView = (__bridge GCCalendarDayView *)context;
	
	// cut variables
	[dayView removeFromSuperview];
	
	// reassign variables
	self.dayView = nextDayView;
	
	// release pointers
	
	// reset pickers
	dayPicker.userInteractionEnabled = YES;
}

- (void)reloadData {
    [self reloadDayAnimated:NO context:NULL];
}

- (BOOL)datePickerControl:(GCDatePickerControl *)picker willChangeToDate:(NSDate *)date {
    return YES;
}

@end
