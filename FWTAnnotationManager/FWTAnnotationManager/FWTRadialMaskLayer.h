//
//  FWTRadialMaskLayer.h
//  FWTAnnotationManager
//
//  Created by Marco Meschini on 11/11/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface FWTRadialMaskLayer : CALayer
@property (nonatomic, retain) UIColor *fillColor;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, retain) UIImage *maskImage;

- (void)setValue:(CGFloat)value animated:(BOOL)animated;

@end
