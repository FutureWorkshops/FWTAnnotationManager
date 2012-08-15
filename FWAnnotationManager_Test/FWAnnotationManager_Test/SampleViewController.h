//
//  SampleViewController.h
//  FWPopoverHintView_Test
//
//  Created by Marco Meschini on 8/8/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FWAnnotationManager.h"

@interface SampleViewController : UIViewController <FWAnnotationManagerDelegate>
{
    FWAnnotationManager *_fwPopoverController;
}
@end
