//
//  InitialViewController.m
//  Lifelike
//
//  Created by LoveStar_PC on 1/30/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//

#import "InitialViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

#import "InviteViewController.h"

#import "AppDelegate.h"

@interface InitialViewController ()

@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated {
    if ([PFUser currentUser][@"facebookId"]) {
        if ([AppDelegate sharedAppDelegate].isLoggedInAlready) {
            UIViewController * viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateDateRangeViewController"];
            [self.navigationController pushViewController:viewController animated:YES];
        } else {
            InviteViewController * viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteViewController"];
            viewController.isNeedNextButton = YES;
            [self.navigationController pushViewController:viewController animated:YES];
        }
        return;
    }
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"email,name"}];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        NSDictionary *userData = (NSDictionary *)result;
        PFUser *currentUser = [PFUser currentUser];
        
        // Condition incase user denies us access to their email via facebook permissions.
        if (userData[@"email"]) {
            currentUser[@"email"] = userData[@"email"];
        }
        if (userData[@"name"]) {
            currentUser[@"name"] = userData[@"name"];
        }
        currentUser[@"facebookId"] = userData[@"id"];
        currentUser[@"profileImageURL"] = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", userData[@"id"]];
        [currentUser save];
        dispatch_async(dispatch_get_main_queue(), ^{
            InviteViewController * viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteViewController"];
            viewController.isNeedNextButton = YES;
            [self.navigationController pushViewController:viewController animated:YES];
        });
    }];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
