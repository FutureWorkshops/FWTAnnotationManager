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

@property (nonatomic, readonly, retain) NSString *guid;
@property (nonatomic, assign) CGRect presentingRectPortrait, presentingRectLandscape;
@property (nonatomic, assign) FWTPopoverArrowDirection arrowDirection;
@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, assign) BOOL animated;
@property (nonatomic, retain) NSString *text;

@end
