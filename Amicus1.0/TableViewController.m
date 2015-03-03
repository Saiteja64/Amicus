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

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}
@end
