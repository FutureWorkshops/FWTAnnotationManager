//
//  FWTAnnotationArrow.m
//  FWTAnnotationManager
//
//  Created by Marco Meschini on 30/10/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import "FWTAnnotationArrow.h"

@implementation FWTAnnotationArrow

- (id)init
{
    if ((self = [super init]))
    {
        self.arrowSize = CGSizeMake(10.0f, 10.0f);
        self.arrowOffset = .0f;
        self.arrowCornerOffset = .0f;
    }
    return self;
}

@end
