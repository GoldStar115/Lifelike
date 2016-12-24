//
//  NotificationsViewController.m
//  Lifelike
//
//  Created by LoveStar_PC on 2/5/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//
#import <Parse/Parse.h>

#import "NotificationsViewController.h"
#import "InviteTableViewCell.h"
#import "SlideNavigationController.h"
#import "AppDelegate.h"
#import "GlobalProc.h"

@interface NotificationsViewController ()
{
    PFObject * objectSelected;
}
@property (weak, nonatomic) IBOutlet UITableView *tblView;

@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoadedPN) name:@"LoadedPN" object:nil];

}
- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadedPN" object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onMenu:(id)sender {
    [[SlideNavigationController sharedInstance] leftMenuSelected:nil];
}
- (void) onLoadedPN {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tblView reloadData];
    });
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UITableView Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![AppDelegate sharedAppDelegate].arrayPushnotifications) {
        return 0;
    }
    return [AppDelegate sharedAppDelegate].arrayPushnotifications.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80 * 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"cell_notification";
    InviteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFObject * object = [AppDelegate sharedAppDelegate].arrayPushnotifications[indexPath.row];
    
    cell.imgProfile.layer.masksToBounds = YES;
    cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.size.height / 2;
    cell.imgProfile.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.imgProfile.layer.borderWidth = 2;
    
    cell.lblName.text = object[@"message"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:object[@"profileImageURL"]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage * image = [UIImage imageWithData:data];
            if (image) {
                InviteTableViewCell * tmpCell = [tableView cellForRowAtIndexPath:indexPath];
                if (tmpCell) {
                    [tmpCell.imgProfile setImage:image];
                }
            }
        });
    });

    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    objectSelected = [AppDelegate sharedAppDelegate].arrayPushnotifications[indexPath.row];
    if ([objectSelected[@"typePN"] isEqualToString:@"requestPhoto"]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"LifeLike" message:objectSelected[@"message"] delegate:self cancelButtonTitle:@"Not now" otherButtonTitles:@"Yes", nil];
        alertView.tag = 1;
        [alertView show];

    }
    if ([objectSelected[@"typePN"] isEqualToString:@"hasAcceptedRequestToUsePhotos"]) {
        [objectSelected deleteInBackground];
        [[AppDelegate sharedAppDelegate].arrayPushnotifications removeObject:objectSelected];
        [self.tblView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadPN" object:nil userInfo:nil];

    }
}
#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 1:
            if (buttonIndex) {
                [[AppDelegate sharedAppDelegate] showWaitingScreen:@"Accepting ..." bShowText:YES withSize:CGSizeMake(150 * MULTIPLY_VALUE, 100 * MULTIPLY_VALUE)];
                
                [GlobalProc acceptRequestToUsePhotosWithFacebookID:objectSelected[@"sentUser"] withCompletion:^(BOOL isSuccess) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[AppDelegate sharedAppDelegate] hideWaitingScreen];
                        [objectSelected deleteInBackground];
                        [[AppDelegate sharedAppDelegate].arrayPushnotifications removeObject:objectSelected];
                        [self.tblView reloadData];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadPN" object:nil userInfo:nil];
                    });
                    
                }];
            }
            break;
            
        case 2:
            
            break;
            
        case 3:
            
            break;
            
        default:
            break;
    }
}

@end
