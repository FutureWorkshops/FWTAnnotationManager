//
//  FWTPopoverController.h
//  FWTPopoverHintView
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FWTAnnotationView.h"
#import "FWTAnnotation.h"
#import "FWTAnnotationModel.h"

typedef NS_ENUM(NSInteger, FWTAnnotationsContainerViewType) {
    FWTAnnotationsContainerViewTypeDefault,
    FWTAnnotationsContainerViewTypeRadial,
};

@class FWTAnnotationManager;
@protocol FWTAnnotationManagerDelegate <NSObject>

@optional
- (FWTAnnotationView *)annotationManager:(FWTAnnotationManager *)annotationManager viewForAnnotation:(FWTAnnotation *)annotation;
- (void)annotationManager:(FWTAnnotationManager *)annotationManager didTapAnnotationView:(FWTAnnotationView *)annotationView annotation:(FWTAnnotation *)annotation;

@end

@interface FWTAnnotationManager : NSObject

@property (nonatomic, retain) UIView *parentView;
@property (nonatomic, assign) FWTAnnotationsContainerViewType annotationsContainerViewType; //  configure the type before accessing any property
@property (nonatomic, readonly, retain) UIView *annotationsContainerView;   //  plug with your own class or just customize the default one
@property (nonatomic, assign) id<FWTAnnotationManagerDelegate> delegate;
@property (nonatomic, readonly, retain) FWTAnnotationModel *model;

- (void)addAnnotation:(FWTAnnotation *)annotation;
- (void)addAnnotations:(NSArray *)annotations;

- (void)removeAnnotation:(FWTAnnotation *)annotation;
- (void)removeAnnotations:(NSArray *)annotations;

//- (void)cancel;

- (BOOL)hasSuperview;

@end
