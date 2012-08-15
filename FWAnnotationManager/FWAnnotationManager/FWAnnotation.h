//
//  FWPopoverDescriptor.h
//  FWPopoverHintView
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FWAnnotationView.h"

@interface FWAnnotation : NSObject
{
    NSString *_text;
    CGRect _presentingRectPortrait, _presentingRectLandscape;
    FWPopoverArrowDirection _arrowDirection;
    NSTimeInterval _delay;
    BOOL _animated;
    CGSize _desiredSize;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, assign) CGRect presentingRectPortrait, presentingRectLandscape;
@property (nonatomic, assign) FWPopoverArrowDirection arrowDirection;
@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, assign) BOOL animated;
@property (nonatomic, assign) CGSize desiredSize;
@end
