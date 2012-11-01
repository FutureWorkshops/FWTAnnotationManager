//
//  FWTLabelPopoverView.h
//  FWTPopoverHintView
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "FWTPopoverView.h"

@interface FWTDefaultAnnotationView : FWTPopoverView
{
    UILabel *_textLabel;
    UIImageView *_imageView;
}

@property (nonatomic, assign) UIEdgeInsets contentViewEdgeInsets;
@property (nonatomic, readonly, retain) UILabel *textLabel;
@property (nonatomic, readonly, retain) UIImageView *imageView;

@end
