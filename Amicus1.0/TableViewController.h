//
//  TableViewController.h
//  Amicus1.0
//
//  Created by Saiteja Samudrala on 2/28/15.
//  Copyright (c) 2015 edu.saiteja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
