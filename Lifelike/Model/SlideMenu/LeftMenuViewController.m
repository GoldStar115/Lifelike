//
//  MenuViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"

//#import "Define_Global.h"
#import "AppDelegate.h"
#import "UserProfileViewController.h"
#import <Parse/Parse.h>

@implementation LeftMenuViewController

#pragma mark - UIViewController Methods -

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self.slideOutAnimationEnabled = YES;
	
	return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
}
- (void) viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoadedPN) name:@"LoadedPN" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoadedPN) name:@"ReloadPN" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoggedInInstagramPN) name:@"LoggedInInstagramPN" object:nil];
    
    self.lblCntPN.layer.masksToBounds = YES;
    self.lblCntPN.layer.cornerRadius = self.lblCntPN.frame.size.width / 2;
    self.lblCntPN.layer.borderColor = [UIColor whiteColor].CGColor;
    self.lblCntPN.layer.borderWidth = 2;
    self.lblCntPN.hidden = YES;
    if ([AppDelegate sharedAppDelegate].arrayPushnotifications) {
        if ([AppDelegate sharedAppDelegate].arrayPushnotifications.count) {
            self.lblCntPN.text = @([AppDelegate sharedAppDelegate].arrayPushnotifications.count).stringValue;
//            self.lblCntPN.hidden = NO;
        }
    }
    self.btnConnectInstagram.hidden = NO;
    if ([PFUser currentUser]) {
        if ([PFUser currentUser][@"userIdInstagram"]) {
            if ([[PFUser currentUser][@"userIdInstagram"] length]) {
//                self.btnConnectInstagram.hidden = YES;
            }
        }
    }

}
- (void) viewDidAppear:(BOOL)animated {
    if ([PFUser currentUser]) {
        if ([PFUser currentUser][@"userIdInstagram"]) {
            if ([[PFUser currentUser][@"userIdInstagram"] length]) {
                self.btnConnectInstagram.hidden = YES;
            }
        }
    }

}
- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadedPN" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ReloadPN" object:nil];
}
- (void) onLoadedPN {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lblCntPN.text = @([AppDelegate sharedAppDelegate].arrayPushnotifications.count).stringValue;
    });
}
- (void) onLoggedInInstagramPN {
    self.btnConnectInstagram.hidden = YES;

}
- (IBAction)onBack:(id)sender {
    [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
}
- (IBAction)onCreateSpins:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"CreateDateRangeViewController"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                     andCompletion:nil];

}
- (IBAction)onMyProfile:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UserProfileViewController * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"UserProfileViewController"];
    vc.selectedFriend = nil;
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                     andCompletion:nil];
}
- (IBAction)onMyFriends:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"MyFriendsViewController"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                     andCompletion:nil];
}
- (IBAction)onNotifications:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"NotificationsViewController"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                     andCompletion:nil];
}
- (IBAction)onInstagram:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController * vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"LoginWithInstagramViewController"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                     andCompletion:nil];
}

//#pragma mark - UITableView Delegate & Datasrouce -
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//	return 6;
//}
//
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//	return 20;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftMenuCell"];
////    UITableViewCell *  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"leftMenuCell"];
//   
//    UILabel * lblTitle = (UILabel *) [cell viewWithTag:1];
//    
//    
//	switch (indexPath.row)
//	{
//		case 0:
//			lblTitle.text = NSLocalizedString(@"Activities", @"Activities");
//			break;
//			
//		case 1:
//			lblTitle.text = NSLocalizedString(@"Map", @"Map");
//			break;
//			
//		case 2:
//			lblTitle.text = NSLocalizedString(@"Contacts", @"Contacts");
//			break;
//			
//		case 3:
//			lblTitle.text = NSLocalizedString(@"Daily", @"Daily");
//			break;
//			
//		case 4:
//			lblTitle.text = NSLocalizedString(@"Deals", @"Deals");
//			break;
//			
//		case 5:
//			lblTitle.text = NSLocalizedString(@"Sign Out", @"Sign Out");
//			break;
//			
//	}
//	
//	cell.backgroundColor = [UIColor clearColor];
//	
//	return cell;
//} 
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//	
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//	UIViewController *vc ;
//	
//	switch (indexPath.row)
//	{
//		case 0:
//			vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ID_ACTIVITIES_VIEW"];
//			break;
//			
//		case 1:
//			vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ID_MAP_VIEW"];
//			break;
//			
//		case 2:
//			vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ID_CONTACTS_VIEW"];
//			break;
//			
//		case 3:
//			vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ID_DAILY_VIEW"];
//			break;
//			
//		case 4:
//			vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ID_DEALS_VIEW"];
//			break;
//			
//		case 5:
//        {
////            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Are you sure you want to sign out?", @"Are you sure you want to sign out?") delegate:self cancelButtonTitle:NSLocalizedString(@"NO", @"NO") otherButtonTitles:NSLocalizedString(@"YES", @"YES"), nil];
////            [alert show];
//        }
//            
//			return;
//			break;
//	}
//	
//	[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
//															 withSlideOutAnimation:self.slideOutAnimationEnabled
//																	 andCompletion:nil];
//}


@end
