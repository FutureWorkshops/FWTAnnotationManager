//
//  FWTPopoverController.h
//  FWTPopoverHintView
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FWTAnnotation.h"
#import "FWTAnnotationView.h"
#import "FWTAnnotationModel.h"
#import "FWTAnnotationContainerView.h"

typedef NS_ENUM(NSInteger, FWTAnnotationContainerViewType)
{
    FWTAnnotationContainerViewTypeDefault,
    FWTAnnotationContainerViewTypeRadial,
};

typedef FWTAnnotationView *(^FWTAnnotationManagerViewForAnnotationBlock)(FWTAnnotation *);
typedef void (^FWTAnnotationManagerDidTapAnnotationBlock)(FWTAnnotation *, FWTAnnotationView *);

@interface FWTAnnotationManager : UIViewController

@property (nonatomic, assign) FWTAnnotationContainerViewType annotationContainerViewType;       // configure the type before accessing any property
@property (nonatomic, retain) FWTAnnotationContainerView *annotationsContainerView;             // plug with your own class or just customize the default one
@property (nonatomic, readonly, retain) FWTAnnotationModel *model;
@property (nonatomic, copy) FWTAnnotationManagerViewForAnnotationBlock viewForAnnotationBlock;  //
@property (nonatomic, copy) FWTAnnotationManagerDidTapAnnotationBlock didTapAnnotationBlock;    //
@property (nonatomic, assign) BOOL dismissOnBackgroundTouch;                                    //  default is YES
@property (nonatomic, readonly, getter=isVisible) BOOL visible;

- (void)addAnnotation:(FWTAnnotation *)annotation;
- (void)addAnnotations:(NSArray *)annotations;

- (void)removeAnnotation:(FWTAnnotation *)annotation;
- (void)removeAnnotations:(NSArray *)annotations;

- (void)cancel;

@end

@interface FWTAnnotationModel (Public)

- (FWTAnnotationView *)viewForAnnotation:(FWTAnnotation *)annotation;
- (FWTAnnotation *)annotationForView:(FWTAnnotationView *)view;
- (FWTAnnotationView *)viewAtPoint:(CGPoint)point;

@end

@interface FWTAnnotationContainerView (Public)

- (void)addAnnotation:(FWTAnnotation *)annotation withView:(FWTAnnotationView *)annotationView;
- (void)removeAnnotation:(FWTAnnotation *)annotation withView:(FWTAnnotationView *)annotationView;
- (void)cancel;

@end