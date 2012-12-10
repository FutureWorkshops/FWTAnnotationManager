#FWTAnnotationManager

![FWTAnnotationManager screenshot](http://grab.by/ia7m)

FWTAnnotationManager is a small set of classes that makes easy to manage custom annotations for each screen of your app. 

FWTAnnotationManager extends our [FWTPopoverView](https://github.com/FutureWorkshops/FWTPopover) project and changes the methaphor from a simple popover view to a slightly more complex annotation view. As Apple does with MapKit, the FWTAnnotationManager uses FWTAnnotation objects to provide annotation related informations inside a view controller. An FWTAnnotation instance does not provide the visual representation of the annotation but typically coordinate (in conjuction with your custom blocks) the creation of an appropriate FWTAnnotationView object to handle the display.  

The FWTAnnotationManager can be considered as an extension of a UIViewController instance and typically you interact with it by adding or removing annotation objects. It supports also a sequential and delayed order when displaying multiple annotations.


##Requirements
* XCode 4.4.1 or higher
* iOS 5.0

##Features
Each FWTAnnotationManager has a container view that holds all the annotation views and a model object that stores annotations and exposes, as a MKMapView, few public methods to retrieve views/annotations. The container view can be of two different types: default or radial. The latter one is a quite nice and advanced sample about a possible way to customize the FWTAnnotationManager: for each annotation the container view creates a spotlight (a real hole) in the background matching the position of the annotation view. 
FWTAnnotationManager replaces the standard delegate pattern with a faster block approach (optional). There are two customizable blocks: the first one returns the FWTAnnotationView instance/subclass for the particular annotation object and the latter one is called when a particular annotation is tapped. 
The FWTAnnotationManager, as default behaviour, dismisses itself when the user tap the background and no animations are currently running.        
 
This project is not yet ARC-ready.

##How to use it: initializing
TODO


##How to use it: configure

####FWTAnnotation
TODO

####FWTAnnotationView
TODO

####FWTAnnotationsContainerViewType 
TODO

####FWTAnnotationManagerViewForAnnotationBlock
TODO  

####FWTAnnotationManagerDidTapAnnotationBlock 
TODO


##View hierarchy

##For your interest

##Demo
The sample project shows how to use the FWTAnnotationManager and how to create a custom annotation view.

	//	inside your view controller, time to display the annotations
	NSArray *annotationsArray = [self _annotationsArray];
    [self fwt_addAnnotations:annotationsArray];
    

	- (NSArray *)_annotationsArray
	{
		// creates some annotations
		FWTAnnotation *ann0 = [[[FWTAnnotation alloc] init] autorelease];
    	ann0.presentingRectPortrait = CGRectMake(240, 440, 1, 1);
    	ann0.presentingRectLandscape = CGRectMake(260, 220, 1, 1);
    	ann0.arrowDirection = FWTPopoverArrowDirectionDown;
    	ann0.animated = YES;
    	ann0.text = @"No, Donny, these men are nihilists, there's nothing to be afraid of.";
    	
    	FWTAnnotation *ann1 = […]
    	
    	return @[ann0, ann1, …];
	}


##Licensing
Apache License Version 2.0

##Credits
[Saudi Telecom Mobile](http://www.stc.com.sa) Apps team, who enabled and collaborated with us to extract source code from My STC App for this library

##Support, bugs and feature requests
If you want to submit a feature request, please do so via the issue tracker on github.
If you want to submit a bug report, please also do so via the issue tracker, including a diagnosis of the problem and a suggested fix (in code).
