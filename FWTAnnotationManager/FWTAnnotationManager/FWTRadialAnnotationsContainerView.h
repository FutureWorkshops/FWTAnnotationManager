//
//  FWTRadialAnnotationsContainerView.h
//  FWTAnnotationManager
//
//  Created by Marco Meschini on 09/11/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FWTAnnotationView;
@interface FWTRadialAnnotationsContainerView : UIView

- (void)addAnnotationView:(FWTAnnotationView *)annotationView;
- (void)removeAnnotationView:(FWTAnnotationView *)annotationView;
- (void)cancel;

@end
