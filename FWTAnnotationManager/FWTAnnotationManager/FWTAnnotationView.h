//
//  FWTPopoverHintView.h
//  FWTPopoverHintView
//
//  Created by Marco Meschini on 7/12/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FWTAnnotationBackgroundImageHelper.h"
#import "FWTAnnotationArrow.h"

enum {
    FWTAnnotationArrowDirectionNone = 1UL << 0,
    FWTAnnotationArrowDirectionUp = 1UL << 1,
    FWTAnnotationArrowDirectionDown = 1UL << 2,
    FWTAnnotationArrowDirectionLeft = 1UL << 3,
    FWTAnnotationArrowDirectionRight = 1UL << 4,
};
typedef NSUInteger FWTAnnotationArrowDirection;

@class FWTAnnotationView;
typedef void (^FWTAnnotationViewDrawBezierPathBlock)(CGContextRef, FWTAnnotationView *);
typedef void (^FWTAnnotationViewPrepareToAnimationsBlock)(void);
typedef void (^FWTAnnotationViewAnimationsBlock)(void);
typedef void (^FWTAnnotationViewCompletionBlock)(BOOL finished);

@interface FWTAnnotationView : UIView
{    
    //
    FWTAnnotationArrowDirection _arrowDirection;
        
    //
    FWTAnnotationViewDrawBezierPathBlock _drawPathBlock;
    FWTAnnotationViewPrepareToAnimationsBlock _prepareToAnimationsBlock;
    FWTAnnotationViewAnimationsBlock _presentAnimationsBlock, _dismissAnimationsBlock;
    FWTAnnotationViewCompletionBlock _presentCompletionBlock, _dismissCompletionBlock;
    
    //
    CGFloat _animationDuration;
    UIView *_contentView;
    UIEdgeInsets _edgeInsets, _desiredEdgeInsets;
    CGSize _contentSize;
    
    //
    BOOL _adjustPositionInSuperviewEnabled;
}

@property (nonatomic, assign) UIEdgeInsets edgeInsets, desiredEdgeInsets;

@property (nonatomic, assign) CGSize contentSize;

@property (nonatomic, readonly) FWTAnnotationArrowDirection arrowDirection;

@property (nonatomic, copy) FWTAnnotationViewDrawBezierPathBlock drawPathBlock;
@property (nonatomic, copy) FWTAnnotationViewPrepareToAnimationsBlock prepareToAnimationsBlock;
@property (nonatomic, copy) FWTAnnotationViewAnimationsBlock presentAnimationsBlock, dismissAnimationsBlock;
@property (nonatomic, copy) FWTAnnotationViewCompletionBlock presentCompletionBlock, dismissCompletionBlock;

@property (nonatomic, assign) CGFloat animationDuration;

@property (nonatomic, readonly, retain) UIView *contentView;

@property (nonatomic, assign) BOOL adjustPositionInSuperviewEnabled;

@property (nonatomic, readonly, retain) FWTAnnotationBackgroundImageHelper *backgroundImageHelper;
@property (nonatomic, readonly, retain) FWTAnnotationArrow *arrow;

//
- (void)presentAnnotationFromRect:(CGRect)rect
                           inView:(UIView *)view
          permittedArrowDirection:(FWTAnnotationArrowDirection)arrowDirection
                         animated:(BOOL)animated;

//
- (void)dismissPopoverAnimated:(BOOL)animated;

//
- (UIBezierPath *)bezierPathForRect:(CGRect)rect;

//
- (UIImage *)backgroundImageForSize:(CGSize)size;

@end
