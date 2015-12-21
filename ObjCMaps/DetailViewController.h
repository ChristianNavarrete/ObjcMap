//
//  DetailViewController.h
//  ObjCMaps
//
//  Created by HoodsDream on 11/24/15.
//  Copyright © 2015 HoodsDream. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSString *annotationTitle;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end
