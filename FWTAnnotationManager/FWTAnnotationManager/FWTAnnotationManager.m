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

@interface FWTAnnotationManager () <FWTPopoverViewDelegate>
{
    struct
    {
        BOOL viewForAnnotation: 1;
        BOOL didTapAnnotationView: 1;
    } _delegateHas;
}

@property (nonatomic, readwrite, retain) UIView *annotationsContainerView;
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, assign) NSInteger popoverViewDidPresentCounter;
@property (nonatomic, retain) id orientationObserver;
@property (nonatomic, readwrite, retain) FWTAnnotationModel *model;

@end

@implementation FWTAnnotationManager
@synthesize delegate = _delegate;
@synthesize annotationsContainerView = _annotationsContainerView;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;

- (void)dealloc
{
    [self _unregisterFromStatusBarOrientationNotifications];
    self.model = nil;
    self.orientationObserver = nil;
    self.tapGestureRecognizer = nil;
    self.annotationsContainerView = nil;
    self.delegate = nil;
    self.parentView = nil;
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        self.popoverViewDidPresentCounter = 0;
        self.annotationsContainerViewType = FWTAnnotationsContainerViewTypeDefault;
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

#pragma mark - Actions
- (void)_handleGesture:(UIGestureRecognizer *)gesture
{
    if (_delegateHas.didTapAnnotationView)
    {
        CGPoint point = [gesture locationInView:gesture.view];
        FWTDefaultAnnotationView *_popoverView = [self.model viewAtPoint:point];
        FWTAnnotation *_annotation = [self.model annotationForView:_popoverView];
        [self.delegate annotationManager:self didTapAnnotationView:_popoverView annotation:_annotation];
    }
}

#pragma mark - Private Orientation
- (void)_registerToStatusBarOrientationNotifications
{
    if (!self.orientationObserver)
    {
        __block typeof(self) myself = self;
        void (^NotificationBlock)(NSNotification *) = ^(NSNotification *note){
            int64_t delayInSeconds = .1f;   //  wait to get a consistent frame
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
                [myself _updatePopoverAnnotationsToInterfaceOrientation:orientation];
            });
        };
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        self.orientationObserver = [notificationCenter addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification
                                                                   object:nil
                                                                    queue:[NSOperationQueue mainQueue]
                                                               usingBlock:NotificationBlock];
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
        [self.model enumerateAnnotationsUsingBlock:^(FWTAnnotation *annotation, NSUInteger idx, BOOL *stop) {
            FWTDefaultAnnotationView *_popoverView = [self.model viewForAnnotation:annotation];
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

- (void)_setupAnnotationsContainerView
{
    if (!self.annotationsContainerView.superview)
    {
        BOOL needsAnimation = NO;
        if (!CGColorEqualToColor([UIColor clearColor].CGColor, self.annotationsContainerView.backgroundColor.CGColor))
        {
            needsAnimation = YES;
            self.annotationsContainerView.alpha = .0f;
        }
        
        self.annotationsContainerView.frame = self.parentView.bounds;
        [self.parentView addSubview:self.annotationsContainerView];
        [UIView animateWithDuration:.2f animations:^{ self.annotationsContainerView.alpha = 1.0f; }];
    }
    else
    {
        self.annotationsContainerView.frame = self.parentView.bounds;
    }
}

#pragma mark - Public
- (void)addAnnotation:(FWTAnnotation *)annotation
{
    //  add the containerView if needed
    [self _setupAnnotationsContainerView];
    
    //  add the gesture
    if (!self.tapGestureRecognizer.view) [self.annotationsContainerView addGestureRecognizer:self.tapGestureRecognizer];
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
    [self.model addAnnotation:annotation withView:annotationView];
    
    //
    self.popoverViewDidPresentCounter++;
    
    //
    [self.annotationsContainerView addAnnotationView:annotationView];
    
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
    FWTDefaultAnnotationView *_popoverView = [self.model viewForAnnotation:annotation];
    if (_popoverView)
    {
        [self.annotationsContainerView removeAnnotationView:_popoverView];
        [_popoverView dismissPopoverAnimated:annotation.animated];
    }
}

- (void)removeAnnotations:(NSArray *)annotations
{    
    NSArray *arrayCopy = [NSArray arrayWithArray:annotations];
    [arrayCopy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self removeAnnotation:obj];
    }];
}

//- (void)cancel
//{
//    [NSObject cancelPreviousPerformRequestsWithTarget:self];
//    [self.model enumerateAnnotationsUsingBlock:^(FWTAnnotation *annotation, NSUInteger idx, BOOL *stop) {
//        FWTDefaultAnnotationView *_popoverView = [self.model viewForAnnotation:annotation];
//        [_popoverView removeFromSuperview];
//    }];
//    [self.annotationsContainerView removeFromSuperview];
//}

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
    FWTAnnotation *annotation = [self.model annotationForView:(FWTDefaultAnnotationView *)annotationView];
    [self.model removeAnnotation:annotation];

    //
    if (self.model.numberOfAnnotations == 0)
    {
        [UIView animateWithDuration:.2f
                         animations:^{
                             self.annotationsContainerView.alpha = .0f;
                         }
                         completion:^(BOOL finished) {
                             [self.annotationsContainerView removeFromSuperview];
                             [self _unregisterFromStatusBarOrientationNotifications];
                         }];
    }
}

@end
