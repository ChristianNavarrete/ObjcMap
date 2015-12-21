//
//  Annotation.h
//  ObjCMaps
//
//  Created by HoodsDream on 11/23/15.
//  Copyright © 2015 HoodsDream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Annotation : NSObject <MKAnnotation> {
    
    NSString *title;
    NSString *subtitle;
    CLLocationCoordinate2D coordinate;
    
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
