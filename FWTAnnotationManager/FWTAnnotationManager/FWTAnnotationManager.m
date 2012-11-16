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
    [self _unregisterFromStatusBarOrientationNotifications];
    self.didTapAnnotationBlock = nil;
    self.viewForAnnotationBlock = nil;
    self.model = nil;
    self.orientationObserver = nil;
    self.tapGestureRecognizer = nil;
    self.annotationsContainerView = nil;
    self.parentView = nil;
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
            FWTAnnotationView *_popoverView = [self.model viewForAnnotation:annotation];
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
    NSArray *arrayCopy = [NSArray arrayWithArray:annotations];
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
