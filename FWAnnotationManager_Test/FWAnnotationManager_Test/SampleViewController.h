//
//  SampleViewController.h
//  FWTPopoverHintView_Test
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FWTAnnotationManager.h"

@interface SampleViewController : UIViewController <FWTAnnotationManagerDelegate>
{
    FWTAnnotationManager *_fwPopoverController;
}
@end
