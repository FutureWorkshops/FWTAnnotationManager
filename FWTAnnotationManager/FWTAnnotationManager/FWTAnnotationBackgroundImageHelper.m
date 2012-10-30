//
//  FWTAnnotationBackgroundImage.m
//  FWTAnnotationManager
//
//  Created by Marco Meschini on 30/10/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import "FWTAnnotationBackgroundImageHelper.h"
#import "FWTAnnotationView.h"

enum {
    AxisTypeHorizontal = 0,
    AxisTypeVertical,
};
typedef NSUInteger AxisType;

@interface FWTAnnotationBackgroundImageHelper ()
@property (nonatomic, readwrite, assign) FWTAnnotationView *annotationView;
@property (nonatomic, readwrite, retain) UIBezierPath *bezierPath;
@end

@implementation FWTAnnotationBackgroundImageHelper

- (void)dealloc
{
    self.annotationView = nil;
    self.bezierPath = nil;
    self.bezierPathColorFill = nil;
    self.bezierPathColorStroke = nil;
    [super dealloc];
}

- (id)initWithAnnotationView:(FWTAnnotationView *)annotationView
{
    if ((self = [super init]))
    {
        self.annotationView = annotationView;
        
        //
        self.cornerRadius = 6.0f;
        self.bezierPathColorFill = [[UIColor blackColor] colorWithAlphaComponent:.5f];
        self.bezierPathColorStroke = [UIColor blackColor];
        self.bezierPathLineWidth = 1.0f;
        self.shadowBlur = 8.0f;
        self.shadowOffset = CGSizeMake(.0f, 2.0f);
        self.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.75f];
    }
    
    return self;
}

- (UIImage *)resizableBackgroundImageForSize:(CGSize)size
{
    //
    UIEdgeInsets edgeInsets = self.annotationView.edgeInsets;
    FWTAnnotationArrowDirection arrowDirection = self.annotationView.arrowDirection;
    UIEdgeInsets capInsets = UIEdgeInsetsZero;
    CGSize contextSize = size;
    if (arrowDirection & FWTAnnotationArrowDirectionUp || arrowDirection & FWTAnnotationArrowDirectionDown)
    {
        contextSize.height = (self.cornerRadius * 2) + edgeInsets.top + edgeInsets.bottom + 1.0f;
        capInsets = UIEdgeInsetsMake(edgeInsets.top + self.cornerRadius, .0f, edgeInsets.bottom + self.cornerRadius, .0f);
    }
    
    if (arrowDirection & FWTAnnotationArrowDirectionLeft || arrowDirection & FWTAnnotationArrowDirectionRight)
    {
        contextSize.width = (self.cornerRadius * 2) + edgeInsets.left + edgeInsets.right + 1.0f;
        capInsets = UIEdgeInsetsMake(.0f, edgeInsets.left + self.cornerRadius, .0f, edgeInsets.right + self.cornerRadius);
    }
    
    //
    CGSize ctxSize = contextSize;
    CGRect rect = CGRectMake(.0f, .0f, ctxSize.width, ctxSize.height);
    
    //
    CGRect shapeBounds = UIEdgeInsetsInsetRect(rect, edgeInsets);
    self.bezierPath = [self _bezierPathForRect:shapeBounds];
    
    //
    UIImage *image = [self _backgroundImageForSize:ctxSize];
    return [image resizableImageWithCapInsets:capInsets];
}

#pragma mark - Private
- (UIBezierPath *)_bezierPathForRect:(CGRect)rect
{
    CGFloat radius = self.cornerRadius;
    
    //
    //  ab  b           c   cd
    //  a                   d
    //  h                   e
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
    
    FWTAnnotationArrowDirection arrowDirection = self.annotationView.arrowDirection;
    CGSize arrowSize = self.annotationView.arrow.arrowSize;
    CGFloat halfArrowWidth = arrowSize.width*.5f;
    CGSize availableHalfRectSize = CGSizeMake((rect.size.width-2*radius)*.5f, (rect.size.height-2*radius)*.5f);
    CGFloat ao = self.annotationView.arrow.arrowOffset;
    CGFloat ao_aco = self.annotationView.arrow.arrowOffset + self.annotationView.arrow.arrowCornerOffset;
    void(^AppendArrowBlock)(UIBezierPath *, CGPoint, NSInteger, AxisType) = ^(UIBezierPath *bezierPath, CGPoint point, NSInteger sign, AxisType axisType) {
        
        CGPoint a0, a1, a2;
        if (axisType == AxisTypeHorizontal)
        {
            a0 = CGPointMake(point.x + sign*(availableHalfRectSize.width - halfArrowWidth) + ao, point.y);
            a1 = CGPointMake(point.x + sign*(availableHalfRectSize.width) + ao_aco, point.y - sign*(arrowSize.height));
            a2 = CGPointMake(point.x + sign*(availableHalfRectSize.width + halfArrowWidth) + ao, point.y);
        }
        else
        {
            a0 = CGPointMake(point.x, point.y + sign*(availableHalfRectSize.height - halfArrowWidth) + ao);
            a1 = CGPointMake(point.x + sign*(arrowSize.height), point.y + sign*(availableHalfRectSize.height) + ao_aco);
            a2 = CGPointMake(point.x, point.y + sign*(availableHalfRectSize.height + halfArrowWidth) + ao);
        }
        
        [bezierPath addLineToPoint:a0];
        [bezierPath addLineToPoint:a1];
        [bezierPath addLineToPoint:a2];
    };
    
    //
    UIBezierPath *bp = [UIBezierPath bezierPath];
    [bp moveToPoint:a];
    [bp addQuadCurveToPoint:b controlPoint:ab];
    if (arrowDirection == FWTAnnotationArrowDirectionUp)
        AppendArrowBlock(bp, b, 1, AxisTypeHorizontal);
    [bp addLineToPoint:c];
    [bp addQuadCurveToPoint:d controlPoint:cd];
    if (arrowDirection == FWTAnnotationArrowDirectionRight)
        AppendArrowBlock(bp, d, 1, AxisTypeVertical);
    [bp addLineToPoint:e];
    [bp addQuadCurveToPoint:f controlPoint:ef];
    if (arrowDirection == FWTAnnotationArrowDirectionDown)
        AppendArrowBlock(bp, f, -1, AxisTypeHorizontal);
    [bp addLineToPoint:g];
    [bp addQuadCurveToPoint:h controlPoint:gh];
    if (arrowDirection == FWTAnnotationArrowDirectionLeft)
        AppendArrowBlock(bp, h, -1, AxisTypeVertical);
    [bp closePath];
    
    return bp;
}

- (UIImage *)_backgroundImageForSize:(CGSize)size
{
    //
    UIGraphicsBeginImageContextWithOptions(size, NO, .0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //  join with a rounded end
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    
    //  fill with a solid to get good shadow - then clear inside
    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetShadowWithColor(ctx, self.shadowOffset, self.shadowBlur, self.shadowColor.CGColor);
    CGContextAddPath(ctx, self.bezierPath.CGPath);
    CGContextDrawPath(ctx, kCGPathFill);
    CGContextRestoreGState(ctx);
    CGContextSaveGState(ctx);
    [self.bezierPath addClip];
    [[UIColor clearColor] setFill];
    UIRectFill(CGContextGetClipBoundingBox(ctx));
    CGContextRestoreGState(ctx);
    
    //  fill with the right color now
    CGContextSetFillColorWithColor(ctx, self.bezierPathColorFill.CGColor);
    CGContextAddPath(ctx, self.bezierPath.CGPath);
    CGContextDrawPath(ctx, kCGPathFill);
    
    //
    if (self.annotationView.drawPathBlock)
        self.annotationView.drawPathBlock(ctx, self.annotationView);
    
    //  stroke the border
    CGContextSetStrokeColorWithColor(ctx, self.bezierPathColorStroke.CGColor);
    CGContextSetLineWidth(ctx, self.bezierPathLineWidth);
    CGContextAddPath(ctx, self.bezierPath.CGPath);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    //
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
