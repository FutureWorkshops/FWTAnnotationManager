//
//  FWTAnnotationModel.h
//  FWTAnnotationManager
//
//  Created by Marco Meschini on 09/11/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FWTAnnotation, FWTAnnotationView;
@interface FWTAnnotationModel : NSObject
@property (nonatomic, readonly, copy) NSArray *annotations;
@property (nonatomic, readonly) NSInteger numberOfAnnotations;

- (void)addAnnotation:(FWTAnnotation *)annotation withView:(FWTAnnotationView *)annotationView;
- (void)removeAnnotation:(FWTAnnotation *)annotation;

- (FWTAnnotationView *)viewForAnnotation:(FWTAnnotation *)annotation;
- (FWTAnnotation *)annotationForView:(FWTAnnotationView *)view;
- (FWTAnnotationView *)viewAtPoint:(CGPoint)point;

- (void)enumerateAnnotationsUsingBlock:(void (^)(FWTAnnotation *annotation, NSUInteger idx, BOOL *stop))block;

@end
