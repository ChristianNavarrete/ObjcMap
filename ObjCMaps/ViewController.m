//
//  ViewController.m
//  ObjCMaps
//
//  Created by HoodsDream on 11/23/15.
//  Copyright © 2015 HoodsDream. All rights reserved.
//

#import "ViewController.h"
#import "Annotation.h"
#import "DetailViewController.h"
@import UIKit;
@import CoreLocation;
@import Parse;

@interface ViewController () <MKMapViewDelegate>

@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView  *mapView;
@property (strong, nonatomic) UILongPressGestureRecognizer *gesture;
@property BOOL *creatingAccount;
@property (strong, nonatomic) PFUser *user;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signInTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

//TextFields
@property (weak, nonatomic) IBOutlet UILabel *AppNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *rePasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (strong, nonatomic) NSArray *locationsArray;

@property (nonatomic) BOOL showedLocation;

@property (nonatomic) CLLocationCoordinate2D userLocation;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupView];
    //[self retrieveRegions];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addReminder:) name:@"AddedReminder" object:nil];
}

-(void)retrieveRegions {
    
    
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"Regions"];
    [query whereKey:@"username" equalTo:PFUser.currentUser.username];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects) {
            
            self.locationsArray = objects;
            NSLog(@"%lu",objects.count);
            
            for (int i = 1; i <= self.locationsArray.count; i++)
            {
                
                NSDictionary *parseGeopoint = [self.locationsArray objectAtIndex:i];
                PFGeoPoint * geopoint = [parseGeopoint objectForKey:@"location"];
                
                NSLog(@"%f", geopoint.latitude);
                NSLog(@"%f", geopoint.longitude);
                CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(geopoint.latitude, geopoint.longitude) radius:200 identifier:@"reminder"];
                MKCircle *regionOverlay = [MKCircle circleWithCenterCoordinate:region.center radius:region.radius];
                [self.mapView addOverlay:regionOverlay];
                
            }
            
            
        } else if (error) {
            NSLog(@"error description: %@", error.description);
        }
        
    }];
    
    
}


-(void) setupView {
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    
    [self.mapView setShowsUserLocation:YES];
    self.mapView.delegate = self;
    
    [self addGesutureRecognizer];
    self.creatingAccount = false;
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    [self.navigationController.navigationBar setTranslucent:false];
    
    self.navigationItem.rightBarButtonItem = nil;
    
    self.usernameTextField.alpha = 1;
    self.emailTextField.alpha = 1;
    self.passwordTextField.alpha = 1;
    self.signInButton.alpha = 1;
    self.createAccountButton.alpha = 1;
    self.blurView.alpha = 1;
    self.AppNameLabel.alpha = 1;
    
    self.rePasswordTextField.alpha = 0;
    self.emailTextField.alpha = 0;
}


-(void) clearFieldsForAppStart {
    
    [UIView animateWithDuration:0.4 animations:^{
        self.usernameTextField.alpha = 0;
        self.emailTextField.alpha = 0;
        self.passwordTextField.alpha = 0;
        self.rePasswordTextField.alpha = 0;
        self.emailTextField.alpha = 0;
        self.signInButton.alpha = 0;
        self.createAccountButton.alpha = 0;
        self.blurView.alpha = 0;
        self.AppNameLabel.alpha = 0;
        
        [self.usernameTextField resignFirstResponder];
        [self.passwordTextField resignFirstResponder];
        [self.emailTextField resignFirstResponder];
        [self.rePasswordTextField resignFirstResponder];
        
        MKCoordinateRegion myRegion;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.005;
        span.longitudeDelta = 0.005;
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = self.userLocation.latitude;
        coordinate.longitude = self.userLocation.longitude;
        myRegion.center = coordinate;
        myRegion.span = span;
        
        [self.locationManager stopUpdatingLocation];
        
        if (self.showedLocation == true) {
            NSLog(@"already showed location");
            [self.locationManager stopUpdatingLocation];
        } else {
            [self.mapView setRegion:myRegion animated:YES];
            self.showedLocation = true;
        }
        
        
        [self.mapView setRegion:myRegion animated:true];
    }];
    
    
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([segue.identifier isEqualToString:@"DetailViewController"]) {
        if ([sender isKindOfClass:[MKAnnotationView class]]) {
            MKAnnotationView *annotationView = (MKAnnotationView *)sender;
            DetailViewController *detailViewController = (DetailViewController *)segue.destinationViewController;
            detailViewController.annotationTitle = annotationView.annotation.title;
            detailViewController.coordinate = annotationView.annotation.coordinate;
        }
    }
    
    
}



#pragma mark - Parse Sign In /Log out

-(void) loginWithParse:(NSString *)username password:(NSString*)password{
    PFUser *user = [PFUser user];
    user.username = username;
    user.password = password;
    
    [self viewDidAppear:true];
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if (!error) {
            //YAY
            NSLog(@"%@",PFUser.currentUser.username);
            UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(signout:)];
            [self.navigationItem setRightBarButtonItem:barButton];
            [self clearFieldsForAppStart];
            [self retrieveRegions];
            NSLog(@"the num o reginons in the location Manager is %lu", self.locationManager.monitoredRegions.count);
        } else {
            NSLog(@"Something went wrong with logging the user in");
        }
    }];
    
}

-(IBAction)signout:(id)sender
{
    [PFUser logOut];
    [self viewDidLoad];
    self.usernameTextField.text = @"";
    self.passwordTextField.text = @"";
    self.rePasswordTextField.text = @"";
    self.emailTextField.text = @"";

}

-(void) signUpWithParse:(NSString *)username password:(NSString*)password email:(NSString *)email {
    PFUser *user = [PFUser user];
    user.username = username;
    user.password = password;
    user.email = email;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self clearFieldsForAppStart];
            NSLog(@"%@",PFUser.currentUser.username);
        } else {
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"%@",errorString);
        }
    }];
}



- (IBAction)SignInPressed:(id)sender {
    
    NSLog(@"sign in button pressed");
    if (self.creatingAccount) {
        if ([self.usernameTextField.text isEqual: @""] && [self.passwordTextField.text isEqual: @""] && [self.emailTextField.text isEqual: @""]  ) {
            NSLog(@"make sure all fields are typed correctly");
        } else {
            NSLog(@"trying to sign up user");
            [self signUpWithParse:self.usernameTextField.text password:self.passwordTextField.text email:self.emailTextField.text];
        }
        
    } else {
        if ([self.usernameTextField.text isEqual: @""] && [self.passwordTextField.text isEqual: @""] ) {
            NSLog(@"make sure all fields are typed correctly");
        } else {
            NSLog(@"trying to log in user");
            [self loginWithParse:self.usernameTextField.text password:self.passwordTextField.text];
        }

    }
    
}



- (IBAction)createAccountButtonPressed:(id)sender {
    
    
    if (self.creatingAccount == NO) {
        [UIView animateWithDuration:0.4 animations:^{
            [self.signInTopConstraint setConstant:self.signInTopConstraint.constant + 75];
            [self.createAccountButton setTitle:@"Cancel" forState:UIControlStateNormal];
            [self.signInButton setTitle:@"Ready" forState:UIControlStateNormal];
            self.rePasswordTextField.alpha = 1;
            self.emailTextField.alpha = 1;
            self.creatingAccount = true;
        }];
    
    } else if (self.creatingAccount == true) {
        [UIView animateWithDuration:0.2 animations:^{
        [self.signInTopConstraint setConstant:self.signInTopConstraint.constant - 75];
        [self.createAccountButton setTitle:@"Create Account" forState:UIControlStateNormal];
        [self.signInButton setTitle:@"Sign In" forState:UIControlStateNormal];
        self.rePasswordTextField.alpha = 0;
        self.emailTextField.alpha = 0;
        self.creatingAccount = false;
        }];
    }
    
    
    
    
}




#pragma mark - Annotations and Gestures

-(void) addGesutureRecognizer {
    
    self.gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addAnnotation:)];
    self.gesture.delegate = self;
    [self.mapView addGestureRecognizer:self.gesture];
    
    
}

-(void) addAnnotation:(UIGestureRecognizer*)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"began");
        
        CGPoint touchPoint = [gesture locationInView:self.mapView];
        CLLocationCoordinate2D touchCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];

        annotation.title = @"Yo";
        annotation.subtitle = @"waddup";
        annotation.coordinate = touchCoordinate;
        [self.mapView addAnnotation:annotation];
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        NSLog(@"ended");
        
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - MKMapView Methods


-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"did enter region");
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"region entered!";
    localNotification.alertAction = @"region entered!";
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    // add an alert to notify users that location services are unavailable
    NSLog(@"Location service failed.");
}

-(void)addReminder:(NSNotification*)notification {
    NSDictionary* reminderRegion = notification.userInfo;
    CLCircularRegion *region = reminderRegion[@"region"];
    MKCircle *regionOverlay = [MKCircle circleWithCenterCoordinate:region.center radius:region.radius];
    [self.mapView addOverlay:regionOverlay];
    
    
}


-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
    circleRenderer.fillColor = [UIColor blueColor];
    circleRenderer.alpha = 0.5;
    return circleRenderer;
}


- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    [self.mapView setCenterCoordinate:userLocation.coordinate animated:YES];
    
}


-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
    
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"identifier"];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"identifier"];
            annotationView.canShowCallout = true;
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            annotationView.rightCalloutAccessoryView = rightButton;
            return annotationView;
            
        }
 
        
    }
    
    return nil;
    
    
}


-(void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    
    [self performSegueWithIdentifier:@"DetailViewController" sender:view];
    
    
}

















@end















//
//- (IBAction)showUserLocation:(UIButton *)sender {
//
//    [self.mapView setRegion:[self regionForButtonTitle:sender.titleLabel.text] animated:YES];
//
//}




//- (MKCoordinateRegion)regionForButtonTitle:(NSString *)title {
//
//    [self.locationManager stopUpdatingLocation];
//
//    MKCoordinateRegion myRegion;
//    CLLocationCoordinate2D coordinate;
//
//    if ([title isEqualToString:@"Mountain View"]) {
//        coordinate = CLLocationCoordinate2DMake(37.386052, -122.083851);
//        myRegion = MKCoordinateRegionMakeWithDistance(coordinate, 500.0, 500.0);
//    }
//
//    if ([title isEqualToString:@"Shenzhen"]) {
//        coordinate = CLLocationCoordinate2DMake(22.543099, 114.057868);
//        myRegion = MKCoordinateRegionMakeWithDistance(coordinate, 500.0, 500.0);
//    }
//
//    if ([title isEqualToString:@"Maywood Ca"]) {
//        coordinate = CLLocationCoordinate2DMake(33.986681, -118.185349);
//        myRegion = MKCoordinateRegionMakeWithDistance(coordinate, 500.0, 500.0);
//    }
//
//    return myRegion;
//
//}

