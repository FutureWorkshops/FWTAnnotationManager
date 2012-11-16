//
//  SampleViewController.m
//  FWTPopoverHintView_Test
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "SampleViewController.h"
#import "StaticModel.h"
#import "CustomAnnotationView.h"
#import "UIView+FWTAnnotationManager.h"

@interface SampleViewController ()

@property (nonatomic, retain) NSArray *debugArray;
@end

@implementation SampleViewController

- (void)dealloc
{
    self.debugArray = nil;
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        UISegmentedControl *sc = [[[UISegmentedControl alloc] initWithItems:@[@"show", @"remove"]] autorelease];
        sc.segmentedControlStyle = UISegmentedControlStyleBar;
        sc.momentary = YES;
        [sc addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = sc;
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
    
//    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *iv = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo.png"]] autorelease];
    [self.view addSubview:iv];
    
    // configure our annotation
    self.view.fwt_annotationManager.annotationsContainerViewType = FWTAnnotationsContainerViewTypeRadial;
    self.view.fwt_annotationManager.annotationsContainerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.65f];
    self.view.fwt_annotationManager.viewForAnnotationBlock = ^(FWTAnnotation *annotation){
        CustomAnnotationView *_annotationView = [[[CustomAnnotationView alloc] init] autorelease];
        [_annotationView setupAnimationHelperWithSuperview:self.view];
        return _annotationView;
    };
}

//- (void)viewDidLayoutSubviews
//{
//    [super viewDidLayoutSubviews];
//    
//    return;
//    
//    [self.debugArray makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
//    self.debugArray = nil;
//    
//    NSArray *annotations = [StaticModel popoverAnnotations];
//    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:annotations.count];
//    
//    //  debug
//    __block typeof(self) myself = self;
//    CALayer *(^debugLayerBlock)(CGPoint, CGColorRef) = ^(CGPoint centerPoint, CGColorRef borderColor) {
//        CALayer *l = [CALayer layer];
//        l.bounds = CGRectMake(.0f, .0f, 11.0f, 11.0f);
//        l.position = centerPoint;
//        l.borderWidth = 1.0f;
//        l.borderColor = borderColor;
//        [myself.view.layer addSublayer:l];
//        return l;
//    };
//    
//    
//    if UIInterfaceOrientationIsLandscape(self.interfaceOrientation)
//    {
//        [annotations enumerateObjectsUsingBlock:^(FWTAnnotation *obj, NSUInteger idx, BOOL *stop) {
//            CGRect rect = obj.presentingRectLandscape;
//            CGPoint midPoint = CGPointZero;
//            midPoint.x = CGRectGetWidth(rect) == 1.0f ? rect.origin.x : CGRectGetMidX(rect);
//            midPoint.y = CGRectGetHeight(rect) == 1.0f ? rect.origin.y : CGRectGetMidY(rect);
//            [tmp addObject:debugLayerBlock(midPoint, [UIColor blackColor].CGColor)];
//        }];
//    }
//    else
//    {
//        [annotations enumerateObjectsUsingBlock:^(FWTAnnotation *obj, NSUInteger idx, BOOL *stop) {
//            CGRect rect = obj.presentingRectPortrait;
//            CGPoint midPoint = CGPointZero;
//            midPoint.x = CGRectGetWidth(rect) == 1.0f ? rect.origin.x : CGRectGetMidX(rect);
//            midPoint.y = CGRectGetHeight(rect) == 1.0f ? rect.origin.y : CGRectGetMidY(rect);
//            [tmp addObject:debugLayerBlock(midPoint, [UIColor blackColor].CGColor)];
//        }];
//    }
//    
//    self.debugArray = tmp;
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    UISegmentedControl *sc = [[[UISegmentedControl alloc] initWithItems:@[@"0", @"1", @"2"]] autorelease];
    sc.segmentedControlStyle = UISegmentedControlStyleBar;
    sc.momentary = YES;
    sc.frame = CGRectInset(self.navigationController.toolbar.bounds, 40.0f, 6.0f);
    sc.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight;
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
//    [self.fwPopoverController cancel];
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - Actions
- (void)segmentedControlValueChanged:(UISegmentedControl *)sc
{
    if (sc == self.navigationItem.titleView)
    {
        if (sc.selectedSegmentIndex == 0)
        {
            [self.view fwt_addAnnotations:[StaticModel popoverAnnotations]];
            
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                    target:self
                                                                                                    action:@selector(cancel)] autorelease];
        }
        else
        {
            [self.view fwt_removeAnnotations:self.view.fwt_annotationManager.model.annotations];
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
    else
    {                
        FWTAnnotation *pd = [[StaticModel popoverAnnotations] objectAtIndex:sc.selectedSegmentIndex];
        if ([self.view.fwt_annotations containsObject:pd])
            [self.view fwt_removeAnnotation:pd];
        else
        {
            CGFloat savedDelay = pd.delay;
            pd.delay = .0f;
            [self.view fwt_addAnnotation:pd];
            pd.delay = savedDelay;
        }
    }
}

@end
