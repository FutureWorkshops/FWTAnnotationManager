//
//  AppDelegate.m
//  FWTPopoverHintView_Test
//
//  Created by Marco Meschini on 7/12/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "AppDelegate.h"
#import "AnnotationViewController.h"
#import "IManagerViewController.h"
#import "SamplePickerViewController.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];//
    
    //
    SamplePickerViewController *vc = [[[SamplePickerViewController alloc] init] autorelease];
    vc.samples = @[@"AnnotationViewController", @"DefaultViewController", @"CustomViewController"];
    
    UINavigationController *nc = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    nc.toolbarHidden = NO;
    self.window.rootViewController = nc;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
