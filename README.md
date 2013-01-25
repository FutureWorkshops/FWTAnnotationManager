#FWTAnnotationManager

![FWTAnnotationManager screenshot](http://grab.by/ia7m)

FWTAnnotationManager is a small set of classes that lets you easily manage custom annotations for the desired screens within your app. 

FWTAnnotationManager extends our [FWTPopoverView](https://github.com/FutureWorkshops/FWTPopover) project and changes the methaphor from a simple popover view to a slightly more complex annotation view. As Apple does with MapKit, the FWTAnnotationManager uses FWTAnnotation objects to provide relevant information inside of a view controller. An FWTAnnotation instance does not provide the visual representation of the annotation, but typically coordinates (in conjuction with your custom blocks) the creation of an appropriate FWTAnnotationView object to handle the display.  

The FWTAnnotationManager can be considered an extension of a UIViewController instance; typically you would interact with it by adding or removing annotation objects. It also supports both sequential and delayed orders when displaying multiple annotations.


##Requirements
* XCode 4.4.1 or higher
* iOS 5.0

##Features
Each FWTAnnotationManager has a container view that holds all the annotation views and a model object that stores annotations and exposes, as a MKMapView, few public methods to retrieve views/annotations. The container view comes in two distinct types: default and radial. The latter is a sleeker and more advanced example for one of the possible ways in which the FWTAnnotationManager can be customised: for each annotation the container view creates a spotlight (a small hole) in the background, matching the position of the annotation view.       
 
This project is not yet ARC-ready.

##How to use it: initializing
You don't need to initialize an FWTAnnotationManager instance directly. Instead you'll ask your view controller to return its associated manager objects.   


##How to use it: configuration

####UIViewController (FWTAnnotationManager)
This category exposes the associated FWTAnnotationManager instance and a basic interface to add and remove annotations.

####FWTAnnotation
An FWTAnnotation instance coordinates the creation of an appropriate FWTAnnotationView object to handle the display. This class exposes position and presentation attributes as well as data values.

* **presentingRectPortrait** the rectangle to anchor the annotation in, portrait view
* **presentingRectLandscape** the rectangle to anchor the annotation in, landscape view
* **arrowDirection** the direction in which the popover arrow is pointing
* **delay** the amount of time (measured in seconds) to wait before beginning the animations. Specify a value of 0 to begin the animations immediately
* **animated** set YES (default) to animate the presentation
* **dismissOnTouch** set YES (default) if you want the annotation to be dismissed on tap
* **text** the text of the annotation 
* **image** the image to use as content for the annotation

####FWTAnnotationView
FWTAnnotationView subclasses FWTPopoverView and adds the following extra properties:

* **contentViewEdgeInsets** the inset or outset margins for the edges of the content view. Use this property to resize and reposition the effective rectangle
* **textLabel** (_readonly_) the label used for the textual content of the annotation
* **imageView** (_readonly_) the image view of the annotation

FWTAnnotationView takes into account its text value and resize itself when needed respecting the current contentSize. The image is left aligned and vertically centered as in tableview cells. 

####FWTAnnotationManager

FWTAnnotationManager replaces the standard delegate pattern with a faster block approach (optional). There are two customizable blocks: the first one returns the FWTAnnotationView instance/subclass for the particular annotation object and the latter one is called when a particular annotation is tapped. 
The FWTAnnotationManager, as default behaviour, dismisses itself when the user tap the background and no animations are currently running.  

* **annotationContainerViewType** 
* **annotationsContainerView** the superview for annotation views displayed by the receiver
* **model**
* **viewForAnnotationBlock** a block object that returns the annotation view for the given annotation 
* **didTapAnnotationBlock** a block object to be executed when a view is touched
* **didEndPresentBlock** a block object to be executed when the present animation sequence ends
* **didEndDismissBlock** a block object to be executed when the dismiss animation ends
* **dismissOnBackgroundTouch** a boolean value that enables the dismiss when the user touches an empty area of the screen. Default is YES
* **visible** a boolean value that determines wheter the receiver is visible

####FWTAnnotationContainerView 
Each FWTAnnotationManager has an _annotationsContainerView_ that holds all the annotation views. The base class is FWTAnnotationContainerView and it exposes three public methods:

* **addAnnotation:withView:**
* **removeAnnotation:withView:**
* **cancel**

to make easy to extend and customize the behaviour of the container. 
FWTAnnotationManager currently comes with two different types of container view:

* **FWTAnnotationContainerViewTypeDefault**
* **FWTAnnotationContainerViewTypeRadial**

If the annotationsContainerView has a backgroundColor then the FWTAnnotationManager will fade in/fade out the view when adding the first annotation/removing the last one.

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
[Saudi Telecom](http://www.stc.com.sa) Mobile Apps team, who enabled and collaborated with us to extract source code from My STC App for this library

##Support, bugs and feature requests
If you want to submit a feature request, please do so via the issue tracker on github.
If you want to submit a bug report, please also do so via the issue tracker, including a diagnosis of the problem and a suggested fix (in code).
