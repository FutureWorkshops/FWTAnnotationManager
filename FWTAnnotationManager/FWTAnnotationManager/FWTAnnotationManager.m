//
//  FWTPopoverController.m
//  FWTPopoverHintView
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "FWTAnnotationManager.h"
#import "FWTAnnotationModel.h"
#import "FWTRadialAnnotationsContainerView.h"
#import "FWTAnnotationView.h"
#import "FWTAnnotation.h"

@interface FWTAnnotationManager () <FWTPopoverViewDelegate>

@property (nonatomic, readwrite, retain) UIView *annotationsContainerView;
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, assign) NSInteger popoverViewDidPresentCounter;
@property (nonatomic, retain) id orientationObserver;
@property (nonatomic, readwrite, retain) FWTAnnotationModel *model;

@end

@implementation FWTAnnotationManager
@synthesize annotationsContainerView = _annotationsContainerView;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;

- (void)dealloc
{
    self.didTapAnnotationBlock = nil;
    self.viewForAnnotationBlock = nil;
    self.model = nil;
    self.orientationObserver = nil;
    self.tapGestureRecognizer = nil;
    self.annotationsContainerView = nil;
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        self.popoverViewDidPresentCounter = 0;
        self.annotationsContainerViewType = FWTAnnotationsContainerViewTypeDefault;
        self.viewForAnnotationBlock = ^(FWTAnnotation *annotation){
          return [[[FWTAnnotationView alloc] init] autorelease];
        };
        self.dismissOnBackgroundTouch = YES;
    }
    
    return self;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    __block typeof(self) myself = self;
    [self.model enumerateAnnotationsUsingBlock:^(FWTAnnotation *annotation, NSUInteger idx, BOOL *stop) {
        FWTAnnotationView *_popoverView = [myself.model viewForAnnotation:annotation];
        [_popoverView adjustPositionToRect:[myself _presentingRectForAnnotation:annotation]];
    }];
}

#pragma mark - Getters
- (UIView *)annotationsContainerView
{
    if (!self->_annotationsContainerView)
    {
        Class class = self.annotationsContainerViewType == FWTAnnotationsContainerViewTypeDefault ? [UIView class] : [FWTRadialAnnotationsContainerView class];
        self->_annotationsContainerView = [[class alloc] init];
        self->_annotationsContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    
    return self->_annotationsContainerView;
}

- (UITapGestureRecognizer *)tapGestureRecognizer
{
    if (!self->_tapGestureRecognizer) self->_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleGesture:)];
    return self->_tapGestureRecognizer;
}

- (FWTAnnotationModel *)model
{
    if (!self->_model) self->_model = [[FWTAnnotationModel alloc] init];
    return self->_model;
}

#pragma mark - UIResponder
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.popoverViewDidPresentCounter != 0) return;
    
    CGPoint point = [[touches anyObject] locationInView:self.view];
    FWTAnnotationView *_annotationView = [self.model viewAtPoint:point];
    FWTAnnotation *_annotation = [self.model annotationForView:_annotationView];
    
    // give user a chance
    if (self.didTapAnnotationBlock) self.didTapAnnotationBlock(_annotation, _annotationView);
    
    //
    if (_annotationView && _annotation.dismissOnTouch)
        [self removeAnnotation:_annotation];
    else if (!_annotationView && self.dismissOnBackgroundTouch)
        [self removeAnnotations:self.model.annotations];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.popoverViewDidPresentCounter != 0) return;
    
    CGPoint point = [[touches anyObject] locationInView:self.view];
    FWTAnnotationView *_annotationView = [self.model viewAtPoint:point];
    FWTAnnotation *_annotation = [self.model annotationForView:_annotationView];
    
    // give user a chance
    if (self.didTapAnnotationBlock) self.didTapAnnotationBlock(_annotation, _annotationView);
    
    //
    if (_annotationView && _annotation.dismissOnTouch)
        [self removeAnnotation:_annotation];
    else if (!_annotationView && self.dismissOnBackgroundTouch)
        [self removeAnnotations:self.model.annotations];
}

#pragma mark - Actions
- (void)_handleGesture:(UIGestureRecognizer *)gesture
{
    FWTAnnotationView *_annotationView = [self.model viewAtPoint:[gesture locationInView:gesture.view]];
    FWTAnnotation *_annotation = [self.model annotationForView:_annotationView];
    
    // give user a chance
    if (self.didTapAnnotationBlock) self.didTapAnnotationBlock(_annotation, _annotationView);
    
    //
    if (_annotationView && _annotation.dismissOnTouch)
        [self removeAnnotation:_annotation];
    else if (!_annotationView && self.dismissOnBackgroundTouch)
        [self removeAnnotations:self.model.annotations];
}

#pragma mark - Private 
- (CGRect)_presentingRectForAnnotation:(FWTAnnotation *)annotation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect rect = CGRectZero;
    rect = UIInterfaceOrientationIsLandscape(orientation) ? annotation.presentingRectLandscape : annotation.presentingRectPortrait;    
    return rect;
}

- (void)_setupViews
{
    if (![self isViewLoaded] || !self.view.superview)
    {
        [self.parentViewController.view addSubview:self.view];
        self.view.frame = self.parentViewController.view.bounds;
    }
    
    if (!self.annotationsContainerView.superview)
    {
        BOOL needsAnimation = [self _annotationsContainerViewNeedsAnimation];
        if (needsAnimation) self.annotationsContainerView.alpha = .0f;
        [self.view addSubview:self.annotationsContainerView];
        self.annotationsContainerView.frame = self.view.bounds;
        if (needsAnimation) [UIView animateWithDuration:.2f animations:^{ self.annotationsContainerView.alpha = 1.0f; }];
    }
}

- (BOOL)_annotationsContainerViewNeedsAnimation
{
    return self.annotationsContainerView.backgroundColor != nil;
}

#pragma mark - Public
- (void)addAnnotation:(FWTAnnotation *)annotation
{
    //  add the containerView if needed
    [self _setupViews];
    
    //  add the gesture
//    if (!self.tapGestureRecognizer.view) [self.annotationsContainerView addGestureRecognizer:self.tapGestureRecognizer];
//    self.tapGestureRecognizer.enabled = NO;
    
    //  get an annotationView
    FWTAnnotationView *annotationView = self.viewForAnnotationBlock(annotation);
    annotationView.delegate = self;
    
    //  configure
    if (annotation.text) annotationView.textLabel.text = annotation.text;
    if (annotation.image) annotationView.imageView.image = annotation.image;
    annotationView.animationHelper.presentDelay = annotation.delay;
    
    //  update model
    [self.model addAnnotation:annotation withView:annotationView];
    
    //  update animation counter
    self.popoverViewDidPresentCounter++;
    
    //
    if (self.annotationsContainerViewType == FWTAnnotationsContainerViewTypeRadial)
        [(FWTRadialAnnotationsContainerView *)self.annotationsContainerView addAnnotationView:annotationView];
    
    //  ready to present
    CGRect rect = [self _presentingRectForAnnotation:annotation];
    [annotationView presentFromRect:rect inView:self.annotationsContainerView permittedArrowDirection:annotation.arrowDirection animated:annotation.animated];
}

- (void)addAnnotations:(NSArray *)annotations
{
    [annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addAnnotation:obj];
    }];
}

- (void)removeAnnotation:(FWTAnnotation *)annotation
{
    FWTAnnotationView *_popoverView = [self.model viewForAnnotation:annotation];
    if (_popoverView)
    {
        if (self.annotationsContainerViewType == FWTAnnotationsContainerViewTypeRadial)
            [(FWTRadialAnnotationsContainerView *)self.annotationsContainerView removeAnnotationView:_popoverView];
        
        [_popoverView dismissPopoverAnimated:annotation.animated];
    }
}

- (void)removeAnnotations:(NSArray *)annotations
{    
    NSArray *arrayCopy = self.model.annotations;
    [arrayCopy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self removeAnnotation:obj];
    }];
}

- (BOOL)hasSuperview
{
    return self.annotationsContainerView.superview != nil;
}

#pragma mark - FWTPopoverViewDelegate
- (void)popoverViewDidPresent:(FWTPopoverView *)annotationView
{    
    self.popoverViewDidPresentCounter--;
    if (self.popoverViewDidPresentCounter == 0)
    {
        self.tapGestureRecognizer.enabled = YES;
    }
}

- (void)popoverViewDidDismiss:(FWTPopoverView *)annotationView
{
    FWTAnnotation *annotation = [self.model annotationForView:(FWTAnnotationView *)annotationView];
    [self.model removeAnnotation:annotation];

    //
    if (self.model.numberOfAnnotations == 0)
    {
        void (^completionBlock)(BOOL) = ^(BOOL finished){
            [self.annotationsContainerView removeFromSuperview];
            [self.view removeFromSuperview];
        };
        
        if ([self _annotationsContainerViewNeedsAnimation])
            [UIView animateWithDuration:.2f
                             animations:^{ self.annotationsContainerView.alpha = .0f; }
                             completion:completionBlock];
        else
            completionBlock(YES);
    }
}

@end
