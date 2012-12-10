//
//  CustomViewController.m
//  FWAnnotationManager_Test
//
//  Created by Marco Meschini on 30/11/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import "CustomViewController.h"
#import "CustomAnnotationView.h"

@interface CustomViewController ()

@end

@implementation CustomViewController

- (void)configureAnnotationsManager
{
    self.fwt_annotationManager.annotationContainerViewType = FWTAnnotationContainerViewTypeRadial;
    __block typeof(self) myself = self;
    self.fwt_annotationManager.viewForAnnotationBlock = ^(FWTAnnotation *annotation){
        CustomAnnotationView *_annotationView = [[[CustomAnnotationView alloc] init] autorelease];
        [_annotationView setupAnimationHelperWithSuperview:myself.view];
        return _annotationView;
    };
}

@end
