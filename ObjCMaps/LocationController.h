//
//  LocationController.h
//  ObjCMaps
//
//  Created by HoodsDream on 11/24/15.
//  Copyright © 2015 HoodsDream. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@protocol LocationControllerDelegate <NSObject>

- (void) locationControllerDidUpdateLocation:(CLLocation*)location;


@end


@interface LocationController : NSObject



@property (strong, nonatomic) CLLocationManager *locationManager;



@end
