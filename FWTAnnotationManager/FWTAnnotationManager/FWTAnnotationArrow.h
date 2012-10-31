//
//  FWTAnnotationArrow.h
//  FWTAnnotationManager
//
//  Created by Marco Meschini on 30/10/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FWTAnnotationArrowDirection) {
    FWTAnnotationArrowDirectionNone = 1UL << 0,
    FWTAnnotationArrowDirectionUp = 1UL << 1,
    FWTAnnotationArrowDirectionDown = 1UL << 2,
    FWTAnnotationArrowDirectionLeft = 1UL << 3,
    FWTAnnotationArrowDirectionRight = 1UL << 4,
};

@interface FWTAnnotationArrow : NSObject

@property (nonatomic, readonly, assign) FWTAnnotationArrowDirection direction;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGFloat cornerOffset;

- (UIEdgeInsets)adjustedEdgeInsetsForEdgeInsets:(UIEdgeInsets)edgeInsets;

@end
