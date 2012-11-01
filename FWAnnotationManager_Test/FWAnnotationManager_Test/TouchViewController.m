//
//  ViewController.m
//  FWTPopoverHintView_Test
//
//  Created by Marco Meschini on 8/6/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "TouchViewController.h"
#import "FWTDefaultAnnotationView.h"
#import "StaticModel.h"

@interface TouchViewController ()
{
    UIView *_touchPointView;
    UISegmentedControl *_segmentedControl;
    FWTPopoverArrowDirection _popoverArrowDirection;
}

@property (nonatomic, retain) UIView *touchPointView;
@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, assign) FWTPopoverArrowDirection popoverArrowDirection;

@end

@implementation TouchViewController
@synthesize segmentedControl = _segmentedControl;
@synthesize popoverArrowDirection = _popoverArrowDirection;
@synthesize touchPointView = _touchPointView;

- (void)dealloc
{
    self.touchPointView = nil;
    self.segmentedControl = nil;
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
    //
    self.popoverArrowDirection = pow(2, 0);
    
    //
    self.navigationItem.titleView = self.segmentedControl;
    self.segmentedControl.selectedSegmentIndex = 0;
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
        NSArray *items = @[@"N", @"U", @"D", @"L", @"R"];
        self->_segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
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
        self->_touchPointView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, 3.0f, 3.0f)];
        self->_touchPointView.layer.borderWidth = 1.0f;
    }
    
    return self->_touchPointView;
}

#pragma mark - Actions
- (void)valueChangedForSegmentedControl:(UISegmentedControl *)segmentedControl
{
    self.popoverArrowDirection = pow(2, segmentedControl.selectedSegmentIndex);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.view];
    
    if (!self.touchPointView.superview)
        [self.view addSubview:self.touchPointView];
    
    self.touchPointView.center = point;
    
    //
    FWTDefaultAnnotationView *popoverView = (FWTDefaultAnnotationView *)[self.view viewWithTag:0xbeef];
    if (!popoverView)
    {
        popoverView = [[self class] _defaultAnnotationView];
        popoverView.tag = 0xbeef;
        popoverView.textLabel.text = [StaticModel randomText];
        id image = [StaticModel randomImage];
        if ([image isKindOfClass:[UIImage class]])
            popoverView.imageView.image = image;

        [popoverView presentFromRect:self.touchPointView.frame
                              inView:self.view
             permittedArrowDirection:self.popoverArrowDirection
                            animated:YES];
    }
    else
    {
        [popoverView dismissPopoverAnimated:YES];
    }
    
    //
    [self.view bringSubviewToFront:_touchPointView];
}

+ (FWTDefaultAnnotationView *)_defaultAnnotationView
{
    //
    FWTDefaultAnnotationView *toReturn = [[[FWTDefaultAnnotationView alloc] init] autorelease];
    toReturn.contentSize = CGSizeMake(180.0f, 40.0f);
    
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
