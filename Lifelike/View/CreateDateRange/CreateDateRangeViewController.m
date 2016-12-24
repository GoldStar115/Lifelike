//
//  CreateDateRangeViewController.m
//  Lifelike
//
//  Created by LoveStar_PC on 2/5/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

#import "CreateDateRangeViewController.h"
#import "AppDelegate.h"
@interface CreateDateRangeViewController ()

@end

@implementation CreateDateRangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    if (![PFUser currentUser][@"facebookAccessToken"]) {
//        
//        [PFUser currentUser][@"facebookAccessToken"] = [FBSDKAccessToken currentAccessToken].tokenString;
//        [[PFUser currentUser] save];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onLastMonth:(id)sender {
}
- (IBAction)onLastYear:(id)sender {
}
- (IBAction)onAllTime:(id)sender {
}
- (IBAction)onMenu:(id)sender {
    [[SlideNavigationController sharedInstance] leftMenuSelected:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"id_last_month"]) {
        [AppDelegate sharedAppDelegate].selectedDateRange = 0;
    }
    else if ([segue.identifier isEqualToString:@"id_last_year"]) {
        [AppDelegate sharedAppDelegate].selectedDateRange = 1;
    }
    else if ([segue.identifier isEqualToString:@"id_all_time"]) {
        [AppDelegate sharedAppDelegate].selectedDateRange = 2;
    }
}


@end
