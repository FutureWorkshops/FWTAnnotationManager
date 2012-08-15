//
//  FWTPopoverController.m
//  FWTPopoverHintView
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "FWTAnnotationManager.h"
#import "FWTAnnotationView.h"
#import "FWTDefaultAnnotationView.h"

@interface FWTAnnotationManager ()
{
    NSInteger _presentAnimationsCounter;
    BOOL _animationsDisabled;
    BOOL _registeredToStatusBarOrientationNotification;
}

@property (nonatomic, readwrite, retain) NSMutableArray *annotations;
@property (nonatomic, retain) NSMutableDictionary *annotationsDictionary;
@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, assign) NSInteger presentAnimationsCounter;
@property (nonatomic, assign) BOOL animationsDisabled;
@property (nonatomic, assign) BOOL registeredToStatusBarOrientationNotification;

//  Actions
- (void)handleGesture:(UIGestureRecognizer *)gesture;

//  Private
- (void)presentPopoverViewForPopoverDescriptor:(FWTAnnotation *)annotation;
- (void)registerToStatusBarOrientationNotifications;
- (void)unregisterFromStatusBarOrientationNotifications;

//  UIApplicationDidChangeStatusBarOrientationNotification
- (void)updatePopoverAnnotationsToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end

@implementation FWTAnnotationManager
@synthesize view = _view;
@synthesize annotations = _annotations;
@synthesize annotationsDictionary = _annotationsDictionary;
@synthesize delegate = _delegate;
@synthesize contentView = _contentView;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize presentAnimationsCounter = _presentAnimationsCounter;
@synthesize animationsDisabled = _animationsDisabled;
@synthesize registeredToStatusBarOrientationNotification = _registeredToStatusBarOrientationNotification;
@synthesize removeAnnotationsWithRandomDelay = _removeAnnotationsWithRandomDelay;

- (void)dealloc
{
    [self unregisterFromStatusBarOrientationNotifications];
    self.tapGestureRecognizer = nil;
    self.contentView = nil;
    self.delegate = nil;
    self.annotations = nil;
    self.annotationsDictionary = nil;
    self.view = nil;
    [super dealloc];
}

#pragma mark - Setters
- (void)setDelegate:(id<FWTAnnotationManagerDelegate>)delegate
{
    if (self->_delegate != delegate)
    {
        self->_delegate = delegate;
        if (self->_delegate)
        {
            _delegateHas.viewForAnnotation = [self->_delegate respondsToSelector:@selector(annotationManager:viewForAnnotation:)];
            _delegateHas.didTapAnnotationView = [self->_delegate respondsToSelector:@selector(annotationManager:didTapAnnotationView:annotation:)];
        }
        else
        {
            _delegateHas.viewForAnnotation = NO;
            _delegateHas.didTapAnnotationView = NO;
        }
    }
}

#pragma mark - Getters
- (NSMutableArray *)annotations
{
    if (!self->_annotations)
        self->_annotations = [[NSMutableArray alloc] init];
    
    return self->_annotations;
}

- (NSMutableDictionary *)annotationsDictionary
{
    if (!self->_annotationsDictionary)
        self->_annotationsDictionary = [[NSMutableDictionary alloc] init];
    
    return self->_annotationsDictionary;
}

- (UIView *)contentView
{
    if (!self->_contentView)
    {
        self->_contentView = [[UIView alloc] init];
        self->_contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    
    return self->_contentView;
}

- (UITapGestureRecognizer *)tapGestureRecognizer
{
    if (!self->_tapGestureRecognizer)
        self->_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    
    return self->_tapGestureRecognizer;
}

#pragma mark - Actions
- (void)handleGesture:(UIGestureRecognizer *)gesture
{
    if (_delegateHas.didTapAnnotationView)
    {
        CGPoint point = [gesture locationInView:gesture.view];
        FWTAnnotationView *_popoverView = [self viewAtPoint:point];
        FWTAnnotation *_annotation = [self annotationForView:_popoverView];
        [self.delegate annotationManager:self didTapAnnotationView:_popoverView annotation:_annotation];
    }
}

#pragma mark - Private
- (void)presentPopoverViewForPopoverDescriptor:(FWTAnnotation *)annotation
{
    FWTAnnotationView *_popoverView = [self viewForAnnotation:annotation];
    FWTAnnotationViewCompletionBlock currentCompletionBlock = NULL;
    if (_popoverView.presentCompletionBlock)
        currentCompletionBlock = _popoverView.presentCompletionBlock;
    
    FWTAnnotationViewCompletionBlock completionBlock = ^(BOOL finished){
      if (currentCompletionBlock)
          currentCompletionBlock(finished);
        
        self.presentAnimationsCounter--;
        if (self.presentAnimationsCounter == 0)
        {
            self.tapGestureRecognizer.enabled = YES;
        }
    };
    
    _popoverView.presentCompletionBlock = completionBlock;
    
    CGRect rect = CGRectZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if UIInterfaceOrientationIsLandscape(orientation)
        rect = annotation.presentingRectLandscape;
    else 
        rect = annotation.presentingRectPortrait;
    
    BOOL animated = self.animationsDisabled ? YES : annotation.animated;
    
    [_popoverView presentAnnotationFromRect:rect
                                  inView:self.contentView
                 permittedArrowDirection:annotation.arrowDirection
                                animated:animated];
}

- (void)registerToStatusBarOrientationNotifications
{
    if (!self.registeredToStatusBarOrientationNotification)
    {
        //
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeStatusBarOrientation:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
        
        self.registeredToStatusBarOrientationNotification = YES;
    }
}

- (void)unregisterFromStatusBarOrientationNotifications
{
    if (self.registeredToStatusBarOrientationNotification)
    {
        //
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidChangeStatusBarOrientationNotification
                                                      object:nil];
        
        self.registeredToStatusBarOrientationNotification = NO;
    }
}

- (void)updatePopoverAnnotationsToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    NSArray *arrayCopy = [NSArray arrayWithArray:self.annotations];
    [arrayCopy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FWTAnnotationView *_popoverView = [self viewForAnnotation:obj];
        if (_popoverView)
        {
            [self.annotations removeObject:obj];
            [self.annotationsDictionary removeObjectForKey:[obj description]];
            [_popoverView removeFromSuperview];
        }
    }];
    
    self.animationsDisabled = YES;
    [self addAnnotations:arrayCopy];
    self.animationsDisabled = NO;
}

#pragma mark - UIApplicationDidChangeStatusBarOrientationNotification
- (void)didChangeStatusBarOrientation:(NSNotification *)notification
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self updatePopoverAnnotationsToInterfaceOrientation:orientation];
}

#pragma mark - Public
- (void)addAnnotation:(FWTAnnotation *)annotation
{
    if (!self.contentView.superview)
        [self.view addSubview:self.contentView];
    
    if (!self.tapGestureRecognizer.view)
        [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    
    self.tapGestureRecognizer.enabled = NO;
    
    [self registerToStatusBarOrientationNotifications];
    
    self.contentView.frame = self.view.bounds;
    
    FWTAnnotationView *_popoverView = nil;
    if (_delegateHas.viewForAnnotation)
        _popoverView = [self.delegate annotationManager:self viewForAnnotation:annotation];
    else
        _popoverView = [[[FWTAnnotationView alloc] init] autorelease];
    
    //
    [self.annotations addObject:annotation];
    
    //
    [self.annotationsDictionary setObject:_popoverView forKey:[annotation description]];
    
    //
    self.presentAnimationsCounter = self.annotations.count;
    
    //
    CGFloat delay = self.animationsDisabled ? .0f : annotation.delay;
    
    //
    [self performSelector:@selector(presentPopoverViewForPopoverDescriptor:)
               withObject:annotation
               afterDelay:delay];
}

- (void)addAnnotations:(NSArray *)annotations
{
    [annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addAnnotation:obj];
    }];
}

- (void)removeAnnotation:(FWTAnnotation *)annotation
{
    FWTAnnotationView *_popoverView = [self viewForAnnotation:annotation];
    if (_popoverView)
    {
        FWTAnnotationViewCompletionBlock currentDismissCompletionBlock = NULL;
        if (_popoverView.dismissCompletionBlock)
            currentDismissCompletionBlock = _popoverView.dismissCompletionBlock;
        
        FWTAnnotationViewCompletionBlock completionBlock = ^(BOOL finished){
            if (currentDismissCompletionBlock)
                currentDismissCompletionBlock(finished);
            
            [self.annotations removeObject:annotation];
            [self.annotationsDictionary removeObjectForKey:[annotation description]];
            
            [_popoverView removeFromSuperview];
            
            if (self.annotations.count == 0)
            {
                [self.contentView removeFromSuperview];
                
                [self unregisterFromStatusBarOrientationNotifications];
            }
        };
        
        _popoverView.dismissCompletionBlock = completionBlock;
        
        [_popoverView dismissPopoverAnimated:annotation.animated];
    }
}

- (void)removeAnnotations:(NSArray *)annotations
{    
    NSArray *arrayCopy = [NSArray arrayWithArray:annotations];
    [arrayCopy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (self.removeAnnotationsWithRandomDelay)
        {
            NSInteger random = arc4random()%220;
            CGFloat delay = (CGFloat)random/1000.0f;
            [self performSelector:@selector(removePopoverAnnotation:) withObject:obj afterDelay:delay];
        }
        else
            [self removeAnnotation:obj];
    }];
}

- (void)cancel
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.annotations enumerateObjectsUsingBlock:^(FWTAnnotation *annotation, NSUInteger idx, BOOL *stop) {
        FWTAnnotationView *_popoverView = [self viewForAnnotation:annotation];
        [_popoverView removeFromSuperview];
    }];
    [self.contentView removeFromSuperview];
}

- (FWTAnnotationView *)viewForAnnotation:(FWTAnnotation *)annotation
{
    FWTAnnotationView *_popoverView = [self.annotationsDictionary objectForKey:[annotation description]];
    return _popoverView;
}

- (FWTAnnotationView *)viewAtPoint:(CGPoint)point
{
    __block FWTAnnotationView *toReturn = nil;
    [self.annotations enumerateObjectsUsingBlock:^(FWTAnnotation *annotation, NSUInteger idx, BOOL *stop) {
        FWTAnnotationView *_popoverView = [self viewForAnnotation:annotation];
        if (CGRectContainsPoint(_popoverView.frame, point))
        {
            toReturn = _popoverView;
            *stop = YES;
        }
    }];
    
    return toReturn;
}

- (FWTAnnotation *)annotationForView:(FWTAnnotationView *)view
{
    __block FWTAnnotation *toReturn = nil;
    [self.annotations enumerateObjectsUsingBlock:^(FWTAnnotation *annotation, NSUInteger idx, BOOL *stop) {
        FWTAnnotationView *_popoverView = [self viewForAnnotation:annotation];
        if (_popoverView == view)
        {
            toReturn = annotation;
            *stop = YES;
        }
    }];
    
    return toReturn;
}

- (BOOL)hasSuperview
{
    return self.contentView.superview != nil;
}

@end
