//
//  TableViewCell.h
//  Amicus1.0
//
//  Created by Saiteja Samudrala on 2/28/15.
//  Copyright (c) 2015 edu.saiteja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UIImageView * proPic;
@property (nonatomic, weak) NSString * fbId;
@end
