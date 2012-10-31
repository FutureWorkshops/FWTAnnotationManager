//
//  FWTAnnotationBackgroundHelper.h
//  FWTAnnotationManager
//
//  Created by Marco Meschini on 31/10/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class FWTAnnotationView, FWTAnnotationBackgroundHelper;

typedef void (^FWTAnnotationViewDrawBezierPathBlock)(CGContextRef, FWTAnnotationBackgroundHelper *);

@interface FWTAnnotationBackgroundHelper : CAShapeLayer

@property (nonatomic, readonly, assign) FWTAnnotationView *annotationView;
@property (nonatomic, copy) FWTAnnotationViewDrawBezierPathBlock drawPathBlock;
@property (nonatomic, readonly, assign) CGRect pathFrame;

- (id)initWithAnnotationView:(FWTAnnotationView *)annotationView;

- (UIImage *)resizableBackgroundImageForSize:(CGSize)size edgeInsets:(UIEdgeInsets)edgeInsets;

- (UIBezierPath *)bezierPathForRect:(CGRect)rect;

@end
