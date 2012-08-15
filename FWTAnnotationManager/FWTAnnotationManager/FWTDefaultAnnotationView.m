//
//  FWTLabelPopoverView.m
//  FWTPopoverHintView
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "FWTDefaultAnnotationView.h"

@interface FWTAnnotationView ()
@property (nonatomic, readwrite) FWTAnnotationArrowDirection arrowDirection;
- (void)adjustEdgeInsets;
@end

@interface FWTDefaultAnnotationView ()
{
    BOOL _textLabelEnabled, _imageViewEnabled;
}
@property (nonatomic, readwrite, retain) UILabel *textLabel;
@property (nonatomic, readwrite, retain) UIImageView *imageView;
@property (nonatomic, assign) BOOL textLabelEnabled, imageViewEnabled;
@end

@implementation FWTDefaultAnnotationView
@synthesize textLabel = _textLabel;
@synthesize imageView = _imageView;
@synthesize textLabelEnabled = _textLabelEnabled;
@synthesize imageViewEnabled = _imageViewEnabled;

- (void)dealloc
{
    self.textLabel = nil;
    self.imageView = nil;
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
        
    //
    if (self.textLabelEnabled)
    {
        if (!self.textLabel.superview)
            [self.contentView addSubview:self.textLabel];
        
        CGRect contentViewBounds = self.contentView.bounds;
        if (self.imageViewEnabled)
        {
            CGFloat imageWidth = self.imageView.image.size.width;
            contentViewBounds.origin.x += imageWidth;
            contentViewBounds.size.width -= imageWidth;
        }
                
        CGRect textLabelFrame = contentViewBounds;
        self.textLabel.frame = textLabelFrame;
    }
    
    //
    if (self.imageViewEnabled)
    {
        if (!self.imageView.superview)
            [self.contentView addSubview:self.imageView];
     
        CGRect contentViewBounds = self.contentView.bounds;
        CGRect imageViewFrame = contentViewBounds;
        imageViewFrame.origin.y += (imageViewFrame.size.height - self.imageView.image.size.height)*.5f;
        imageViewFrame.size = self.imageView.image.size;
        self.imageView.frame = imageViewFrame;
    }
}

#pragma mark - Getters
- (UILabel *)textLabel
{
    if (!self->_textLabel)
    {
        self.textLabelEnabled = YES;
        self->_textLabel = [[UILabel alloc] init];
    }
    
    return self->_textLabel;
}

- (UIImageView *)imageView
{
    if (!self->_imageView)
    {
        self.imageViewEnabled = YES;
        self->_imageView = [[UIImageView alloc] init];
    }
    
    return self->_imageView;
}

#pragma mark - Overrides
- (void)presentAnnotationFromRect:(CGRect)rect
                        inView:(UIView *)view
       permittedArrowDirection:(FWTAnnotationArrowDirection)arrowDirection
                      animated:(BOOL)animated
{
    //
    self.arrowDirection = arrowDirection;
    
    //
    self.edgeInsets = self.desiredEdgeInsets;
    [self adjustEdgeInsets];
    
    //  calculate how much space we have and then calculate the size of the text
    //
    CGFloat imageWidth = .0f;
    if (self.imageViewEnabled)
        imageWidth = self.imageView.image.size.width;
    
    CGFloat widthToRemove = self.edgeInsets.left + self.edgeInsets.right + self.contentViewEdgeInsets.left + self.contentViewEdgeInsets.right + imageWidth;
    CGFloat heightToAdd = self.edgeInsets.top + self.edgeInsets.bottom + self.contentViewEdgeInsets.top + self.contentViewEdgeInsets.bottom;
    CGFloat avalaibleWidth = self.contentSize.width - widthToRemove;
    CGSize size = [self.textLabel.text sizeWithFont:self.textLabel.font constrainedToSize:CGSizeMake(avalaibleWidth, MAXFLOAT)];
    size.height += heightToAdd;
    CGSize newContentSize = self.contentSize;
    newContentSize.height = MAX(newContentSize.height, size.height);
    self.contentSize = newContentSize;
    
    [super presentAnnotationFromRect:rect inView:view permittedArrowDirection:arrowDirection animated:animated];
}



@end
