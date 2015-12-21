//
//  DetailViewController.m
//  ObjCMaps
//
//  Created by HoodsDream on 11/24/15.
//  Copyright © 2015 HoodsDream. All rights reserved.
//

#import "DetailViewController.h"
@import Parse;


@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *coordinateLabel;
@property (strong,nonatomic) CLLocationManager *locationManager;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%@", self.annotationTitle);
    NSLog(@"%d", self.coordinate);
    NSString *labelString = [[NSString alloc] initWithFormat:@"%d", self.coordinate];
    [self.coordinateLabel setText:labelString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)setRegionButtonPressed:(id)sender {
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        
        CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:self.coordinate radius:200 identifier:@"reminder"];
        [self.locationManager startMonitoringForRegion:region];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddedReminder" object:self userInfo:@{@"region" : region}];
        
        PFGeoPoint *geopoint = [[PFGeoPoint alloc] init];
        geopoint.latitude = self.coordinate.latitude;
        geopoint.longitude = self.coordinate.longitude;
        
        PFObject *regions = [PFObject objectWithClassName:@"Regions"];
        regions[@"location"] = geopoint;
        regions[@"username"] = PFUser.currentUser.username;
        [regions saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // The object has been saved.
                NSLog(@"the object was saved");
                [self.navigationController popToRootViewControllerAnimated:true];
            } else {
                // There was a problem, check error.description
                NSLog(@"nope");
                [self.navigationController popToRootViewControllerAnimated:true];
            }
        }];
    }
    
    
}



@end
