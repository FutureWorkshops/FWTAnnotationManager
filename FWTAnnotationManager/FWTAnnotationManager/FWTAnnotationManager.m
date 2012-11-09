//
//  FWTPopoverController.m
//  FWTPopoverHintView
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "FWTAnnotationManager.h"

@interface FWTAnnotationManager () <FWTPopoverViewDelegate>
{
    struct
    {
        BOOL viewForAnnotation: 1;
        BOOL didTapAnnotationView: 1;
    } _delegateHas;
}

@property (nonatomic, retain) NSMutableArray *mutableAnnotations;
@property (nonatomic, retain) NSMutableDictionary *annotationsDictionary;
@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, assign) NSInteger popoverViewDidPresentCounter;
@property (nonatomic, retain) id orientationObserver;

@end

@implementation FWTAnnotationManager
@synthesize mutableAnnotations = _mutableAnnotations;
@synthesize annotations = _annotations;
@synthesize annotationsDictionary = _annotationsDictionary;
@synthesize delegate = _delegate;
@synthesize contentView = _contentView;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;

- (void)dealloc
{
    [self _unregisterFromStatusBarOrientationNotifications];
    self.orientationObserver = nil;
    self.tapGestureRecognizer = nil;
    self.contentView = nil;
    self.delegate = nil;
    self.mutableAnnotations = nil;
    self.annotationsDictionary = nil;
    self.parentView = nil;
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        self.popoverViewDidPresentCounter = 0;
    }
    
    return self;
}

#pragma mark - Setters
- (void)setDelegate:(id<FWTAnnotationManagerDelegate>)delegate
{
    if (self->_delegate != delegate)
    {
        self->_delegate = delegate;

        _delegateHas.viewForAnnotation = [self->_delegate respondsToSelector:@selector(annotationManager:viewForAnnotation:)];
        _delegateHas.didTapAnnotationView = [self->_delegate respondsToSelector:@selector(annotationManager:didTapAnnotationView:annotation:)];
    }
}

#pragma mark - Getters
- (NSArray *)annotations
{
    return [[self.mutableAnnotations copy] autorelease];
}

- (NSMutableArray *)mutableAnnotations
{
    if (!self->_mutableAnnotations) self->_mutableAnnotations = [[NSMutableArray alloc] init];
    return self->_mutableAnnotations;
}

- (NSMutableDictionary *)annotationsDictionary
{
    if (!self->_annotationsDictionary) self->_annotationsDictionary = [[NSMutableDictionary alloc] init];
    return self->_annotationsDictionary;
}

- (UIView *)contentView
{
    if (!self->_contentView)
    {
        self->_contentView = [[UIView alloc] init];
        self->_contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        self->_contentView.layer.borderWidth = 2.0f;
        self->_contentView.layer.borderColor = [UIColor orangeColor].CGColor;
    }
    
    return self->_contentView;
}

- (UITapGestureRecognizer *)tapGestureRecognizer
{
    if (!self->_tapGestureRecognizer)
        self->_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleGesture:)];
    
    return self->_tapGestureRecognizer;
}

#pragma mark - Actions
- (void)_handleGesture:(UIGestureRecognizer *)gesture
{
    if (_delegateHas.didTapAnnotationView)
    {
        CGPoint point = [gesture locationInView:gesture.view];
        FWTDefaultAnnotationView *_popoverView = [self viewAtPoint:point];
        FWTAnnotation *_annotation = [self annotationForView:_popoverView];
        [self.delegate annotationManager:self didTapAnnotationView:_popoverView annotation:_annotation];
    }
}

#pragma mark - Private Orientation
- (void)_registerToStatusBarOrientationNotifications
{
    if (!self.orientationObserver)
    {
        __block typeof(self) myself = self;
        self.orientationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification
                                                                                     object:nil
                                                                                      queue:[NSOperationQueue mainQueue]
                                                                                 usingBlock:^(NSNotification *note) {
                                                                                     NSLog(@"_updatePopoverAnnotationsToInterfaceOrientation");
                                                                                     
                                                                                     int64_t delayInSeconds = .1f;
                                                                                     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                                                                     dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                                         [myself _updatePopoverAnnotationsToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
                                                                                     });
                                                                                 }];
    }
}

- (void)_unregisterFromStatusBarOrientationNotifications
{
    if (self.orientationObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self.orientationObserver
                                                        name:UIApplicationDidChangeStatusBarOrientationNotification
                                                      object:nil];
        self.orientationObserver = nil;
    }
}

- (void)_updatePopoverAnnotationsToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [UIView animateWithDuration:.2f animations:^{
        [self.mutableAnnotations enumerateObjectsUsingBlock:^(FWTAnnotation *annotation, NSUInteger idx, BOOL *stop) {
            FWTDefaultAnnotationView *_popoverView = [self viewForAnnotation:annotation];
            [_popoverView adjustPositionToRect:[self _presentingRectForAnnotation:annotation]];
        }];
    }];
}

#pragma mark - Private 
- (CGRect)_presentingRectForAnnotation:(FWTAnnotation *)annotation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect rect = CGRectZero;
    rect = UIInterfaceOrientationIsLandscape(orientation) ? annotation.presentingRectLandscape : annotation.presentingRectPortrait;    
    return rect;
}

- (FWTDefaultAnnotationView *)_createViewForAnnotation:(FWTAnnotation *)annotation
{
    FWTDefaultAnnotationView *_popoverView = nil;
    if (_delegateHas.viewForAnnotation)
        _popoverView = [self.delegate annotationManager:self viewForAnnotation:annotation];
    else
        _popoverView = [[[FWTDefaultAnnotationView alloc] init] autorelease];
    
    _popoverView.delegate = self;
    return _popoverView;
}

#pragma mark - Public
- (void)addAnnotation:(FWTAnnotation *)annotation
{
    //  add the contentView if needed
    if (!self.contentView.superview) [self.parentView addSubview:self.contentView];
    self.contentView.frame = self.parentView.bounds;
    
    //  add the gesture
    if (!self.tapGestureRecognizer.view) [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    self.tapGestureRecognizer.enabled = NO;
    
    //  orientation
    [self _registerToStatusBarOrientationNotifications];
    
    //  get an annotationView
    FWTDefaultAnnotationView *annotationView = [self _createViewForAnnotation:annotation];
    
    //  configure
    if (annotation.text) annotationView.textLabel.text = annotation.text;
    if (annotation.image) annotationView.imageView.image = annotation.image;
    annotationView.animationHelper.presentDelay = annotation.delay;
    
    //  update model
    [self.mutableAnnotations addObject:annotation];
    [self.annotationsDictionary setObject:annotationView forKey:annotation.guid];
    self.popoverViewDidPresentCounter++;
    
    //  ready to present
    CGRect rect = [self _presentingRectForAnnotation:annotation];
    [annotationView presentFromRect:rect inView:self.contentView permittedArrowDirection:annotation.arrowDirection animated:annotation.animated];
}

- (void)addAnnotations:(NSArray *)annotations
{
    [annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addAnnotation:obj];
    }];
}

- (void)removeAnnotation:(FWTAnnotation *)annotation
{
    FWTDefaultAnnotationView *_popoverView = [self viewForAnnotation:annotation];
    if (_popoverView)
        [_popoverView dismissPopoverAnimated:annotation.animated];
}

- (void)removeAnnotations:(NSArray *)annotations
{    
    NSArray *arrayCopy = [NSArray arrayWithArray:annotations];
    [arrayCopy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self removeAnnotation:obj];
    }];
}

- (void)cancel
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.mutableAnnotations enumerateObjectsUsingBlock:^(FWTAnnotation *annotation, NSUInteger idx, BOOL *stop) {
        FWTDefaultAnnotationView *_popoverView = [self viewForAnnotation:annotation];
        [_popoverView removeFromSuperview];
    }];
    [self.contentView removeFromSuperview];
}

- (FWTDefaultAnnotationView *)viewForAnnotation:(FWTAnnotation *)annotation
{
    FWTDefaultAnnotationView *_popoverView = [self.annotationsDictionary objectForKey:annotation.guid];
    return _popoverView;
}

- (FWTDefaultAnnotationView *)viewAtPoint:(CGPoint)point
{
    __block FWTDefaultAnnotationView *toReturn = nil;
    [self.mutableAnnotations enumerateObjectsUsingBlock:^(FWTAnnotation *annotation, NSUInteger idx, BOOL *stop) {
        FWTDefaultAnnotationView *_popoverView = [self viewForAnnotation:annotation];
        if (CGRectContainsPoint(_popoverView.frame, point))
        {
            toReturn = _popoverView;
            *stop = YES;
        }
    }];
    
    return toReturn;
}

- (FWTAnnotation *)annotationForView:(FWTDefaultAnnotationView *)view
{
    __block FWTAnnotation *toReturn = nil;
    [self.mutableAnnotations enumerateObjectsUsingBlock:^(FWTAnnotation *annotation, NSUInteger idx, BOOL *stop) {
        FWTDefaultAnnotationView *_popoverView = [self viewForAnnotation:annotation];
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
    FWTAnnotation *annotation = [self annotationForView:(FWTDefaultAnnotationView *)annotationView];
    [self.mutableAnnotations removeObject:annotation];
    [self.annotationsDictionary removeObjectForKey:annotation.guid];
    
    //
    if (self.mutableAnnotations.count == 0)
    {
        [self.contentView removeFromSuperview];
        [self _unregisterFromStatusBarOrientationNotifications];
    }
}

@end
