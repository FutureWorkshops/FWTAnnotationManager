//
//  FWTPopoverController.h
//  FWTPopoverHintView
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FWTDefaultAnnotationView.h"
#import "FWTAnnotation.h"

@class FWTAnnotationManager;
@protocol FWTAnnotationManagerDelegate <NSObject>

@optional
- (FWTDefaultAnnotationView *)annotationManager:(FWTAnnotationManager *)annotationManager viewForAnnotation:(FWTAnnotation *)annotation;
- (void)annotationManager:(FWTAnnotationManager *)annotationManager didTapAnnotationView:(FWTDefaultAnnotationView *)annotationView annotation:(FWTAnnotation *)annotation;

@end

@interface FWTAnnotationManager : NSObject

@property (nonatomic, retain) UIView *parentView;
@property (nonatomic, readonly, copy) NSArray *annotations;
@property (nonatomic, assign) id<FWTAnnotationManagerDelegate> delegate;

- (void)addAnnotation:(FWTAnnotation *)annotation;
- (void)addAnnotations:(NSArray *)annotations;

- (void)removeAnnotation:(FWTAnnotation *)annotation;
- (void)removeAnnotations:(NSArray *)annotations;

- (FWTDefaultAnnotationView *)viewForAnnotation:(FWTAnnotation *)annotation;
- (FWTAnnotation *)annotationForView:(FWTDefaultAnnotationView *)view;
- (FWTDefaultAnnotationView *)viewAtPoint:(CGPoint)point;

- (void)cancel;

- (BOOL)hasSuperview;

@end
