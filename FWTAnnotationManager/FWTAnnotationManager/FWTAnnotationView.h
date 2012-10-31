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

@class FWTAnnotationView;

typedef void (^FWTAnnotationViewPrepareToAnimationsBlock)(void);
typedef void (^FWTAnnotationViewAnimationsBlock)(void);
typedef void (^FWTAnnotationViewCompletionBlock)(BOOL finished);

@interface FWTAnnotationView : UIView

@property (nonatomic, readonly, retain) UIView *contentView;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) BOOL adjustPositionInSuperviewEnabled;

@property (nonatomic, copy) FWTAnnotationViewPrepareToAnimationsBlock prepareToAnimationsBlock;
@property (nonatomic, copy) FWTAnnotationViewAnimationsBlock presentAnimationsBlock, dismissAnimationsBlock;
@property (nonatomic, copy) FWTAnnotationViewCompletionBlock presentCompletionBlock, dismissCompletionBlock;
@property (nonatomic, assign) CGFloat animationDuration;

@property (nonatomic, retain) FWTAnnotationBackgroundHelper *backgroundHelper;
@property (nonatomic, retain) FWTAnnotationArrow *arrow;

//
- (void)presentAnnotationFromRect:(CGRect)rect
                           inView:(UIView *)view
          permittedArrowDirection:(FWTAnnotationArrowDirection)arrowDirection
                         animated:(BOOL)animated;

//
- (void)dismissPopoverAnimated:(BOOL)animated;

@end
