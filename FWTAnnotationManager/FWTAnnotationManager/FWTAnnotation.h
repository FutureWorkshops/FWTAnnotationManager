//
//  FWTPopoverDescriptor.h
//  FWTPopoverHintView
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FWTPopoverView.h"

@interface FWTAnnotation : NSObject

@property (nonatomic, assign) CGRect presentingRectPortrait, presentingRectLandscape;   // CGRectZero
@property (nonatomic, assign) FWTPopoverArrowDirection arrowDirection;                  // FWTPopoverArrowDirectionNone
@property (nonatomic, assign) NSTimeInterval delay;                                     // 0
@property (nonatomic, assign) BOOL animated;                                            // YES
@property (nonatomic, assign) BOOL dismissOnTouch;                                      // YES

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) UIImage *image;

@end
