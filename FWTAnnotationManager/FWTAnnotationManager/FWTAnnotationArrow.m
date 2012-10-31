//
//  FWTAnnotationArrow.m
//  FWTAnnotationManager
//
//  Created by Marco Meschini on 30/10/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import "FWTAnnotationArrow.h"

@interface FWTAnnotationArrow ()
@property (nonatomic, readwrite, assign) FWTAnnotationArrowDirection direction;
@end

@implementation FWTAnnotationArrow
@synthesize direction = _direction;

- (id)init
{
    if ((self = [super init]))
    {
        self.direction = FWTAnnotationArrowDirectionNone;
        self.size = CGSizeMake(10.0f, 10.0f);
        self.offset = .0f;
        self.cornerOffset = .0f;
    }
    return self;
}

- (UIEdgeInsets)adjustedEdgeInsetsForEdgeInsets:(UIEdgeInsets)edgeInsets
{
    UIEdgeInsets adjustedEdgeInsets = edgeInsets;
    CGFloat dY = self.size.height;
    
    if (self.direction & FWTAnnotationArrowDirectionUp)
        adjustedEdgeInsets.top += dY;
    else if (self.direction & FWTAnnotationArrowDirectionLeft)
        adjustedEdgeInsets.left += dY;
    else if (self.direction & FWTAnnotationArrowDirectionRight)
        adjustedEdgeInsets.right += dY;
    else if (self.direction & FWTAnnotationArrowDirectionDown)
        adjustedEdgeInsets.bottom += dY;
    
    return adjustedEdgeInsets;
}

@end
