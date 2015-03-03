//
//  ViewController.m
//  Amicus1.0
//
//  Created by Saiteja Samudrala on 2/27/15.
//  Copyright (c) 2015 edu.saiteja. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <CoreLocation/CoreLocation.h>
#import "TableViewController.h"



@interface ViewController ()
{
    CLLocationManager * locationManager;
    NSMutableArray * ids;
    NSMutableArray * fbfriendsnearby;
    CLLocation * location1;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    fbfriendsnearby = [[NSMutableArray alloc]initWithCapacity:50];
    location1 = [[CLLocation alloc]init];
    [super viewDidLoad];
    
    
    
   /*
    PFUser *user = [PFUser user];
    user.username = @"my name";
    user.password = @"my pass";
    user.email = @"email@example.com";
    
    // other fields can be set if you want to save more information
    user[@"phone"] = @"650-555-0000";
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hooray! Let them use the app now.
        } else {
            NSString *errorString = [error userInfo][@"error"];
            // Show the errorString somewhere and let the user try again.
        }
    }];*/
}
- (void)tester {
    
    if ([PFUser currentUser]) {
        
    }
    
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            
            
            
            // Parse the data received
            
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            
            NSLog(@"%@",userData);
            
            
            NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
            
            if (facebookID) {
                userProfile[@"facebookId"] = facebookID;
            }
            
            NSString *name = userData[@"name"];
            if (name) {
                userProfile[@"name"] = name;
                NSLog(name);
            }
            
            NSString *location = userData[@"location"][@"name"];
            if (location) {
                userProfile[@"location"] = location;
            }
            
            NSString * location2 = [NSString stringWithFormat:@"%f,%f",location1.coordinate.latitude,location1.coordinate.longitude];
            userProfile[@"currentLocation"] = location2;
            NSLog(@"%@",userProfile[@"currentLocation"]);
            
            NSString *gender = userData[@"gender"];
            if (gender) {
                userProfile[@"gender"] = gender;
            }
            
            NSString *birthday = userData[@"birthday"];
            if (birthday) {
                userProfile[@"birthday"] = birthday;
            }
            
            NSString *relationshipStatus = userData[@"relationship_status"];
            if (relationshipStatus) {
                userProfile[@"relationship"] = relationshipStatus;
            }
            
            userProfile[@"pictureURL"] = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
            
            NSLog(@"====++++=====");
            
            [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            
            NSLog(@"=+");
            
            [[PFUser currentUser] saveInBackground];
            NSLog(@"==");
            
            
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
    
    NSLog(@"swag");
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"did fail with error %@",[error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation * newLocation = [locations lastObject];
    location1 = newLocation;
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
    }
    
}




- (IBAction)loginPressed:(id)sender {
    NSLog(@"button pressed");
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse
        //[CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways
        ) {
        // Will open an confirm dialog to get user's approval
        [locationManager requestWhenInUseAuthorization];
        //[_locationManager requestAlwaysAuthorization];
    } else {
        [locationManager startUpdatingLocation]; //Will update location immediately
    }

    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
       
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                [self tester];
                [self getData];
                
               
            
            } else {
                NSLog(@"User with facebook logged in!");
                [self tester];
                [self getData];
                
            }
            
        }
    }];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

-(IBAction)logOut:(id)sender{
    [PFUser logOut];
}


- (void)getData{
    
    ids = [[NSMutableArray alloc]init];
    [FBRequestConnection startWithGraphPath:@"/me/friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              NSMutableDictionary * fBInfo = [[NSMutableDictionary alloc]init];
                              fBInfo =  (NSMutableDictionary*)result;
                              NSLog(@"%@",fBInfo[@"data"]);
                              NSMutableArray * FBUsers = fBInfo[@"data"];
                              for(int i = 0; i < [FBUsers count]; i++)
                              {
                                 NSString * userId =  [FBUsers objectAtIndex:i][@"id"];
                                  NSLog(@"sdaa%@",userId);
                                  [ids addObject:userId];
                              }
                              [self press];
                              
                          }];
    
    }

-(void)press
{
    NSMutableArray * array = [[NSMutableArray alloc]initWithCapacity:20];
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        @try {
            
            if (!error) {
                // The find succeeded. The first 100 objects are available in objects
                NSLog(@"eqweq%@", objects);
                NSLog(@"ji%@",[objects objectAtIndex:0]);
                NSMutableDictionary * dic = [[ objects objectAtIndex:0] objectForKey:@"profile"];
                NSLog(@"sauce%@",dic[@"facebookId"]);
                NSLog(@"jia%@",[[ objects objectAtIndex:0] objectForKey:@"profile"]);
                
                int k = 0;
                for (NSMutableDictionary * user in objects)
                {
                    //if([PFUser currentUser][@"id"] == [ids objectAtIndex:k])
                    // continue;
                    
                    NSString * string = user[@"profile"][@"currentLocation"];
                    NSLog(@"fafdadfa%@",string);
                    NSString * lats = [NSString stringWithFormat:@""];
                    NSString * longs = [NSString stringWithFormat:@""];
                    
                    
                    ;
                    NSString * distancetemp = user[@"profile"][@"currentLocation"];
                    NSScanner * scan = [NSScanner scannerWithString:distancetemp];
                    [scan scanUpToString:@"," intoString:&longs];
                    NSLog(@"the rat %@",longs);
                    [scan scanString:@"," intoString:nil];
                    [scan scanUpToString:@"" intoString: &lats];
                    NSLog(@"the rat %@",lats);
                    
                    CLLocation *locB = [[CLLocation alloc] initWithLatitude:[longs floatValue] longitude:[lats floatValue]];
                    
                    CLLocationDistance distance = [location1 distanceFromLocation:locB];
                    NSString * distancer = [NSString stringWithFormat:@"%f",distance];
                    NSLog(@"%f",distance);
                    
                    for(int g = 0; g < [ids count]; g++)
                    {
                        NSLog(@"userId%@",user[@"profile"][@"facebookId"]);
                        if([user[@"profile"][@"facebookId"] isEqualToString:[ids objectAtIndex:g]])
                    if(distance/1000 < 70)
                        [fbfriendsnearby addObject:user ];
                    }
                    NSLog(@"%i",[fbfriendsnearby count]);
                    
                    
                    NSString * stringr = user[@"profile"][@"facebookId"];
                    NSLog(@"strupper%@",stringr);
                    
                    k++;
                    
                }
                [self save:fbfriendsnearby];
                [self performSegueWithIdentifier:@"table" sender:nil];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        @finally {
            
        }
        
        
        
    }];
}


-(void)save:(NSMutableArray*)array
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * names = [[NSMutableArray alloc]initWithCapacity:10];
    NSMutableArray * statuses = [[NSMutableArray alloc]initWithCapacity:10];
    NSMutableArray * distances = [[NSMutableArray alloc]initWithCapacity:10];
    NSMutableArray * images = [[NSMutableArray alloc]initWithCapacity:10];
    
    NSLog(@"%lu",(unsigned long)[array count]);
    
    for(int i = 0; i < [array count]; i++)
    {
        NSString * name = [array objectAtIndex:i][@"profile"][@"name"];
        [names addObject:name];
        NSLog(@"debugpoint1%@",name);
    
        NSString * status = [array objectAtIndex:i][@"profile"][@"relationship"];
         NSLog(@"debugpoint2%@",status);
       
        
        NSString * imageURL = [array objectAtIndex:i][@"profile"][@"pictureURL"];
        NSLog(@"debugpoint3%@",imageURL);
        [images addObject:imageURL];
        
        
        NSString * distancetemp = [array objectAtIndex:i][@"profile"][@"currentLocation"];
        CLLocation * loc = (CLLocation*)[PFUser currentUser][@"currentLocation"];
        NSString * longs = [NSString stringWithFormat:@""];
        NSString * lats = [NSString stringWithFormat:@""];
        NSScanner * scan = [NSScanner scannerWithString:distancetemp];
        [scan scanUpToString:@"," intoString:&longs];
        [scan scanString:@"," intoString:nil];
        [scan scanUpToString: @"" intoString:&lats];
        
        CLLocation *locB = [[CLLocation alloc] initWithLatitude:[longs floatValue] longitude:[lats floatValue]];
        
        CLLocationDistance distance = [location1 distanceFromLocation:locB];
        NSString * distancer = [NSString stringWithFormat:@"%f km",distance/1000];
        NSLog(@"debugpoint4%@",distancer);
            [distances addObject:distancer ];
        
    }
    

    [defaults setObject:names forKey:@"names"];
    [defaults setObject:distances forKey:@"distances"];
    [defaults setObject:images forKey:@"images"];
}

    @end


