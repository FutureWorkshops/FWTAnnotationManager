//
//  CustomAnnotationView.m
//  FWAnnotationManager_Test
//
//  Created by Marco Meschini on 01/11/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import "CustomAnnotationView.h"

@implementation CustomAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //
        self.contentSize = CGSizeMake(160.0f, 40.0f);
        
        //
        self.arrow.cornerOffset = 10.0f;
        
        //
        self.textLabel.textAlignment = UITextAlignmentCenter;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.numberOfLines = 0;
        self.textLabel.font = [UIFont systemFontOfSize:12.0f];
        self.textLabel.textColor = [UIColor colorWithWhite:.91f alpha:1.0f];
        self.textLabel.shadowOffset = CGSizeMake(.0f, -.7f);
        self.textLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
        
        //
        self.backgroundHelper.cornerRadius = 9.0f;
        self.backgroundHelper.drawPathBlock = ^(CGContextRef ctx, FWTPopoverBackgroundHelper *backgroundHelper){
            
            //  clip to current path
            CGContextSaveGState(ctx);
            CGContextAddPath(ctx, backgroundHelper.path);
            CGContextClip(ctx);
            
            //  stroke a thick inner border
            CGRect innerShapeBounds = CGRectInset(backgroundHelper.pathFrame, 2.0f, 2.0f);
            UIBezierPath *innerBezierPath = [backgroundHelper bezierPathForRect:innerShapeBounds];
            CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
            CGContextSetLineWidth(ctx, 5.0f);
            CGContextSetLineJoin(ctx, kCGLineJoinRound);
            CGContextSetBlendMode(ctx, kCGBlendModeColorDodge);
            CGContextAddPath(ctx, innerBezierPath.CGPath);
            CGContextDrawPath(ctx, kCGPathStroke);
            CGContextRestoreGState(ctx);
        };
        
        //
        self.animationHelper.dismissDuration = .3f;
    }
    
    return self;
}

- (void)setupAnimationHelperWithSuperview:(UIView *)theSuperview
{
    __block typeof(self) myself = self;
    self.animationHelper.prepareBlock = ^{
        myself.frame = CGRectOffset(myself.frame, .0f, -theSuperview.frame.size.height);
    };
    
    self.animationHelper.presentAnimationsBlock = ^{
        myself.frame = CGRectOffset(myself.frame, .0f, theSuperview.frame.size.height + 5.0f);
    };
    
    self.animationHelper.presentCompletionBlock = ^(BOOL finished){
        [UIView animateWithDuration:.1f animations:^{
            myself.frame = CGRectOffset(myself.frame, .0f, -5.0f);
        }];
    };
    
    self.animationHelper.dismissAnimationsBlock = ^{
        myself.transform = ((arc4random()%1000) > 500) ? CGAffineTransformMakeRotation(M_PI*.5f):CGAffineTransformMakeRotation(-M_PI*.5f);
        myself.frame = CGRectOffset(myself.frame, .0f, theSuperview.frame.size.height);
    };
}

@end
