//
//  FWTAnnotationModel.h
//  FWTAnnotationManager
//
//  Created by Marco Meschini on 09/11/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FWTAnnotation, FWTDefaultAnnotationView;
@interface FWTAnnotationModel : NSObject
@property (nonatomic, readonly, copy) NSArray *annotations;
@property (nonatomic, readonly) NSInteger numberOfAnnotations;

- (void)addAnnotation:(FWTAnnotation *)annotation withView:(FWTDefaultAnnotationView *)annotationView;
- (void)removeAnnotation:(FWTAnnotation *)annotation;

- (FWTDefaultAnnotationView *)viewForAnnotation:(FWTAnnotation *)annotation;
- (FWTAnnotation *)annotationForView:(FWTDefaultAnnotationView *)view;
- (FWTDefaultAnnotationView *)viewAtPoint:(CGPoint)point;

- (void)enumerateAnnotationsUsingBlock:(void (^)(FWTAnnotation *annotation, NSUInteger idx, BOOL *stop))block;

@end
