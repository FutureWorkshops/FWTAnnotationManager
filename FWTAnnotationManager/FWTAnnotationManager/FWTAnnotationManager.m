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

@interface FWTAnnotationManager () 

@property (nonatomic, assign) NSInteger needsToPresentCounter, needsToDismissCounter;
@property (nonatomic, readwrite, retain) FWTAnnotationModel *model;

@property (nonatomic, copy) FWTPopoverViewDidPresentBlock didPresentBlock;
@property (nonatomic, copy) FWTPopoverViewDidDismissBlock didDismissBlock;

@end

@implementation FWTAnnotationManager
@synthesize annotationsContainerView = _annotationsContainerView;

- (void)dealloc
{
    if (self.needsToPresentCounter > 0) [self cancel];
    self.didEndDismissBlock = nil;
    self.didEndPresentBlock = nil;
    self.didDismissBlock = nil;
    self.didPresentBlock = nil;
    self.didTapAnnotationBlock = nil;
    self.viewForAnnotationBlock = nil;
    self.model = nil;
    self.annotationsContainerView = nil;
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        self.needsToPresentCounter = 0;
        self.annotationContainerViewType = FWTAnnotationContainerViewTypeDefault;
        self.dismissOnBackgroundTouch = YES;
    }
    
    return self;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    __block typeof(self) myself = self;
    [self.model enumerateAnnotationsUsingBlock:^(FWTAnnotation *annotation, NSUInteger idx, BOOL *stop) {
        FWTAnnotationView *_popoverView = [myself.model viewForAnnotation:annotation];
        [_popoverView adjustPositionToRect:[annotation presentingRectForInterfaceOrientation:toInterfaceOrientation]];
    }];
}

#pragma mark - Getters
- (UIView *)annotationsContainerView
{
    if (!self->_annotationsContainerView)
    {
        BOOL isDefault = self.annotationContainerViewType == FWTAnnotationContainerViewTypeDefault ? YES : NO;
        Class class = isDefault ? [FWTAnnotationContainerView class] : [FWTRadialAnnotationsContainerView class];
        self->_annotationsContainerView = [[class alloc] init];
        self->_annotationsContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    
    return self->_annotationsContainerView;
}

- (FWTAnnotationModel *)model
{
    if (!self->_model) self->_model = [[FWTAnnotationModel alloc] init];
    return self->_model;
}

- (FWTAnnotationManagerViewForAnnotationBlock)viewForAnnotationBlock
{
    if (!self->_viewForAnnotationBlock)
        self->_viewForAnnotationBlock = [^(FWTAnnotation *annotation){
            return [[[FWTAnnotationView alloc] init] autorelease];
        } copy];
    
    return self->_viewForAnnotationBlock;
}

- (FWTPopoverViewDidPresentBlock)didPresentBlock
{
    if (!self->_didPresentBlock)
    {
        __block typeof(self) myself = self;
        self->_didPresentBlock = [^(FWTPopoverView *av){
            myself.needsToPresentCounter--;
            
            if (myself.needsToPresentCounter == 0 && self.didEndPresentBlock)
                self.didEndPresentBlock();
               
        } copy];
    }
    
    return self->_didPresentBlock;
}

- (FWTPopoverViewDidDismissBlock)didDismissBlock
{
    if (!self->_didDismissBlock)
    {
        __block typeof(self) myself = self;
        self->_didDismissBlock = [^(FWTPopoverView *av){
            // remove from model
            FWTAnnotation *annotation = [myself.model annotationForView:(FWTAnnotationView *)av];
            [myself.model removeAnnotation:annotation];
            
            myself.needsToDismissCounter--;
            
            // remove annotationsContainerView
            if (myself.model.numberOfAnnotations == 0 && myself.needsToDismissCounter == 0)
            {
                void (^completionBlock)(BOOL) = ^(BOOL finished){
                    [myself.annotationsContainerView removeFromSuperview];
                    [myself.view removeFromSuperview];
                    
                    myself.view.userInteractionEnabled = YES;
                    if (self.didEndDismissBlock) self.didEndDismissBlock();
                };
                
                if ([myself _annotationsContainerViewNeedsAnimation])
                    [UIView animateWithDuration:.2f
                                     animations:^{ myself.annotationsContainerView.alpha = .0f; }
                                     completion:completionBlock];
                else
                    completionBlock(YES);
            }
            else if (myself.needsToDismissCounter == 0)
            {
                myself.view.userInteractionEnabled = YES;
            }
            
        } copy];
    }
    
    return self->_didDismissBlock;
}

#pragma mark - UIResponder
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _didTouchAtPoint:[[touches anyObject] locationInView:self.view]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _didTouchAtPoint:[[touches anyObject] locationInView:self.view]];
}

#pragma mark - Private 
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

- (void)_didTouchAtPoint:(CGPoint)point
{
    if (self.needsToPresentCounter != 0 || !self.view.userInteractionEnabled) return;
    self.view.userInteractionEnabled = NO;
    
    //
    FWTAnnotationView *_annotationView = [self.model viewAtPoint:point];
    FWTAnnotation *_annotation = [self.model annotationForView:_annotationView];
    
    // give user a chance
    if (self.didTapAnnotationBlock) self.didTapAnnotationBlock(_annotation, _annotationView);
    
    //
    if (_annotationView && _annotation.dismissOnTouch)
    {
        self.needsToDismissCounter = 1;
        [self removeAnnotation:_annotation];
    }
    else if (!_annotationView && self.dismissOnBackgroundTouch)
    {
        self.needsToDismissCounter = self.model.numberOfAnnotations;
        [self removeAnnotations:self.model.annotations];
    }
}

#pragma mark - Public
- (void)addAnnotation:(FWTAnnotation *)annotation
{
    //  add the containerView if needed
    [self _setupViews];
        
    //  get an annotationView
    FWTAnnotationView *annotationView = self.viewForAnnotationBlock(annotation);
    annotationView.didPresentBlock = self.didPresentBlock;   // keep track of what happens
    annotationView.didDismissBlock = self.didDismissBlock;   //
    //  configure
    if (annotation.text) annotationView.textLabel.text = annotation.text;
    if (annotation.image) annotationView.imageView.image = annotation.image;
    annotationView.animationHelper.presentDelay = annotation.delay;
    
    //  update model
    [self.model addAnnotation:annotation withView:annotationView];
    
    //  update animation counter
    self.needsToPresentCounter++;
    
    //
    [self.annotationsContainerView addAnnotation:annotation withView:annotationView];
    
    //  ready to present
    [annotationView presentFromRect:[annotation presentingRectForInterfaceOrientation:self.interfaceOrientation]
                             inView:self.annotationsContainerView
            permittedArrowDirection:annotation.arrowDirection
                           animated:annotation.animated];
}

- (void)addAnnotations:(NSArray *)annotations
{
    [annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addAnnotation:obj];
    }];
}

- (void)removeAnnotation:(FWTAnnotation *)annotation
{
    FWTAnnotationView *annotationView = [self.model viewForAnnotation:annotation];
    if (annotationView)
    {
        [self.annotationsContainerView removeAnnotation:annotation withView:annotationView];
        [annotationView dismissPopoverAnimated:annotation.animated];
    }
}

- (void)removeAnnotations:(NSArray *)annotations
{    
    NSArray *arrayCopy = self.model.annotations;
    [arrayCopy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self removeAnnotation:obj];
    }];
}

- (void)cancel
{
    [self.annotationsContainerView cancel];
    
    NSArray *arrayCopy = self.model.annotations;
    [arrayCopy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FWTAnnotationView *_popoverView = [self.model viewForAnnotation:obj];
        if (_popoverView)
        {
            [_popoverView dismissPopoverAnimated:NO];
        }
        [self.model removeAnnotation:obj];
    }];
}

- (BOOL)isVisible
{
    return self.annotationsContainerView.superview != nil;
}

@end
