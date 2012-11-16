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

@property (nonatomic, readwrite) CGColorRef fillColor;
@property (nonatomic, readwrite) CGImageRef maskImageRef;
@property (nonatomic, readwrite) CGImageRef accessoryImageRef;

- (void)presentAnimation:(void (^)(void))completionBlock;
- (void)dismissAnimation:(void (^)(void))completionBlock;

@end
