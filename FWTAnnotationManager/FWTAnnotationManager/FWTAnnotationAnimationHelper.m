//
//  FWTAnnotationAnimationHelper.m
//  FWTAnnotationManager
//
//  Created by Marco Meschini on 31/10/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import "FWTAnnotationAnimationHelper.h"
#import "FWTAnnotationView.h"

@interface FWTAnnotationAnimationHelper ()
@property (nonatomic, readwrite, assign) FWTAnnotationView *annotationView;
@end

@implementation FWTAnnotationAnimationHelper

- (void)dealloc
{
    self.prepareBlock = nil;
    self.presentAnimationsBlock = nil;
    self.dismissAnimationsBlock = nil;
    self.presentCompletionBlock = nil;
    self.dismissCompletionBlock = nil;
    self.annotationView = nil;
    [super dealloc];
}

- (id)initWithAnnotationView:(FWTAnnotationView *)annotationView
{
    if ((self = [super init]))
    {
        self.annotationView = annotationView;
        self.animationDuration = .25f;
        
        __block typeof(self.annotationView) theAnnotationView = self.annotationView;
        self.prepareBlock = ^{ theAnnotationView.alpha = .0f; };
        self.presentAnimationsBlock = ^{ theAnnotationView.alpha = 1.0f; };
        self.presentCompletionBlock = nil;
        self.dismissAnimationsBlock = ^{ theAnnotationView.alpha = .0f; };
        self.dismissCompletionBlock = nil;
    }
    
    return self;
}

- (void)safePerformBlock:(void (^)(void))block
{
    if (block) block();
}

- (void)safePerformCompletionBlock:(void (^)(BOOL finished))block finished:(BOOL)finished;
{
    if (block) block(finished);
}

@end
