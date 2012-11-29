//
//  ViewController.m
//  FWTPopoverHintView_Test
//
//  Created by Marco Meschini on 8/6/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "TouchViewController.h"
#import "FWTAnnotationView.h"
#import "StaticModel.h"

@interface TouchViewController () <FWTPopoverViewDelegate>
@property (nonatomic, retain) UIView *touchPointView;
@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, assign) FWTPopoverArrowDirection popoverArrowDirection;
@property (nonatomic, retain) FWTAnnotationView *annotationView;
@end

@implementation TouchViewController

- (void)dealloc
{
    self.annotationView = nil;
    self.touchPointView = nil;
    self.segmentedControl = nil;
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
    self.popoverArrowDirection = pow(2, 0);
    
    self.navigationItem.titleView = self.segmentedControl;
    self.segmentedControl.selectedSegmentIndex = log2(self.popoverArrowDirection);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Getters
- (UISegmentedControl *)segmentedControl
{
    if (!self->_segmentedControl)
    {
        self->_segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"N", @"U", @"D", @"L", @"R"]];
        self->_segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        self->_segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self->_segmentedControl addTarget:self action:@selector(valueChangedForSegmentedControl:) forControlEvents:UIControlEventValueChanged];
        [self->_segmentedControl sizeToFit];
    }
    
    return self->_segmentedControl;
}

- (UIView *)touchPointView
{
    if (!self->_touchPointView)
    {
        self->_touchPointView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, 4.0f, 4.0f)];
        self->_touchPointView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.5f];
        self->_touchPointView.layer.borderWidth = 1.0f;
        self->_touchPointView.layer.cornerRadius = 2.0f;
    }
    
    return self->_touchPointView;
}

#pragma mark - Actions
- (void)valueChangedForSegmentedControl:(UISegmentedControl *)segmentedControl
{
    self.popoverArrowDirection = pow(2, segmentedControl.selectedSegmentIndex);
}

#pragma mark - UIResponder
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.view];
    
    //
    if (!self.annotationView)
    {
        self.annotationView = [[self class] _defaultAnnotationView];
        self.annotationView.delegate = self;
        self.annotationView.textLabel.text = [StaticModel randomText];
        id image = [StaticModel randomImage];
        if ([image isKindOfClass:[UIImage class]]) self.annotationView.imageView.image = image;
        [self.annotationView presentFromRect:CGRectMake(point.x, point.y, 1.0f, 1.0f)
                                      inView:self.view
                     permittedArrowDirection:self.popoverArrowDirection
                                    animated:YES];
    }
    else
        [self.annotationView dismissPopoverAnimated:YES];
    
    //
    if (!self.touchPointView.superview) [self.view addSubview:self.touchPointView];
    self.touchPointView.center = point;
    [self.view bringSubviewToFront:self.touchPointView];
}

#pragma mark - FWTPopoverViewDelegate
- (void)popoverViewDidDismiss:(FWTPopoverView *)annotationView
{
    self.annotationView = nil;
}

#pragma mark - Private
+ (FWTAnnotationView *)_defaultAnnotationView
{
    //
    FWTAnnotationView *toReturn = [[[FWTAnnotationView alloc] init] autorelease];
    toReturn.contentSize = CGSizeMake(180.0f, 40.0f);
//    toReturn.adjustPositionInSuperviewEnabled = NO;
    
    //
    toReturn.textLabel.textAlignment = UITextAlignmentCenter;
    toReturn.textLabel.backgroundColor = [UIColor clearColor];
    toReturn.textLabel.numberOfLines = 0;
    toReturn.textLabel.font = [UIFont systemFontOfSize:12.0f];
    toReturn.textLabel.textColor = [UIColor colorWithWhite:.91f alpha:1.0f];
    toReturn.textLabel.shadowOffset = CGSizeMake(.0f, -.7f);
    toReturn.textLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    
    return toReturn;
}

@end
