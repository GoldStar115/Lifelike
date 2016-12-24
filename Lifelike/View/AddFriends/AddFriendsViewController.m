//
//  AddFriendsViewController.m
//  Lifelike
//
//  Created by LoveStar_PC on 2/5/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//

#import "AddFriendsViewController.h"

#import "InviteTableViewCell.h"
#import "ChooseAPhotoViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

#import "FriendModel.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>


#import "GlobalProc.h"

@interface AddFriendsViewController ()
{
    NSMutableArray * arraySelected;
    NSMutableArray * arrayConnectedInstagram;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tblView;

@end

@implementation AddFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    arraySelected = [NSMutableArray array];
    
    // Do any additional setup after loading the view.
    if (![AppDelegate sharedAppDelegate].arrayMyFriends.count) {
        [self loadFacebookFriends];
    } else {
        if (self.isInstagram) {
            [self getInstagramUsers];
        }
    }
}
- (void) viewWillAppear:(BOOL)animated {
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) getInstagramUsers {
    NSMutableArray * idFacebook = [NSMutableArray array];
    arrayConnectedInstagram = [NSMutableArray array];
    for (FriendModel * model in [AppDelegate sharedAppDelegate].arrayMyFriends) {
        [idFacebook addObject:model.idFB];
    }
    if (idFacebook.count) {
        PFQuery * query = [PFUser query];
        [query whereKey:@"facebookId" containedIn:idFacebook];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (!error && objects) {
                for (PFUser * user in objects) {
                    if (user[@"userIdInstagram"]) {
                        if ([user[@"userIdInstagram"] length]) {
                            for (FriendModel * model in [AppDelegate sharedAppDelegate].arrayMyFriends) {
                                if ([model.idFB isEqualToString:user[@"facebookId"]]) {
                                    [arrayConnectedInstagram addObject:model];
                                    
                                }
                            }
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tblView reloadData];
            });
        }];
    }
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
            if (self.isInstagram) {
                [self getInstagramUsers];
            } else
                [self.tblView reloadData];
        });
        
    }];
    
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (IBAction)onDone:(id)sender {
    if (!arraySelected.count) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please choose at least one friend to use the photos." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    ChooseAPhotoViewController * viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChooseAPhotoViewController"];
    NSMutableArray * array = [NSMutableArray array];
    for (NSNumber * theNumber in arraySelected) {
        if (self.isInstagram) {
            [array addObject:arrayConnectedInstagram[theNumber.integerValue]];
        } else
            [array addObject:[AppDelegate sharedAppDelegate].arrayMyFriends[theNumber.integerValue]];
    }
    viewController.arraySelectedFriends = array;
    viewController.isFromAddFriend = YES;
//    viewController.isInstagram = self.isInstagram;
    [self.navigationController pushViewController:viewController animated:YES];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) onAdd:(UIButton *) theButton {
    if ([arraySelected indexOfObject:[NSNumber numberWithInteger:theButton.tag]] == NSNotFound) {
        if (arraySelected.count < 3) {
            [arraySelected addObject:[NSNumber numberWithInteger:theButton.tag]];
        }
    } else {
        [arraySelected removeObject:[NSNumber numberWithInteger:theButton.tag]];
    }
    [self.tblView reloadData];

}
#pragma mark - UITableView Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isInstagram) {
        return arrayConnectedInstagram.count;
    }
    return [AppDelegate sharedAppDelegate].arrayMyFriends.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80 * 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"cell_add";
    InviteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    FriendModel * model = [AppDelegate sharedAppDelegate].arrayMyFriends[indexPath.row];
    if (self.isInstagram) {
        model = arrayConnectedInstagram[indexPath.row];
    }
    cell.imgProfile.layer.masksToBounds = YES;
    cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.size.height / 2;
    cell.imgProfile.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.imgProfile.layer.borderWidth = 2;
    
    if ([arraySelected indexOfObject:[NSNumber numberWithInteger:indexPath.row]] == NSNotFound) {
        [cell.btnInvite setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    } else {
        [cell.btnInvite setBackgroundImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
    }
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
    cell.btnInvite.tag = indexPath.row;
//    [cell.btnInvite addTarget:self action:@selector(onAdd:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    FriendModel * model = [AppDelegate sharedAppDelegate].arrayMyFriends[indexPath.row];
//    if (self.isInstagram) {
//        model = arrayConnectedInstagram[indexPath.row];
//    }
//    NSMutableArray * arrayPendingRequestsToUsePhotos = [NSMutableArray arrayWithArray:[PFUser currentUser][@"PendingRequestsToUsePhotos"]];
//    if ([arrayPendingRequestsToUsePhotos indexOfObject:model.idFB] == NSNotFound) {
//        NSMutableArray * arrayAcceptedRequestsToUsePhotos = [NSMutableArray arrayWithArray:[PFUser currentUser][@"AcceptedRequestsToUsePhotos"]];
//        if ([arrayAcceptedRequestsToUsePhotos indexOfObject:model.idFB] != NSNotFound) {
            if ([arraySelected indexOfObject:[NSNumber numberWithInteger:indexPath.row]] == NSNotFound) {
                if (arraySelected.count < 3) {
                    [arraySelected addObject:[NSNumber numberWithInteger:indexPath.row]];
                }
            } else {
                [arraySelected removeObject:[NSNumber numberWithInteger:indexPath.row]];
            }
            [self.tblView reloadData];
//        } else {
//            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You should be sent the request to use the friend's photos." delegate:self cancelButtonTitle:@"Not now" otherButtonTitles:@"Yes", nil];
//            alert.tag = indexPath.row;
//            [alert show];
//
//        }
//    } else {
//        [[[UIAlertView alloc] initWithTitle:@"" message:@"The friend doesn't accepted your request yet." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
//    }
    
}
#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex) {
        FriendModel * model = [AppDelegate sharedAppDelegate].arrayMyFriends[alertView.tag];
        if (self.isInstagram) {
            model = arrayConnectedInstagram[alertView.tag];
        }
        [[AppDelegate sharedAppDelegate] showWaitingScreen:@"Requesting ..." bShowText:YES withSize:CGSizeMake(150 * MULTIPLY_VALUE, 100 * MULTIPLY_VALUE)];
        [GlobalProc sendRequestToUsePhotosWithFacebookID:model.idFB withCompletion:^(BOOL isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[AppDelegate sharedAppDelegate] hideWaitingScreen];
                if (isSuccess) {
                    [[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Successfully sent your request to %@.", model.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                    
                }
            });
            
        }];

    }
}
@end
