//
//  DefaultViewController.m
//  FWAnnotationManager_Test
//
//  Created by Marco Meschini on 30/11/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import "DefaultViewController.h"
#import "FWTAnnotationView.h"

@interface DefaultViewController ()

@end

@implementation DefaultViewController

- (void)configureAnnotationsManager
{
    FWTAnnotationManagerViewForAnnotationBlock viewForAnnotationBlock = ^(FWTAnnotation *annotation){
        FWTAnnotationView *_annotationView = [[[FWTAnnotationView alloc] init] autorelease];
        _annotationView.contentSize = CGSizeMake(180.0f, 40.0f);
        
        _annotationView.textLabel.numberOfLines = 0;
        _annotationView.textLabel.backgroundColor = [UIColor clearColor];
        _annotationView.textLabel.textColor = [UIColor colorWithWhite:.91f alpha:1.0f];
        _annotationView.textLabel.shadowOffset = CGSizeMake(.0f, -.7f);
        _annotationView.textLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
        _annotationView.textLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        
        return _annotationView;
    };
    
    self.fwt_annotationManager.viewForAnnotationBlock = viewForAnnotationBlock;
}

@end
