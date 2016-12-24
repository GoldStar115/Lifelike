//
//  MyFriendsViewController.m
//  Lifelike
//
//  Created by LoveStar_PC on 2/5/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//

#import "MyFriendsViewController.h"
#import "InviteTableViewCell.h"
#import "SlideNavigationController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "FriendModel.h"
#import "AppDelegate.h"

#import "GlobalProc.h"
#import "Global.h"

#import "UserProfileViewController.h"

@interface MyFriendsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblView;

@end

@implementation MyFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated {
    if (![AppDelegate sharedAppDelegate].arrayMyFriends.count) {
        [self loadFacebookFriends];
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) loadFacebookFriends {
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/me/friends"
                                  parameters:@{@"fields": @"id,picture,name"}
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        // Handle the result
        NSDictionary * dic = [NSDictionary dictionaryWithDictionary:result];
        if (dic[@"data"]) {
            if ([dic[@"data"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary * theDic in dic[@"data"]) {
                    FriendModel * model = [[FriendModel alloc] init];
                    model.name = theDic[@"name"];
                    model.idFB = theDic[@"id"];
                    model.strPhotoURL = theDic[@"picture"][@"data"][@"url"];
                    [[AppDelegate sharedAppDelegate].arrayMyFriends addObject:model];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tblView reloadData];
        });
        
    }];
    
}
- (IBAction)onMenu:(id)sender {
    [[SlideNavigationController sharedInstance] leftMenuSelected:nil];
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
    return [AppDelegate sharedAppDelegate].arrayMyFriends.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80 * 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"cell_friend";
    InviteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    FriendModel * model = [AppDelegate sharedAppDelegate].arrayMyFriends[indexPath.row];

    cell.imgProfile.layer.masksToBounds = YES;
    cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.size.height / 2;
    cell.imgProfile.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.imgProfile.layer.borderWidth = 2;
    
    if (model.imgPhoto) {
        cell.imgProfile.image = model.imgPhoto;
    } else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.strPhotoURL]];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage * image = [UIImage imageWithData:data];
                if (image) {
                    InviteTableViewCell * tmpCell = [tableView cellForRowAtIndexPath:indexPath];
                    if (tmpCell) {
                        [tmpCell.imgProfile setImage:image];
                    }
                    model.imgPhoto = image;
                }
            });
        });
        
    }
    
    cell.lblName.text = model.name.uppercaseString;
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FriendModel * model = [AppDelegate sharedAppDelegate].arrayMyFriends[indexPath.row];
    
    UserProfileViewController * viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    viewController.selectedFriend = model;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
