//
//  UserProfileViewController.m
//  Lifelike
//
//  Created by LoveStar_PC on 2/5/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//

#import "UserProfileViewController.h"

#import "ProfileHeaderCollectionReusableView.h"
#import "SlideNavigationController.h"
#import "FriendModel.h"
#import "PhotoModel.h"
#import "AppDelegate.h"
#import "Global.h"
#import "GlobalProc.h"

#import "ChooseAPhotoViewController.h"

#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
@interface UserProfileViewController ()
{
    NSMutableArray * userPhotos;
    NSString * accessTokenForFriend;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewPhotos;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadPhotos];
}
- (void) viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGotPhoto) name:NOTI_GOT_FACE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCompletedLoadPhoto) name:NOTI_COMPLETE_FACE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAcceptedPhotosPN:) name:@"AcceptedPhotosPN" object:nil];
    
    if (![Global sharedInstance].isTriedLoading) {
        [[Global sharedInstance] loadAllPhotosWithFacebookID:[PFUser currentUser][@"facebookId"]];
        if ([PFUser currentUser][@"userIdInstagram"]) {
            if ([[PFUser currentUser][@"userIdInstagram"] length]) {
                [[Global sharedInstance] loadAllPhotosForFacebookId:[PFUser currentUser][@"facebookId"] WithInstagramID:[PFUser currentUser][@"userIdInstagram"] withToken:[PFUser currentUser][@"accessTokenInstagram"]];
            }
        }
    }
    if (self.selectedFriend) {
        [[Global sharedInstance] loadAllPhotosWithFacebookID:self.selectedFriend.idFB];
        PFQuery * query = [PFUser query];
        [query whereKey:@"facebookId" equalTo:self.selectedFriend.idFB];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (!error && object) {
                if (object[@"userIdInstagram"]) {
                    if ([object[@"userIdInstagram"] length]) {
                        [[Global sharedInstance] loadAllPhotosForFacebookId:object[@"facebookId"] WithInstagramID:object[@"userIdInstagram"] withToken:object[@"accessTokenInstagram"]];
                    }
                }
            }
        }];
    }
    
}
- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AcceptedPhotosPN" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTI_GOT_FACE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTI_COMPLETE_FACE object:nil];
}
- (void) reloadPhotos {
    userPhotos = [NSMutableArray array];
    NSArray * tmpArray = [NSArray arrayWithArray:[Global sharedInstance].dictionaryFacePhotos.allValues];
    if (tmpArray.count > 1) {
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created"
                                                     ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        tmpArray = [NSMutableArray arrayWithArray:[tmpArray sortedArrayUsingDescriptors:sortDescriptors]];
        
    }
    NSString * strId = [PFUser currentUser][@"facebookId"];
    if (self.selectedFriend) {
        strId = self.selectedFriend.idFB;
    }
    for (NSDictionary * model in tmpArray) {
//        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
//        formatter.dateFormat = @"yyyy-MM-dd";
        if ([model[@"facebookId"] isEqualToString:strId]) {
            if (model[@"imgFace"])
            {
                [userPhotos addObject:model];
            } else if ([model[@"cntTried"] integerValue] < 3) {
                [userPhotos addObject:model];
            }
        }
    }
    
    [self.collectionViewPhotos reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onMenu:(id)sender {
    [[SlideNavigationController sharedInstance] leftMenuSelected:nil];
}
- (void) onFriendImages {
    if (!self.selectedFriend) {
        UIViewController * viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyFriendsViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
//        NSMutableArray * arrayPendingRequestsToUsePhotos = [NSMutableArray arrayWithArray:[PFUser currentUser][@"PendingRequestsToUsePhotos"]];
//        if ([arrayPendingRequestsToUsePhotos indexOfObject:self.selectedFriend.idFB] == NSNotFound) {
//            NSMutableArray * arrayAcceptedRequestsToUsePhotos = [NSMutableArray arrayWithArray:[PFUser currentUser][@"AcceptedRequestsToUsePhotos"]];
//            if ([arrayAcceptedRequestsToUsePhotos indexOfObject:self.selectedFriend.idFB] != NSNotFound) {
                for (UIViewController * theViewController in self.navigationController.viewControllers) {
                    if ([theViewController isKindOfClass:[ChooseAPhotoViewController class]]) {
                        ChooseAPhotoViewController * viewController = (ChooseAPhotoViewController *) theViewController;
                        viewController.arraySelectedFriends = @[self.selectedFriend];
                        [self.navigationController popToViewController:viewController animated:YES];
                        return;
                    }
                }
                ChooseAPhotoViewController * viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChooseAPhotoViewController"];
                viewController.arraySelectedFriends = @[self.selectedFriend];
                [self.navigationController pushViewController:viewController animated:YES];
                return;
//            }
//        } else {
//            [[[UIAlertView alloc] initWithTitle:@"" message:@"The friend doesn't accepted your request yet." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
//            return;
//        }
        [[AppDelegate sharedAppDelegate] showWaitingScreen:@"Requesting ..." bShowText:YES withSize:CGSizeMake(150 * MULTIPLY_VALUE, 100 * MULTIPLY_VALUE)];
        [GlobalProc sendRequestToUsePhotosWithFacebookID:self.selectedFriend.idFB withCompletion:^(BOOL isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[AppDelegate sharedAppDelegate] hideWaitingScreen];
                if (isSuccess) {
                    [[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Successfully sent your request to %@.", self.selectedFriend.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                    [self.collectionViewPhotos reloadData];

                }
            });

        }];

    }

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Photo Notification
- (void) onGotPhoto {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadPhotos];
    });
    
}
- (void) onCompletedLoadPhoto {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadPhotos];
    });
    
}
- (void) onAcceptedPhotosPN:(NSNotification *) notification {
    NSDictionary * dic = notification.userInfo;
    NSMutableArray * arrayAcceptedRequestsToUsePhotos = [NSMutableArray arrayWithArray:[PFUser currentUser][@"AcceptedRequestsToUsePhotos"]];
    if (!arrayAcceptedRequestsToUsePhotos) {
        arrayAcceptedRequestsToUsePhotos = [NSMutableArray array];
    }
    if ([arrayAcceptedRequestsToUsePhotos indexOfObject:dic[@"sentUser"]] == NSNotFound) {
        [arrayAcceptedRequestsToUsePhotos addObject:dic[@"sentUser"]];
        NSMutableArray * arrayPendingRequestsToUsePhotos = [NSMutableArray arrayWithArray:[PFUser currentUser][@"PendingRequestsToUsePhotos"]];
        [arrayPendingRequestsToUsePhotos removeObject:dic[@"sentUser"]];
        [PFUser currentUser][@"PendingRequestsToUsePhotos"] = arrayPendingRequestsToUsePhotos;
    }
    [PFUser currentUser][@"AcceptedRequestsToUsePhotos"] = arrayAcceptedRequestsToUsePhotos;
    [[PFUser currentUser] saveInBackground];
    [self.collectionViewPhotos reloadData];
}
#pragma mark - UICollectionView Datasource
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView * resView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        ProfileHeaderCollectionReusableView * view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header_profile" forIndexPath:indexPath];
        view.imageProfile.layer.masksToBounds = YES;
        view.imageProfile.layer.cornerRadius = view.imageProfile.frame.size.width / 2;
        view.imageProfile.layer.borderColor = [UIColor whiteColor].CGColor;
        view.imageProfile.layer.borderWidth = 3;
        NSString * name = [PFUser currentUser][@"name"];
        if (self.selectedFriend) {
            name = self.selectedFriend.name;
        }
        NSArray * array = [name componentsSeparatedByString:@" "];
        if (array.count > 1) {
            name = [NSString stringWithFormat:@"%@ %@.", [array[0] uppercaseString], [[array[1] uppercaseString] substringToIndex:1]];
        } else {
            name = [array[0] uppercaseString];
        }
        view.lblName.text = name;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString * strPhoto = [PFUser currentUser][@"profileImageURL"];
            if (self.selectedFriend) {
                strPhoto = self.selectedFriend.strPhotoURL;
            }

            NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:strPhoto]];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage * image = [UIImage imageWithData:data];
                if (image) {
                    view.imageProfile.image = image;
                }
            });
        });
        if (!self.selectedFriend) {
            [view.btnFriendImages setTitle:@"FRIEND IMAGES" forState:UIControlStateNormal];
            view.btnFriendImages.backgroundColor = [UIColor colorWithRed:0 green:60.0 / 255.0 blue:141.0 / 255.0 alpha:1.0];
        } else {
            [view.btnFriendImages setTitle:@"REQUEST IMAGES" forState:UIControlStateNormal];
            view.btnFriendImages.backgroundColor = [UIColor colorWithRed:214.0 / 255.0 green:82.0 / 255.0 blue:0 alpha:1.0];
//            NSMutableArray * arrayPendingRequestsToUsePhotos = [NSMutableArray arrayWithArray:[PFUser currentUser][@"PendingRequestsToUsePhotos"]];
//            if ([arrayPendingRequestsToUsePhotos indexOfObject:self.selectedFriend.idFB] == NSNotFound) {
//                NSMutableArray * arrayAcceptedRequestsToUsePhotos = [NSMutableArray arrayWithArray:[PFUser currentUser][@"AcceptedRequestsToUsePhotos"]];
//                if ([arrayAcceptedRequestsToUsePhotos indexOfObject:self.selectedFriend.idFB] != NSNotFound) {
                    [view.btnFriendImages setTitle:@"USE IMAGES" forState:UIControlStateNormal];
//                }
//            } else {
//                [view.btnFriendImages setTitle:@"PENDING REQUEST" forState:UIControlStateNormal];
//
//            }
        }
        view.btnFriendImages.layer.masksToBounds = YES;
        view.btnFriendImages.layer.cornerRadius = view.btnFriendImages.frame.size.height / 2;
        [view.btnFriendImages addTarget:self action:@selector(onFriendImages) forControlEvents:UIControlEventTouchUpInside];
        resView = view;
    }
    return resView;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return userPhotos.count;
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell_photo" forIndexPath:indexPath];
    
    UIImageView * imgPhoto = (UIImageView *) [cell viewWithTag:1];
    UIView * viewLoading = [cell viewWithTag:4];
    imgPhoto.hidden = NO;
    viewLoading.hidden = YES;
    
    NSDictionary * model = userPhotos[indexPath.row];
    if (!model[@"imgFace"]) {
        viewLoading.hidden = NO;
        imgPhoto.hidden = YES;
    } else {
        imgPhoto.image = [UIImage imageWithData:model[@"imgFace"]];
    }
    UIImageView * imgInstagramIcon = (UIImageView *) [cell viewWithTag:10];
    if ([model[@"isInstagram"] boolValue]) {
        imgInstagramIcon.hidden = NO;
    } else {
        imgInstagramIcon.hidden = YES;
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSDictionary * model = userPhotos[indexPath.row];
    if (!model[@"imgFace"]) {
        return;
    }
    
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSMutableArray * arrayAcceptedRequestsToUsePhotos = [NSMutableArray arrayWithArray:[PFUser currentUser][@"AcceptedRequestsToUsePhotos"]];
    if ([arrayAcceptedRequestsToUsePhotos indexOfObject:self.selectedFriend.idFB] != NSNotFound) {
//        [view.btnFriendImages setTitle:@"USE IMAGES" forState:UIControlStateNormal];
    }
}
#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(collectionView.frame.size.width / 2 - 15, collectionView.frame.size.width / 2 - 15);
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

@end
