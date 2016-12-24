//
//  MenuViewController.h
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

@interface LeftMenuViewController : UIViewController 
@property (weak, nonatomic) IBOutlet UILabel *lblCntPN;
@property (weak, nonatomic) IBOutlet UIButton *btnConnectInstagram;

//@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL slideOutAnimationEnabled;

@end
