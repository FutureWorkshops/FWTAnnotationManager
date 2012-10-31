//
//  FWTPopoverHintView.h
//  FWTPopoverHintView
//
//  Created by Marco Meschini on 7/12/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FWTAnnotationArrow.h"
#import "FWTAnnotationBackgroundHelper.h"
#import "FWTAnnotationAnimationHelper.h"

@class FWTAnnotationView;
@protocol FWTAnnotationViewDelegate <NSObject>
@optional
- (void)annotationViewDidPresent:(FWTAnnotationView *)annotationView;
- (void)annotationViewDidDismiss:(FWTAnnotationView *)annotationView;
@end


@interface FWTAnnotationView : UIView

@property (nonatomic, readonly, retain) UIView *contentView;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) BOOL adjustPositionInSuperviewEnabled;

@property (nonatomic, retain) FWTAnnotationBackgroundHelper *backgroundHelper;
@property (nonatomic, retain) FWTAnnotationArrow *arrow;
@property (nonatomic, retain) FWTAnnotationAnimationHelper *animationHelper;

@property (nonatomic, assign) id<FWTAnnotationViewDelegate> delegate;

//
- (void)presentAnnotationFromRect:(CGRect)rect
                           inView:(UIView *)view
          permittedArrowDirection:(FWTAnnotationArrowDirection)arrowDirection
                         animated:(BOOL)animated;

//
- (void)dismissPopoverAnimated:(BOOL)animated;

@end
