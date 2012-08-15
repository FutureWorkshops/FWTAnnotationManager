//
//  StaticModel.m
//  FWPopoverHintView_Test
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "StaticModel.h"
#import "FWAnnotation.h"

@implementation StaticModel

+ (NSString *)randomText
{
    static NSArray *_array = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
                
        _array = [[NSArray alloc] initWithObjects:
                  @"Tap to go back to list of numbers",
                  @"Tap and hold to re-order icons",
                  @"hello world! this is a very long long long text. And it's still not ended. Riders on the storm",
                  @"Ve vant ze money, Lebowski. Ja, uzzervize ve kill ze girl. Ja, it seems you have forgotten our little deal, Lebowski.",
                  @"Are these the Nazis, Walter?",
                  @"No, Donny, these men are nihilists, there's nothing to be afraid of.",
                  @"Ve don't care. Ve still vant ze money, Lebowski, or ve fuck you up.",
                  @"No, without a hostage, there is no ransom. That's what ransom is. Those are the fucking rules.",
                  @"Okay. So we take ze money you haf on you, und ve calls it eefen.",
                  @"Where's the fucking money Lebowski?",
                  @"What's this day of rest shit? What's this bullshit? I don't fuckin' care! It don't matter to Jesus. But you're not foolin' me, man. You might fool the fucks in the league office, but you don't fool Jesus. This bush league psyche-out stuff. Laughable, man - ha ha! I would have fucked you in the ass Saturday. I fuck you in the ass next Wednesday instead. Wooo! You got a date Wednesday, baby!",
                  nil];
        
    });
    
    NSInteger _index = arc4random()%_array.count;
    return [_array objectAtIndex:_index];
}

+ (UIImage *)randomImage
{
    static NSArray *_array = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSInteger count = 14;
        NSMutableArray *_tmp = [NSMutableArray arrayWithCapacity:count];
        
        //
        size_t locationsCount = 2;
        CGFloat locations[]   = {0.0f, 1.0f};
        CGFloat components[]  = {
            .0f, .0f, .0f, .0f,
            .0f, .0f, .0f, .41f
        };
        CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef _gradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, locationsCount);
        CGColorSpaceRelease(rgbColorspace);
        
        for (unsigned i=0; i<count; i++)
        {
            //
            UIColor *color = [UIColor colorWithHue:(CGFloat)i/count saturation:.6f brightness:.7f alpha:1.0];
            CGSize ctxSize = CGSizeMake(30.0f, 26.0f);
            UIGraphicsBeginImageContextWithOptions(ctxSize, NO, .0f);
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            [color setFill];
            UIRectFill(CGRectMake(.0f, .0f, ctxSize.width, ctxSize.height));
            CGContextDrawLinearGradient(ctx, _gradient, CGPointZero, CGPointMake(ctxSize.width, ctxSize.height), kCGGradientDrawsAfterEndLocation);
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            [_tmp addObject:image];
            
            if ((i%2) == 0)
                [_tmp addObject:[NSNull null]];
        }
        
        CGGradientRelease(_gradient);
        
        
        _array = [[NSArray alloc] initWithArray:_tmp];
    });
    
    NSInteger _index = arc4random()%_array.count;
    return [_array objectAtIndex:_index];
}

+ (NSArray *)popoverAnnotations
{
    static NSArray *_array = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //
        FWAnnotation *pd0 = [[[FWAnnotation alloc] init] autorelease];
        pd0.presentingRectPortrait = CGRectMake(200, 300, 1, 1);
        pd0.presentingRectLandscape = CGRectMake(300, 200, 1, 1);
        pd0.arrowDirection = FWAnnotationArrowDirectionDown;
        pd0.animated = YES;
        pd0.text = @"No, Donny, these men are nihilists, there's nothing to be afraid of.";
        
        //
        FWAnnotation *pd1 = [[[FWAnnotation alloc] init] autorelease];
        pd1.presentingRectPortrait = CGRectMake(30, 130, 1, 1);
        pd1.presentingRectLandscape = CGRectMake(30, 80, 1, 1);
        pd1.arrowDirection = FWAnnotationArrowDirectionLeft;
        pd1.animated = YES;
        pd1.text = @"Where's the fucking money Lebowski?";
        pd1.delay = .5f;
        
        //
        FWAnnotation *pd2 = [[[FWAnnotation alloc] init] autorelease];
        pd2.presentingRectPortrait = CGRectMake(300, 30, 1, 1);
        pd2.presentingRectLandscape = CGRectMake(480, 30, 1, 1);
        pd2.arrowDirection = FWAnnotationArrowDirectionRight;
        pd2.animated = YES;
        pd2.text = @"Are these the Nazis, Walter?";
        pd2.delay = 1.0f;
        
        _array = [[NSArray alloc] initWithObjects:pd0, pd1, pd2, nil];
    });
    
    return _array;
}

@end
