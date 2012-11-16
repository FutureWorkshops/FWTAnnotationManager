//
//  FWTPopoverController.h
//  FWTPopoverHintView
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FWTAnnotation, FWTAnnotationView, FWTAnnotationModel;

typedef NS_ENUM(NSInteger, FWTAnnotationsContainerViewType)
{
    FWTAnnotationsContainerViewTypeDefault,
    FWTAnnotationsContainerViewTypeRadial,
};

typedef FWTAnnotationView *(^FWTAnnotationManagerViewForAnnotationBlock)(FWTAnnotation *);
typedef void (^FWTAnnotationManagerDidTapAnnotationBlock)(FWTAnnotation *, FWTAnnotationView *);

@interface FWTAnnotationManager : NSObject

@property (nonatomic, assign) UIView *parentView;
@property (nonatomic, assign) FWTAnnotationsContainerViewType annotationsContainerViewType;     // configure the type before accessing any property
@property (nonatomic, readonly, retain) UIView *annotationsContainerView;                       // plug with your own class or just customize the default one
@property (nonatomic, readonly, retain) FWTAnnotationModel *model;
@property (nonatomic, copy) FWTAnnotationManagerViewForAnnotationBlock viewForAnnotationBlock;  //
@property (nonatomic, copy) FWTAnnotationManagerDidTapAnnotationBlock didTapAnnotationBlock;    //
@property (nonatomic, assign) BOOL dismissOnBackgroundTouch;                                    //  default is YES

- (void)addAnnotation:(FWTAnnotation *)annotation;
- (void)addAnnotations:(NSArray *)annotations;

- (void)removeAnnotation:(FWTAnnotation *)annotation;
- (void)removeAnnotations:(NSArray *)annotations;

//- (void)cancel;

- (BOOL)hasSuperview;

@end
