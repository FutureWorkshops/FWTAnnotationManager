//
//  FWTAnnotationModel.m
//  FWTAnnotationManager
//
//  Created by Marco Meschini on 09/11/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import "FWTAnnotationModel.h"
#import "FWTAnnotation.h"
#import "FWTAnnotationView.h"

@interface FWTAnnotation ()
@property (nonatomic, readonly, retain) NSString *guid;
@end

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

- (void)addAnnotation:(FWTAnnotation *)annotation withView:(FWTAnnotationView *)annotationView
{
    [self.mutableAnnotations addObject:annotation];
    [self.annotationsDictionary setObject:annotationView forKey:annotation.guid];
}

- (void)removeAnnotation:(FWTAnnotation *)annotation
{
    [self.annotationsDictionary removeObjectForKey:annotation.guid];
    [self.mutableAnnotations removeObject:annotation];
}

- (FWTAnnotationView *)viewForAnnotation:(FWTAnnotation *)annotation
{
    return [self.annotationsDictionary objectForKey:annotation.guid];
}

- (FWTAnnotation *)annotationForView:(FWTAnnotationView *)view
{
    __block FWTAnnotation *toReturn = nil;
    [self.mutableAnnotations enumerateObjectsUsingBlock:^(FWTAnnotation *annotation, NSUInteger idx, BOOL *stop) {
        id annotationView = [self.annotationsDictionary objectForKey:annotation.guid];
        if (annotationView == view)
        {
            toReturn = annotation;
            *stop = YES;
        }
    }];

    return toReturn;
}

- (FWTAnnotationView *)viewAtPoint:(CGPoint)point
{
    __block FWTAnnotationView *toReturn = nil;
    [self.annotationsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, FWTAnnotationView *obj, BOOL *stop) {
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
