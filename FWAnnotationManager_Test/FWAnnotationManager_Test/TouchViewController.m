//
//  ViewController.m
//  FWTPopoverHintView_Test
//
//  Created by Marco Meschini on 8/6/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "TouchViewController.h"
#import "FWTAnnotationView.h"
#import "FWTDefaultAnnotationView.h"
#import "StaticModel.h"

@interface TouchViewController ()
{
    FWTDefaultAnnotationView *_popoverView;
    UIView *_touchPointView;
    
    UISegmentedControl *_segmentedControl;
    FWTAnnotationArrowDirection _popoverArrowDirection;
}

@property (nonatomic, retain) FWTDefaultAnnotationView *popoverView;
@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, assign) FWTAnnotationArrowDirection popoverArrowDirection;

@end

@implementation TouchViewController
@synthesize popoverView = _popoverView;
@synthesize segmentedControl = _segmentedControl;
@synthesize popoverArrowDirection = _popoverArrowDirection;

- (void)dealloc
{
    self.popoverView = nil;
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

- (FWTDefaultAnnotationView *)popoverView
{
    if (!self->_popoverView)
    {
        self->_popoverView = [[FWTDefaultAnnotationView alloc] init];
        self->_popoverView.contentSize = CGSizeMake(260.0f, 60.0f);
        self->_popoverView.backgroundHelper.drawPathBlock = ^(CGContextRef ctx, FWTAnnotationBackgroundHelper *backgroundHelper){
            
            //  clip to current path
            CGContextSaveGState(ctx);
            CGContextAddPath(ctx, backgroundHelper.path);
            CGContextClip(ctx);
            
            //  stroke a thick inner border
            CGRect innerShapeBounds = CGRectInset(backgroundHelper.pathFrame, 2.0f, 2.0f);
            UIBezierPath *innerBezierPath = [backgroundHelper bezierPathForRect:innerShapeBounds];
            CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] colorWithAlphaComponent:1.0f].CGColor);
            CGContextSetLineWidth(ctx, 5.0f);
            CGContextSetLineJoin(ctx, kCGLineJoinRound);
            CGContextSetBlendMode(ctx, kCGBlendModeColorBurn);
            CGContextAddPath(ctx, innerBezierPath.CGPath);
            CGContextDrawPath(ctx, kCGPathStroke);
            CGContextRestoreGState(ctx);
        };
        
        self->_popoverView.textLabel.textAlignment = UITextAlignmentCenter;
        self->_popoverView.textLabel.backgroundColor = [UIColor clearColor];
        self->_popoverView.textLabel.numberOfLines = 0;
        self->_popoverView.textLabel.font = [UIFont systemFontOfSize:12.0f];
        self->_popoverView.textLabel.textColor = [UIColor colorWithWhite:.91f alpha:1.0f];
        self->_popoverView.textLabel.shadowOffset = CGSizeMake(.0f, -.7f);
        self->_popoverView.textLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
        
        self->_popoverView.animationHelper.dismissCompletionBlock = ^(BOOL finished){
            self.popoverView = nil;
        };
    }
        
    return self->_popoverView;
}

#pragma mark - Actions
- (void)valueChangedForSegmentedControl:(UISegmentedControl *)segmentedControl
{
    self.popoverArrowDirection = pow(2, segmentedControl.selectedSegmentIndex);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.view];
    
    if (!_touchPointView)
    {
        _touchPointView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, 3.0f, 3.0f)];
        _touchPointView.layer.borderWidth = 1.0f;
        [self.view addSubview:_touchPointView];
    }    
    _touchPointView.center = point;

    //
    if (self.popoverView.superview)
    {
        [self.popoverView dismissPopoverAnimated:YES];
        return;
    }
    
    //
    self.popoverView.contentSize = CGSizeMake(160.0f, 60.0f);
    self.popoverView.textLabel.text = [StaticModel randomText];
    id image = [StaticModel randomImage];
    if ([image isKindOfClass:[UIImage class]])
        self.popoverView.imageView.image = image;
    
    [self.popoverView presentAnnotationFromRect:_touchPointView.frame
                                         inView:self.view
                        permittedArrowDirection:self.popoverArrowDirection //
                                       animated:YES];
    
    //
    [self.view bringSubviewToFront:_touchPointView];
}


@end
