//
//  FWTAnnotationContainerView.h
//  FWTAnnotationManager
//
//  Created by Marco Meschini on 10/12/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FWTAnnotation.h"
#import "FWTAnnotationView.h"

@interface FWTAnnotationContainerView : UIView

- (void)addAnnotation:(FWTAnnotation *)annotation withView:(FWTAnnotationView *)annotationView;
- (void)removeAnnotation:(FWTAnnotation *)annotation withView:(FWTAnnotationView *)annotationView;
- (void)cancel;

@end
