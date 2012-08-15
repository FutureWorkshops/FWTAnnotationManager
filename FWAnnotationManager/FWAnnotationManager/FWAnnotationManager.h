//
//  FWPopoverController.h
//  FWPopoverHintView
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FWAnnotationView.h"
#import "FWAnnotation.h"

@class FWAnnotationManager;
@protocol FWAnnotationManagerDelegate <NSObject>
@optional
- (FWAnnotationView *)popoverController:(FWAnnotationManager *)popoverController viewForAnnotation:(FWAnnotation *)annotation;
- (void)popoverController:(FWAnnotationManager *)popoverController didTapPopoverView:(FWAnnotationView *)popoverView annotation:(FWAnnotation *)annotation;
@end

@interface FWAnnotationManager : NSObject
{
    UIView *_view, *_contentView;
    NSMutableArray *_annotations;
    NSMutableDictionary *_annotationsDictionary;
    UITapGestureRecognizer *_tapGestureRecognizer;
    
    id<FWAnnotationManagerDelegate> _delegate;
    struct
    {
        BOOL viewForAnnotation: 1;
        BOOL didTapPopoverView: 1;
    } _delegateHas;
    
    BOOL _removePopoverAnnotationsWithRandomDelay;
}

@property (nonatomic, retain) UIView *view;
@property (nonatomic, readonly, retain) NSMutableArray *annotations;
@property (nonatomic, assign) id<FWAnnotationManagerDelegate> delegate;
@property (nonatomic, assign) BOOL removePopoverAnnotationsWithRandomDelay;

- (void)addPopoverAnnotation:(FWAnnotation *)annotation;
- (void)addPopoverAnnotations:(NSArray *)annotations;

- (void)removePopoverAnnotation:(FWAnnotation *)annotation;
- (void)removePopoverAnnotations:(NSArray *)annotations;

- (FWAnnotationView *)viewForAnnotation:(FWAnnotation *)annotation;
- (FWAnnotationView *)viewAtPoint:(CGPoint)point;

- (FWAnnotation *)annotationForView:(FWAnnotationView *)view;

- (void)cancel;

- (BOOL)hasSuperview;

@end
