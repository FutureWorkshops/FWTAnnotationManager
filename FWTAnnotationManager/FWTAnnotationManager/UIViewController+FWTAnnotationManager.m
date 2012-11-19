//
//  UIView+FWTAnnotationManager.m
//  FWTAnnotationManager
//
//  Created by Marco Meschini on 15/11/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import "UIViewController+FWTAnnotationManager.h"
#import "FWTAnnotationManager.h"
#import <objc/runtime.h>

static char annotationManagerKey;

@implementation UIViewController (FWTAnnotationManager)

#pragma mark - Public
- (FWTAnnotationManager *)fwt_annotationManager
{
    FWTAnnotationManager *manager = objc_getAssociatedObject(self, &annotationManagerKey);
    if (!manager)
    {
        manager = [[[FWTAnnotationManager alloc] init] autorelease];
        [self addChildViewController:manager];
        [manager didMoveToParentViewController:self];
        objc_setAssociatedObject(self, &annotationManagerKey, manager, OBJC_ASSOCIATION_RETAIN);
    }
    
    return manager;
}

- (NSArray *)fwt_annotations
{
    return self.fwt_annotationManager.model.annotations;
}

- (void)fwt_addAnnotation:(FWTAnnotation *)annotation
{
    [self.fwt_annotationManager addAnnotation:annotation];
}

- (void)fwt_addAnnotations:(NSArray *)annotations
{
    [self.fwt_annotationManager addAnnotations:annotations];
}

- (void)fwt_removeAnnotation:(FWTAnnotation *)annotation
{
    [self.fwt_annotationManager removeAnnotation:annotation];
}

- (void)fwt_removeAnnotations:(NSArray *)annotations
{
    [self.fwt_annotationManager removeAnnotations:annotations];
}

@end
