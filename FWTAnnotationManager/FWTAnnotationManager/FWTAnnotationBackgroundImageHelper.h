//
//  FWTAnnotationBackgroundImage.h
//  FWTAnnotationManager
//
//  Created by Marco Meschini on 30/10/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FWTAnnotationView;

@interface FWTAnnotationBackgroundImageHelper : NSObject

@property (nonatomic, readonly, assign) FWTAnnotationView *annotationView;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, readonly, retain) UIBezierPath *bezierPath;
@property (nonatomic, retain) UIColor *bezierPathColorFill, *bezierPathColorStroke;
@property (nonatomic, assign) CGFloat bezierPathLineWidth;
@property (nonatomic, assign) CGFloat shadowBlur;
@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, retain) UIColor *shadowColor;


- (id)initWithAnnotationView:(FWTAnnotationView *)annotationView;

- (UIImage *)resizableBackgroundImageForSize:(CGSize)size;

@end
