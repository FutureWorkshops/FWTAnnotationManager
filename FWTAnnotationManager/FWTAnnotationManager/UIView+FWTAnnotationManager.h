//
//  UIView+FWTAnnotationManager.h
//  FWTAnnotationManager
//
//  Created by Marco Meschini on 15/11/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FWTAnnotation.h"
#import "FWTAnnotationManager.h"
#import "FWTAnnotationModel.h"

@interface UIView (FWTAnnotationManager)

@property (nonatomic, readonly) FWTAnnotationManager *fwt_annotationManager;
@property (nonatomic, readonly, copy) NSArray *fwt_annotations;

- (void)fwt_addAnnotation:(FWTAnnotation *)annotation;
- (void)fwt_addAnnotations:(NSArray *)annotations;
- (void)fwt_removeAnnotation:(FWTAnnotation *)annotation;
- (void)fwt_removeAnnotations:(NSArray *)annotations;

@end
