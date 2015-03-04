//
//  TableViewController.m
//  Amicus1.0
//
//  Created by Saiteja Samudrala on 2/28/15.
//  Copyright (c) 2015 edu.saiteja. All rights reserved.
//

#import "TableViewController.h"
#import "TableViewCell.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "Moxtra.h"


@interface TableViewController ()

@end

@implementation TableViewController

- (void)unlinkMoxtraAccount:(id)sender
{
    [[Moxtra sharedClient] unlinkAccount:^(BOOL success) {
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSString * idnumber1 = [defs objectForKey:@"id"];
    NSString * idnumber = [NSString stringWithFormat:@"%@21",idnumber1];
    MXUserIdentity *useridentity1 = [[MXUserIdentity alloc] init];
    useridentity1.userIdentityType = kUserIdentityTypeIdentityUniqueID;
    useridentity1.userIdentity = idnumber;
    
    
    NSString * name = [NSString stringWithFormat:@""];
    NSString * lname = [NSString stringWithFormat:@""];
    NSScanner * scan = [NSScanner scannerWithString:[defs objectForKey:@"naam"]];
    [scan scanUpToString:@" " intoString:&name];
    [scan scanString:@" " intoString:nil];
    [scan scanUpToString:@"" intoString:&lname];
    NSLog(@"%@ sdadasda %@",name,lname);
    
    [[Moxtra sharedClient] initializeUserAccount:useridentity1 orgID:nil firstName: name lastName: lname avatar:nil devicePushNotificationToken:nil success:^{
        
 
        NSLog(@"Setup user account success");
    } failure:^(NSError *error) {
        
        if (error.code == MXClientErrorUserAccountAlreadyExist)
            // Get chat list
        
        NSLog(@"Setup user account failed, %@", [NSString stringWithFormat:@"error code [%ld] description: [%@] info [%@]", (long)[error code], [error localizedDescription], [[error userInfo] description]]);
    }];
    
    // Set Moxtra chat delegate
    [Moxtra sharedClient].delegate = self;
    _tableView.dataSource = self;
    _tableView.delegate =self;
    [self.tableView reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * names = [defaults objectForKey:@"names"];
    NSLog(@"%@",[names objectAtIndex:0]);
    return [names count] ;
}

- (void)fetchChatList
{
    NSArray *chatListArray = [[Moxtra sharedClient] getChatSessionArray];
    self.chatlist = [NSMutableArray arrayWithArray:chatListArray];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cells");
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * names = [defaults objectForKey:@"names"];
    NSMutableArray * distances = [defaults objectForKey:@"distances"];
    NSMutableArray * propics = [defaults objectForKey:@"images"];
    NSMutableArray *ids = [defaults objectForKey:@"ids"];
    

    NSString * proURL = [propics objectAtIndex:indexPath.row];
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: proURL]];
    
    
    
    static NSString *CellIdentifier = @"TableViewCell";
    TableViewCell *cell = (TableViewCell *)[self.tableView
                                            dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (cell == nil)
    {
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:CellIdentifier];
    }
    

    
    NSString * userName = [names objectAtIndex:indexPath.row];
    NSString * distance = [distances objectAtIndex:indexPath.row];
    
    NSLog(@"%@",userName);
    NSLog(@"%@",distance);
    
    
    // Display recipe in the table cell
    cell.nameLabel.text = userName;
    cell.distanceLabel.text = distance;
    cell.proPic.image= [UIImage imageWithData: imageData];
    cell.fbId = [ids objectAtIndex:indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)popChatViewController:(UIViewController*)chatViewController;
{
    [chatViewController.navigationController setNavigationBarHidden:NO animated:NO];
    
    if (chatViewController)
    {
   
        [chatViewController dismissViewControllerAnimated:YES completion:nil];
        
        //case 3: remove the chat view controller from 3rd party's view controller
        //[chatViewController.view removeFromSuperview];
        //[chatViewController removeFromParentViewController];
    }
    
    MXChatMemberInfo *userInfo = [[Moxtra sharedClient] getUserInfo];
    NSLog(@"user info: %@, %@, %@", userInfo.firstName, userInfo.lastName, userInfo.avatarPath);
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
{
 
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSString * idnumber = [defs objectForKey:@"id"];
    MXUserIdentity *useridentity = [[MXUserIdentity alloc] init];
    useridentity.userIdentityType = kUserIdentityTypeIdentityUniqueID;
    useridentity.userIdentity = idnumber;
    
   TableViewCell * source = (TableViewCell *)[(UITableView *)self.tableView cellForRowAtIndexPath:indexPath];
 NSString * idnumber2 = [NSString stringWithFormat:@"%@21",source.fbId];
    NSArray * array1 = [NSArray arrayWithObject:idnumber2];
    [[Moxtra sharedClient] createChat:source.nameLabel.text inviteMembersUniqueID:array1 success:^(NSString *binderID, UIViewController *chatViewController) {
        
         //for test
        [self presentViewController:chatViewController animated:YES completion:nil];
    }
                              failure:^(NSError *error) { NSLog (@"%@",error.localizedDescription);
        
    }];

}}


@end
