//
//  SampleViewController.m
//  FWTPopoverHintView_Test
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "SampleViewController.h"
#import "FWTDefaultAnnotationView.h"
#import "StaticModel.h"

@interface SampleViewController ()
{
    NSArray *_popoverAnnotations;
}

@property (nonatomic, retain) NSArray *popoverAnnotations;
@property (nonatomic, retain) FWTAnnotationManager *fwPopoverController;
@end

@implementation SampleViewController

- (void)dealloc
{
    self.popoverAnnotations = nil;
    self.fwPopoverController = nil;
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        NSArray *items = @[@"show", @"remove"];
        UISegmentedControl *sc = [[[UISegmentedControl alloc] initWithItems:items] autorelease];
        sc.segmentedControlStyle = UISegmentedControlStyleBar;
        sc.momentary = YES;
        [sc addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = sc;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    NSArray *items = @[@"0", @"1", @"2"];
    UISegmentedControl *sc = [[[UISegmentedControl alloc] initWithItems:items] autorelease];
    sc.segmentedControlStyle = UISegmentedControlStyleBar;
    sc.momentary = YES;
    sc.center = CGPointMake(CGRectGetMidX(self.view.bounds), 22.0f);
    sc.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [sc addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    sc.tag = 0xbeef;
    [self.navigationController.toolbar addSubview:sc];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[self.navigationController.toolbar viewWithTag:0xbeef] removeFromSuperview];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Private
- (void)cancel
{
    [self.fwPopoverController cancel];
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - Actions
- (void)segmentedControlValueChanged:(UISegmentedControl *)sc
{
    if (sc == self.navigationItem.titleView)
    {
        if (sc.selectedSegmentIndex == 0)
        {
            self.fwPopoverController.view = self.view;
            
            [self.fwPopoverController addAnnotations:[StaticModel popoverAnnotations]];
            
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                    target:self
                                                                                                    action:@selector(cancel)] autorelease];
        }
        else
        {
            [self.fwPopoverController removeAnnotations:self.fwPopoverController.annotations];
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
    else
    {
        self.fwPopoverController.view = self.view;
                
        FWTAnnotation *pd = [[StaticModel popoverAnnotations] objectAtIndex:sc.selectedSegmentIndex];
        if ([self.fwPopoverController.annotations containsObject:pd])
            [self.fwPopoverController removeAnnotation:pd];
        else
        {
            CGFloat savedDelay = pd.delay;
            pd.delay = .0f;
            [self.fwPopoverController addAnnotation:pd];
            pd.delay = savedDelay;
        }
    }
}

#pragma mark - Private
- (FWTDefaultAnnotationView *)defaultPopoverView
{
    FWTDefaultAnnotationView *_popoverView = [[[FWTDefaultAnnotationView alloc] init] autorelease];
    
    //
    _popoverView.contentSize = CGSizeMake(160.0f, 60.0f);
    
    //
    _popoverView.arrow.cornerOffset = 10.0f;
    _popoverView.arrow.offset = 10.0f;
    //    _popoverView.animationDuration = .35f;
    
    //
    _popoverView.textLabel.textAlignment = UITextAlignmentCenter;
    _popoverView.textLabel.backgroundColor = [UIColor clearColor];
    _popoverView.textLabel.numberOfLines = 0;
    _popoverView.textLabel.font = [UIFont systemFontOfSize:12.0f];
    _popoverView.textLabel.textColor = [UIColor colorWithWhite:.91f alpha:1.0f];
    _popoverView.textLabel.shadowOffset = CGSizeMake(.0f, -.7f);
    _popoverView.textLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    

    _popoverView.animationHelper.prepareBlock = ^{
        _popoverView.frame = CGRectOffset(_popoverView.frame, .0f, -self.view.frame.size.height);
    };

    _popoverView.animationHelper.presentAnimationsBlock = ^{
        _popoverView.frame = CGRectOffset(_popoverView.frame, .0f, self.view.frame.size.height + 5.0f);
    };

    _popoverView.animationHelper.presentCompletionBlock = ^(BOOL finished){
        [UIView animateWithDuration:.1f animations:^{
            _popoverView.frame = CGRectOffset(_popoverView.frame, .0f, -5.0f);
        }];
    };
    
    _popoverView.animationHelper.dismissAnimationsBlock = ^{
        _popoverView.transform = ((arc4random()%1000) > 500) ? CGAffineTransformMakeRotation(M_PI*.5f):CGAffineTransformMakeRotation(-M_PI*.5f);
        _popoverView.frame = CGRectOffset(_popoverView.frame, .0f, self.view.frame.size.height);
    };

    return _popoverView;
}

#pragma mark - Getters
- (FWTAnnotationManager *)fwPopoverController
{
    if (!self->_fwPopoverController)
    {
        self->_fwPopoverController = [[FWTAnnotationManager alloc] init];
        self->_fwPopoverController.delegate = self;
    }
    
    return self->_fwPopoverController;
}

#pragma mark - FWTAnnotationManagerDelegate
- (FWTAnnotationView *)annotationManager:(FWTAnnotationManager *)annotationManager viewForAnnotation:(FWTAnnotation *)annotation
{
    FWTDefaultAnnotationView *_popoverView = [self defaultPopoverView];
    _popoverView.textLabel.text = annotation.text;

    return _popoverView;
}

- (void)annotationManager:(FWTAnnotationManager *)annotationManager
     didTapAnnotationView:(FWTAnnotationView *)annotationView
               annotation:(FWTAnnotation *)annotation
{
    if (annotationView)
    {
        [annotationManager removeAnnotation:annotation];
    }
    else
    {
        [annotationManager removeAnnotations:annotationManager.annotations];
    }
}

@end
