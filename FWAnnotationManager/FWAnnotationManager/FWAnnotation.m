//
//  FWPopoverDescriptor.m
//  FWPopoverHintView
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "FWAnnotation.h"

@implementation FWAnnotation
@synthesize text = _text;
@synthesize presentingRectPortrait = _presentingRectPortrait;
@synthesize presentingRectLandscape = _presentingRectLandscape;
@synthesize arrowDirection = _arrowDirection;
@synthesize delay = _delay;
@synthesize animated = _animated;
@synthesize desiredSize = _desiredSize;

- (void)dealloc
{
    self.text = nil;
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        self.arrowDirection = FWPopoverArrowDirectionNone;
        self.delay = .0f;
        self.desiredSize = CGSizeZero;
    }
    
    return self;
}

@end
