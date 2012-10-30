//
//  FWTAnnotationArrow.h
//  FWTAnnotationManager
//
//  Created by Marco Meschini on 30/10/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "FWTAnnotationView.h"

@interface FWTAnnotationArrow : NSObject

//@property (nonatomic, readonly) FWTAnnotationArrowDirection arrowDirection;
@property (nonatomic, assign) CGSize arrowSize;
@property (nonatomic, assign) CGFloat arrowOffset;
@property (nonatomic, assign) CGFloat arrowCornerOffset;

@end
