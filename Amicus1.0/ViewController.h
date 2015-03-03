//
//  ViewController.h
//  Amicus1.0
//
//  Created by Saiteja Samudrala on 2/27/15.
//  Copyright (c) 2015 edu.saiteja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSURLConnectionDelegate>

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)loginPressed:(id)sender;
- (IBAction)getData:(id)sender;
-(IBAction)logOut:(id)sender;
-(void)save:(NSMutableArray*)array;
-(IBAction)press:(id)sender;

@end

