//
//  FWTLabelPopoverView.m
//  FWTPopoverHintView
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "FWTAnnotationView.h"

const CGFloat FWTDefaultAnnotationViewSpaceBetweenImageViewAndTextLabel = 5.0f;

@interface FWTAnnotationView ()
@property (nonatomic, readwrite, retain) UILabel *textLabel;
@property (nonatomic, readwrite, retain) UIImageView *imageView;
@property (nonatomic, assign) CGFloat spaceBetweenImageViewAndTextLabel;
@end

@implementation FWTAnnotationView
@synthesize textLabel = _textLabel;
@synthesize imageView = _imageView;

- (void)dealloc
{
    self.textLabel = nil;
    self.imageView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.contentViewEdgeInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
        self.spaceBetweenImageViewAndTextLabel = FWTDefaultAnnotationViewSpaceBetweenImageViewAndTextLabel;
        
//        self.contentView.layer.borderWidth = 1.0f;
//        self.contentView.layer.borderColor = [[UIColor redColor] colorWithAlphaComponent:.25f].CGColor;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = UIEdgeInsetsInsetRect(self.contentView.frame, self.contentViewEdgeInsets);
    
    [self _layoutTextLabel];
    
    [self _layoutImageView];
}

#pragma mark - Private
- (void)_layoutTextLabel
{
    if (self->_textLabel)
    {
        if (!self.textLabel.superview)
            [self.contentView addSubview:self.textLabel];
        
        CGRect textLabelFrame = self.contentView.bounds;
        if (self->_imageView)
        {
            CGFloat imageWidth = self.imageView.image.size.width + self.spaceBetweenImageViewAndTextLabel;
            textLabelFrame.origin.x += imageWidth;
            textLabelFrame.size.width -= imageWidth;
        }
        
        self.textLabel.frame = textLabelFrame;
    }
}

- (void)_layoutImageView
{
    if (self->_imageView)
    {
        if (!self.imageView.superview)
            [self.contentView addSubview:self.imageView];
        
        CGRect imageViewFrame = self.contentView.bounds;
        imageViewFrame.origin.y += (imageViewFrame.size.height - self.imageView.image.size.height)*.5f;
        imageViewFrame.size = self.imageView.image.size;
        self.imageView.frame = imageViewFrame;
    }
}

#pragma mark - Getters
- (UILabel *)textLabel
{
    if (!self->_textLabel)
        self->_textLabel = [[UILabel alloc] init];
    
    return self->_textLabel;
}

- (UIImageView *)imageView
{
    if (!self->_imageView)
        self->_imageView = [[UIImageView alloc] init];
    
    return self->_imageView;
}

#pragma mark - Overrides
- (void)presentFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirection:(FWTPopoverArrowDirection)arrowDirection animated:(BOOL)animated
{
    //  Calculate the available space and then get the size of the text
    //
    CGFloat imageWidth = .0f;
    if (self->_imageView)
        imageWidth = self.imageView.image.size.width + self.spaceBetweenImageViewAndTextLabel;

    if (self->_textLabel)
    {
        CGFloat widthToRemove = self.contentViewEdgeInsets.left + self.contentViewEdgeInsets.right + imageWidth;
        CGFloat heightToAdd = self.contentViewEdgeInsets.top + self.contentViewEdgeInsets.bottom;
        CGFloat avalaibleWidth = self.contentSize.width - widthToRemove;
        CGSize size = [self.textLabel.text sizeWithFont:self.textLabel.font constrainedToSize:CGSizeMake(avalaibleWidth, MAXFLOAT)];
        size.height += heightToAdd;
        CGSize newContentSize = self.contentSize;
        newContentSize.height = MAX(newContentSize.height, size.height);
        self.contentSize = newContentSize;
    }

    //
    [super presentFromRect:rect inView:view permittedArrowDirection:arrowDirection animated:animated];
}

@end
