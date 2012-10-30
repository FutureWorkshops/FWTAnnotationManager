//
//  SamplePickerViewController.m
//  FWTGridTableViewController_Test
//
//  Created by Marco Meschini on 7/17/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "SamplePickerViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SamplePickerViewController ()
{
    NSArray *_items;
}
@property (nonatomic, retain) NSArray *items;
@end

@implementation SamplePickerViewController
@synthesize items = _items;

- (void)dealloc
{
    self.items = nil;
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
    self.title = @"Pick a sample";
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor lightGrayColor];
    
    CAShapeLayer *boxLayer = [CAShapeLayer layer];
    boxLayer.frame = CGRectMake(100, 300, 100, 100);
//    boxLayer.borderWidth = 1.0f;
    boxLayer.fillColor = [[UIColor blackColor] colorWithAlphaComponent:.5f].CGColor;
    boxLayer.strokeColor = [UIColor blackColor].CGColor;
    [self.view.layer addSublayer:boxLayer];



//    CGFloat cornerRadius = 10.0f;
//    CGSize arrowSize = CGSizeMake(20.0f, 20.0f);
//    CGFloat shadowRadius = 10.0f;
//    NSInteger direction = 1;
//    
//    //
//    UIBezierPath *bp = [self bezierPathForRect:boxLayer.bounds cornerRadius:cornerRadius arrowSize:arrowSize direction:direction clockwise:NO];//[self bezierPathForRect:boxLayer.bounds direction:0 clockwise:NO];
////    boxLayer.path = bp.CGPath;
//    
//    //
//    CGRect shadowPathRect = CGRectInset(boxLayer.bounds, -shadowRadius, -shadowRadius);
//    UIBezierPath *shadowPath = [self bezierPathForRect:shadowPathRect cornerRadius:cornerRadius arrowSize:arrowSize direction:direction clockwise:YES];//[self bezierPathForRect: direction:0 clockwise:YES];
//    [bp appendPath:shadowPath];
////    boxLayer.shadowPath = bp.CGPath;
////    boxLayer.shadowOpacity = .4f;
////    boxLayer.shadowRadius = shadowRadius;
//    
//    boxLayer.path = bp.CGPath;
}

//      0
//  1       3
//      2
- (UIBezierPath *)bezierPathForRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius arrowSize:(CGSize)arrowSize direction:(NSInteger)direction clockwise:(BOOL)clockwiseEnabled
{
    CGFloat radius = cornerRadius;
    
    //
    //  ab  b           c   cd
    //
    //  a                   d
    //
    //  h                   e
    //
    //  gh  g           f   ef
    //
    CGPoint a  = CGPointMake(rect.origin.x, rect.origin.y + radius);
    CGPoint ab = CGPointMake(a.x, a.y - radius);
    CGPoint b  = CGPointMake(a.x + radius, a.y - radius);
    CGPoint c  = CGPointMake(a.x + rect.size.width - radius, rect.origin.y);
    CGPoint cd = CGPointMake(c.x + radius, c.y);
    CGPoint d  = CGPointMake(c.x + radius, c.y + radius);
    CGPoint e  = CGPointMake(a.x + rect.size.width, rect.origin.y + rect.size.height - radius);
    CGPoint ef = CGPointMake(e.x, e.y + radius);
    CGPoint f  = CGPointMake(e.x - radius, e.y + radius);
    CGPoint g  = CGPointMake(a.x + radius, rect.origin.y + rect.size.height);
    CGPoint gh = CGPointMake(g.x - radius, g.y);
    CGPoint h  = CGPointMake(g.x - radius, g.y - radius);
    
    //
    CGFloat halfArrowWidth = arrowSize.width*.5f;
    CGSize availableHalfRectSize = CGSizeMake((rect.size.width-2*radius)*.5f, (rect.size.height-2*radius)*.5f);
    
    enum {
        AxisTypeHorizontal = 0,
        AxisTypeVertical,
    };
    typedef NSUInteger AxisType;
    
    void(^AppendArrowBlock)(UIBezierPath *, CGPoint, NSInteger, AxisType) = ^(UIBezierPath *bezierPath, CGPoint point, NSInteger sign, AxisType axisType) {
        
        CGPoint a0, a1, a2;
        
        if (axisType == AxisTypeHorizontal)
        {
            a0 = CGPointMake(point.x + sign*(availableHalfRectSize.width - halfArrowWidth), point.y);
            a1 = CGPointMake(point.x + sign*(availableHalfRectSize.width), point.y - sign*(arrowSize.height));
            a2 = CGPointMake(point.x + sign*(availableHalfRectSize.width + halfArrowWidth), point.y);
        }
        else
        {
            a0 = CGPointMake(point.x, point.y + sign*(availableHalfRectSize.height - halfArrowWidth));
            a1 = CGPointMake(point.x + sign*(arrowSize.height), point.y + sign*(availableHalfRectSize.height));
            a2 = CGPointMake(point.x, point.y + sign*(availableHalfRectSize.height + halfArrowWidth));
        }
        
        [bezierPath addLineToPoint:a0];
        [bezierPath addLineToPoint:a1];
        [bezierPath addLineToPoint:a2];
    };
    
    //
    UIBezierPath *bp = [UIBezierPath bezierPath];
    [bp moveToPoint:a];
    if (!clockwiseEnabled)
    {
        [bp addQuadCurveToPoint:b controlPoint:ab];
        if (direction == 0)
            AppendArrowBlock(bp, b, 1, AxisTypeHorizontal);
        
        [bp addLineToPoint:c];
        [bp addQuadCurveToPoint:d controlPoint:cd];
        if (direction == 3)
            AppendArrowBlock(bp, d, 1, AxisTypeVertical);
        
        [bp addLineToPoint:e];
        [bp addQuadCurveToPoint:f controlPoint:ef];
        if (direction == 2)
            AppendArrowBlock(bp, f, -1, AxisTypeHorizontal);
        
        [bp addLineToPoint:g];
        [bp addQuadCurveToPoint:h controlPoint:gh];
        if (direction == 1)
            AppendArrowBlock(bp, h, -1, AxisTypeVertical);
    }
    else
    {
        if (direction == 1)
        {
            CGPoint a0 = CGPointMake(a.x, a.y + (availableHalfRectSize.height - halfArrowWidth));
            CGPoint a1 = CGPointMake(a.x - arrowSize.height, a.y + availableHalfRectSize.height);
            CGPoint a2 = CGPointMake(a.x, a.y + (availableHalfRectSize.height + halfArrowWidth));
            
            [bp addLineToPoint:a0];
            [bp addLineToPoint:a1];
            [bp addLineToPoint:a2];            
        }
        [bp addLineToPoint:h];
        [bp addQuadCurveToPoint:g controlPoint:gh];
        
        if (direction == 2)
        {
            CGPoint a0 = CGPointMake(g.x + (availableHalfRectSize.width - halfArrowWidth), g.y);
            CGPoint a1 = CGPointMake(g.x + (availableHalfRectSize.width), g.y + arrowSize.height);
            CGPoint a2 = CGPointMake(g.x + (availableHalfRectSize.width + halfArrowWidth), g.y);
            
            [bp addLineToPoint:a0];
            [bp addLineToPoint:a1];
            [bp addLineToPoint:a2];
        }
        
        [bp addLineToPoint:f];
        [bp addQuadCurveToPoint:e controlPoint:ef];
        if (direction == 3)
        {
            CGPoint a0 = CGPointMake(e.x, e.y - (availableHalfRectSize.height - halfArrowWidth));
            CGPoint a1 = CGPointMake(e.x + arrowSize.height, e.y - availableHalfRectSize.height);
            CGPoint a2 = CGPointMake(e.x, e.y - (availableHalfRectSize.height + halfArrowWidth));
            
            [bp addLineToPoint:a0];
            [bp addLineToPoint:a1];
            [bp addLineToPoint:a2];
        }
        
        [bp addLineToPoint:d];
        [bp addQuadCurveToPoint:c controlPoint:cd];
        if (direction == 0)
        {
            CGPoint a0 = CGPointMake(c.x - (availableHalfRectSize.width - halfArrowWidth), c.y);
            CGPoint a1 = CGPointMake(c.x - availableHalfRectSize.width, c.y - arrowSize.height);
            CGPoint a2 = CGPointMake(c.x - (availableHalfRectSize.width + halfArrowWidth), c.y);
            
            [bp addLineToPoint:a0];
            [bp addLineToPoint:a1];
            [bp addLineToPoint:a2];
        }
        
        [bp addLineToPoint:b];
        [bp addQuadCurveToPoint:a controlPoint:ab];
    }
    
    [bp closePath];
    
    return bp;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Getters
- (NSArray *)items
{
    if (!self->_items)
        self->_items = [@[@"TouchViewController", @"SampleViewController"] retain];
    
    return self->_items;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    cell.textLabel.text = [self.items objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *className = [self.items objectAtIndex:indexPath.row];
    UIViewController *vc = [[[NSClassFromString(className) alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
