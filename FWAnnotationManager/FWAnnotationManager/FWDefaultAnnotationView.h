//
//  FWLabelPopoverView.h
//  FWPopoverHintView
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "FWAnnotationView.h"

@interface FWDefaultAnnotationView : FWAnnotationView
{
    UILabel *_textLabel;
    UIImageView *_imageView;
}

@property (nonatomic, readonly, retain) UILabel *textLabel;
@property (nonatomic, readonly, retain) UIImageView *imageView;

@end
