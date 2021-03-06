//
//  SampleViewController.m
//  FWTPopoverHintView_Test
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "IManagerViewController.h"

@implementation IManagerViewController

- (id)init
{
    if ((self = [super init]))
    {
        UISegmentedControl *sc = [[[UISegmentedControl alloc] initWithItems:@[@"show", @"remove"]] autorelease];
        sc.segmentedControlStyle = UISegmentedControlStyleBar;
        sc.momentary = YES;
        [sc addTarget:self action:@selector(_segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = sc;
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
    
    //
    UIImageView *iv = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo.png"]] autorelease];
    [self.view addSubview:iv];
    
    [self configureAnnotationsManager];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self _toggleToolbar:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self _toggleToolbar:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Private
- (void)_cancel
{
    [self.fwt_annotationManager cancel];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)_toggleToolbar:(BOOL)visible
{
    NSInteger tag = 0xbeef;
    if (visible)
    {
        UISegmentedControl *sc = [[[UISegmentedControl alloc] initWithItems:@[@"0", @"1", @"2"]] autorelease];
        sc.segmentedControlStyle = UISegmentedControlStyleBar;
        sc.momentary = YES;
        sc.frame = CGRectInset(self.navigationController.toolbar.bounds, 40.0f, 6.0f);
        sc.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight;
        [sc addTarget:self action:@selector(_segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        sc.tag = tag;
        [self.navigationController.toolbar addSubview:sc];
    }
    else
    {
        [[self.navigationController.toolbar viewWithTag:tag] removeFromSuperview];
    }
}

#pragma mark - Actions
- (void)_segmentedControlValueChanged:(UISegmentedControl *)sc
{
    //  add/remove all annotations
    //
    if (sc == self.navigationItem.titleView)
    {
        if (sc.selectedSegmentIndex == 0)
        {
            [self fwt_addAnnotations:[StaticModel annotations]];
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                    target:self
                                                                                                    action:@selector(_cancel)] autorelease];
        }
        else
        {
            [self fwt_removeAnnotations:self.fwt_annotationManager.model.annotations];
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
    
    //  add/remove the single one
    //
    else
    {                
        FWTAnnotation *pd = [[StaticModel annotations] objectAtIndex:sc.selectedSegmentIndex];
        if ([self.fwt_annotations containsObject:pd])
            [self fwt_removeAnnotation:pd];
        else
        {
            CGFloat savedDelay = pd.delay;
            pd.delay = .0f;
            [self fwt_addAnnotation:pd];
            pd.delay = savedDelay;
        }
    }
}

#pragma mark - Overrides
- (void)configureAnnotationsManager
{
    
}

@end
