//
//  ViewController.m
//  FWTPopoverHintView_Test
//
//  Created by Marco Meschini on 8/6/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "AnnotationViewController.h"
#import "FWTAnnotationView.h"
#import "StaticModel.h"

@interface AnnotationViewController ()
@property (nonatomic, retain) UIView *touchPointView;
@property (nonatomic, assign) FWTPopoverArrowDirection popoverArrowDirection;
@property (nonatomic, retain) FWTAnnotationView *annotationView;
@end

@implementation AnnotationViewController

- (void)dealloc
{
    self.annotationView = nil;
    self.touchPointView = nil;
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
    self.popoverArrowDirection = pow(2, 0); //  store the selected arrow type
    
    //  allow to change arrow type
    UISegmentedControl *segmentedControl = [[[UISegmentedControl alloc] initWithItems:@[@"N", @"U", @"D", @"L", @"R"]] autorelease];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [segmentedControl addTarget:self action:@selector(_valueChangedForSegmentedControl:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = log2(self.popoverArrowDirection);
    [segmentedControl sizeToFit];
    self.navigationItem.titleView = segmentedControl;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Getters
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
- (void)_valueChangedForSegmentedControl:(UISegmentedControl *)segmentedControl
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
        __block typeof(self) myself = self;
        self.annotationView.didDismissBlock = ^(FWTPopoverView *av){ myself.annotationView = nil; };
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

#pragma mark - Private
+ (FWTAnnotationView *)_defaultAnnotationView
{
    //
    FWTAnnotationView *toReturn = [[[FWTAnnotationView alloc] init] autorelease];
    toReturn.contentSize = CGSizeMake(180.0f, 40.0f);
    
//    toReturn.adjustPositionInSuperviewEnabled = NO; //  uncomment if you want to disable auto adjustment
    
    //
    toReturn.textLabel.textAlignment = UITextAlignmentCenter;
    toReturn.textLabel.backgroundColor = [UIColor clearColor];
    toReturn.textLabel.numberOfLines = 0;
    toReturn.textLabel.textColor = [UIColor colorWithWhite:.91f alpha:1.0f];
    toReturn.textLabel.shadowOffset = CGSizeMake(.0f, -.7f);
    toReturn.textLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    
//    toReturn.textLabel.font = [StaticModel randomFontWithSize:12.0f];
    toReturn.textLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    toReturn.textLabel.text = [StaticModel randomText];
    id image = [StaticModel randomImage];
    if ([image isKindOfClass:[UIImage class]]) toReturn.imageView.image = image;
    
    return toReturn;
}

@end
