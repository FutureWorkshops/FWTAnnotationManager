//
//  FWTAnnotationModel.m
//  FWTAnnotationManager
//
//  Created by Marco Meschini on 09/11/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import "FWTAnnotationModel.h"
#import "FWTAnnotation.h"
#import "FWTDefaultAnnotationView.h"

@interface FWTAnnotationModel ()
@property (nonatomic, retain) NSMutableArray *mutableAnnotations;
@property (nonatomic, retain) NSMutableDictionary *annotationsDictionary;
@end

@implementation FWTAnnotationModel
@synthesize mutableAnnotations = _mutableAnnotations;
@synthesize annotationsDictionary = _annotationsDictionary;
@synthesize annotations = _annotations;

- (void)dealloc
{
    self.mutableAnnotations = nil;
    self.annotationsDictionary = nil;
    [super dealloc];
}

- (NSMutableArray *)mutableAnnotations
{
    if (!self->_mutableAnnotations) self->_mutableAnnotations = [[NSMutableArray alloc] init];
    return self->_mutableAnnotations;
}

- (NSMutableDictionary *)annotationsDictionary
{
    if (!self->_annotationsDictionary) self->_annotationsDictionary = [[NSMutableDictionary alloc] init];
    return self->_annotationsDictionary;
}

#pragma mark - Public
- (NSArray *)annotations
{
    return [[self.mutableAnnotations copy] autorelease];
}

- (void)addAnnotation:(FWTAnnotation *)annotation withView:(FWTDefaultAnnotationView *)annotationView
{
    [self.mutableAnnotations addObject:annotation];
    [self.annotationsDictionary setObject:annotationView forKey:annotation.guid];
}

- (void)removeAnnotation:(FWTAnnotation *)annotation
{
    [self.mutableAnnotations removeObject:annotation];
    [self.annotationsDictionary removeObjectForKey:annotation.guid];
}

- (FWTDefaultAnnotationView *)viewForAnnotation:(FWTAnnotation *)annotation
{
    return [self.annotationsDictionary objectForKey:annotation.guid];
}

- (FWTAnnotation *)annotationForView:(FWTDefaultAnnotationView *)view
{
    __block FWTAnnotation *toReturn = nil;
    [self.mutableAnnotations enumerateObjectsUsingBlock:^(FWTAnnotation *annotation, NSUInteger idx, BOOL *stop) {
        FWTDefaultAnnotationView *_popoverView = [self viewForAnnotation:annotation];
        if (_popoverView == view)
        {
            toReturn = annotation;
            *stop = YES;
        }
    }];
    
    return toReturn;
}

- (FWTDefaultAnnotationView *)viewAtPoint:(CGPoint)point
{
    __block FWTDefaultAnnotationView *toReturn = nil;
    [self.annotationsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, FWTDefaultAnnotationView *obj, BOOL *stop) {
        if (CGRectContainsPoint(obj.frame, point))
        {
            toReturn = obj;
            *stop = YES;
        }
    }];
    
    return toReturn;
}

- (void)enumerateAnnotationsUsingBlock:(void (^)(FWTAnnotation *annotation, NSUInteger idx, BOOL *stop))block
{
    [self.mutableAnnotations enumerateObjectsUsingBlock:block];
}

- (NSInteger)numberOfAnnotations
{
    return self.mutableAnnotations.count;
}

@end
