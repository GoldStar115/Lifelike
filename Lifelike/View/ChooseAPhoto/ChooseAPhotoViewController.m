//
//  ChooseAPhotoViewController.m
//  Lifelike
//
//  Created by LoveStar_PC on 2/4/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <Parse/Parse.h>

#import "ChooseAPhotoViewController.h"
#import "UIImage+ImageEffects.h"

#import "UserSectionCollectionReusableView.h"

#import "PhotoModel.h"
#import "AppDelegate.h"
#import "GlobalProc.h"
#import "Global.h"
#import "FriendModel.h"

#import "AnimationViewController.h"

@interface ChooseAPhotoViewController ()
{
    NSMutableArray * arraySelected;
    NSMutableArray * arraySelectedFriendPhotos;
    NSMutableArray * myFacebookPhotos;
    NSMutableDictionary * dicFriendsFacebookPhotos;
    
    UIImage * myImage;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewPhotos;
@property (weak, nonatomic) IBOutlet UILabel *lblCntSelectedPhoto;

@end

@implementation ChooseAPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated {
    arraySelected = [NSMutableArray array];
    arraySelectedFriendPhotos = [NSMutableArray array];
    dicFriendsFacebookPhotos = [NSMutableDictionary dictionary];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGotPhoto) name:NOTI_GOT_FACE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCompletedLoadPhoto) name:NOTI_COMPLETE_FACE object:nil];
    if (![Global sharedInstance].isTriedLoading) {
        [[Global sharedInstance] loadAllPhotosWithFacebookID:[PFUser currentUser][@"facebookId"]];
        if ([PFUser currentUser][@"userIdInstagram"]) {
            if ([[PFUser currentUser][@"userIdInstagram"] length]) {
                [[Global sharedInstance] loadAllPhotosForFacebookId:[PFUser currentUser][@"facebookId"] WithInstagramID:[PFUser currentUser][@"userIdInstagram"] withToken:[PFUser currentUser][@"accessTokenInstagram"]];
            }
        }
    }
    for (FriendModel * theFriend in self.arraySelectedFriends) {
        [[Global sharedInstance] loadAllPhotosWithFacebookID:theFriend.idFB];
        PFQuery * query = [PFUser query];
        [query whereKey:@"facebookId" equalTo:theFriend.idFB];
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
    [self reloadPhotos];
}
- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTI_GOT_FACE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTI_COMPLETE_FACE object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) reloadPhotos {
    myFacebookPhotos = [NSMutableArray array];
    NSMutableArray * tmpArray = [NSMutableArray arrayWithArray:[Global sharedInstance].dictionaryFacePhotos.allValues];
    if (tmpArray.count > 1) {
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created"
                                                     ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        tmpArray = [NSMutableArray arrayWithArray:[tmpArray sortedArrayUsingDescriptors:sortDescriptors]];

    }
    for (NSDictionary * model in tmpArray) {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
        if ([PhotoModel isInDateRange:[AppDelegate sharedAppDelegate].selectedDateRange withDate:[formatter dateFromString:model[@"created"]]] && [model[@"facebookId"] isEqualToString:[PFUser currentUser][@"facebookId"]]) {
            if (model[@"imgFace"])
            {
                [myFacebookPhotos addObject:model];
            } else if ([model[@"cntTried"] integerValue] < 3) {
                [myFacebookPhotos addObject:model];
            }
        }
    }

    for (FriendModel * theFriend in self.arraySelectedFriends) {
        NSMutableArray * friendArray = [NSMutableArray array];
        for (NSDictionary * model in tmpArray) {
            if ([model[@"facebookId"] isEqualToString:theFriend.idFB]) {
                if (model[@"imgFace"])
                {
                    [friendArray addObject:model];
                } else if ([model[@"cntTried"] integerValue] < 3) {
                    [friendArray addObject:model];
                }
            }
        }
        if (friendArray.count) {
            dicFriendsFacebookPhotos[theFriend.idFB] = friendArray;
        }
    }
    [self.collectionViewPhotos reloadData];
}
- (IBAction)onDone:(id)sender {
    
    if (self.isFromAddFriend) {
        if (!arraySelectedFriendPhotos.count) {
            [[[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Please choose images." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return;
        }
        for (UIViewController * theViewController in self.navigationController.viewControllers) {
            if ([theViewController isKindOfClass:[AnimationViewController class]]) {
                AnimationViewController * viewController = (AnimationViewController *) theViewController;
                NSMutableArray * tmpArrayFriend = [NSMutableArray array];
                for (NSIndexPath * index in arraySelectedFriendPhotos) {
                    NSDictionary * model = [self getPhotosFromIndex:index.section - 0][index.row];
                    if (model[@"imgFace"]) {
                        [tmpArrayFriend addObject:[UIImage imageWithData:model[@"imgFace"]]];
                    }
                }
                viewController.arraySelectedFriendPhotos = tmpArrayFriend;
                viewController.needReload = YES;
                [self.navigationController popToViewController:viewController animated:YES];
                break;
            }
        }
    } else {
        if (!arraySelected.count) {
            [[[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Please choose images." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return;
        }
        AnimationViewController * viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AnimationViewController"];
        NSMutableArray * tmpArray = [NSMutableArray array];
        for (NSNumber * index in arraySelected) {
            NSDictionary * model = myFacebookPhotos[index.integerValue];
            if (model[@"imgFace"]) {
                [tmpArray addObject:[UIImage imageWithData:model[@"imgFace"]]];
            }
        }
        viewController.arraySelectedPhotos = tmpArray;
        
        if (self.arraySelectedFriends.count) {
            NSMutableArray * tmpArrayFriend = [NSMutableArray array];
            for (NSIndexPath * index in arraySelectedFriendPhotos) {
                NSDictionary * model = [self getPhotosFromIndex:index.section - 1][index.row];
                if (model[@"imgFace"]) {
                    [tmpArrayFriend addObject:[UIImage imageWithData:model[@"imgFace"]]];
                }
            }
            viewController.arraySelectedFriendPhotos = tmpArrayFriend;
            
        }
        [self.navigationController pushViewController:viewController animated:YES];

    }
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSArray *) getPhotosFromIndex:(NSInteger) index {
    NSArray * tmpArray = [dicFriendsFacebookPhotos.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return dicFriendsFacebookPhotos[tmpArray[index]];
}
#pragma mark - Photo Notification
- (void) onGotPhoto {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AppDelegate sharedAppDelegate] hideWaitingScreen];
        [self reloadPhotos];
    });
    
}
- (void) onCompletedLoadPhoto {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AppDelegate sharedAppDelegate] hideWaitingScreen];
        [self reloadPhotos];
    });
    
}
#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    if ([Global loadingPhotosFromService]) {
//        return myFacebookPhotos.count + 1;
//    }
    if (self.isFromAddFriend) {
        return [[self getPhotosFromIndex:section] count];
    }
    if (section) {
        return [[self getPhotosFromIndex:section - 1] count];
    }
    return myFacebookPhotos.count;
}
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    NSInteger delta = 0;
    if (!self.isFromAddFriend) {
        delta = 1;
    }
    return delta + dicFriendsFacebookPhotos.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * model;
    if (self.isFromAddFriend) {
        model = [self getPhotosFromIndex:indexPath.section][indexPath.row];
    } else {
        if (indexPath.section) {
            model = [self getPhotosFromIndex:indexPath.section - 1][indexPath.row];
        } else {
            model = myFacebookPhotos[indexPath.row];
        }
    }
    if (model[@"imgFace"]) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell_photo" forIndexPath:indexPath];
        UIImageView * imgPhoto = (UIImageView *) [cell viewWithTag:1];
        UIImageView * imgBlur = (UIImageView *) [cell viewWithTag:2];
        UIImageView * imgSelectedIcon = (UIImageView *) [cell viewWithTag:3];
        imgSelectedIcon.hidden = NO;
        imgPhoto.image = [UIImage imageWithData:model[@"imgFace"]];
        imgBlur.image = [imgPhoto.image applyLightEffect];
        
        if (indexPath.section || self.isFromAddFriend) {
            if ([arraySelectedFriendPhotos indexOfObject:indexPath] == NSNotFound) {
                imgBlur.hidden = YES;
                imgSelectedIcon.hidden = YES;
            } else {
                imgBlur.hidden = NO;
                imgSelectedIcon.hidden = NO;
            }
        } else {
            if ([arraySelected indexOfObject:[NSNumber numberWithInteger:indexPath.row]] == NSNotFound) {
                imgBlur.hidden = YES;
                imgSelectedIcon.hidden = YES;
            } else {
                imgBlur.hidden = NO;
                imgSelectedIcon.hidden = NO;
            }
        }
        UIImageView * imgInstagramIcon = (UIImageView *) [cell viewWithTag:10];
        if ([model[@"isInstagram"] boolValue]) {
            imgInstagramIcon.hidden = NO;
        } else {
            imgInstagramIcon.hidden = YES;
        }
        
        return cell;
    } else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell_photo_loading" forIndexPath:indexPath];
        return cell;
    }

}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSDictionary * model;
    if (self.isFromAddFriend) {
        model = [self getPhotosFromIndex:indexPath.section][indexPath.row];
    } else {
        if (indexPath.section) {
            model = [self getPhotosFromIndex:indexPath.section - 1][indexPath.row];
        } else {
            if (indexPath.row == myFacebookPhotos.count) {
                return;
            }
            model = myFacebookPhotos[indexPath.row];
        }
    }
    if (!model[@"imgFace"]) {
        return;
    }
    if (indexPath.section || self.isFromAddFriend) {
        if ([arraySelectedFriendPhotos indexOfObject:indexPath] == NSNotFound) {
            if (arraySelectedFriendPhotos.count >= 10) {
                [[[UIAlertView alloc] initWithTitle:@"" message:@"You can't choose more 10 images." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                return;
            } else {
                [arraySelectedFriendPhotos addObject:indexPath];
            }
        } else {
            [arraySelectedFriendPhotos removeObject:indexPath];
        }
        if (self.isFromAddFriend) {
            self.lblCntSelectedPhoto.text = [NSString stringWithFormat:@"Selected Photos: %d", (int)arraySelectedFriendPhotos.count];
            if (arraySelectedFriendPhotos.count == 0) {
                self.lblCntSelectedPhoto.textColor = [UIColor blackColor];
            } else if (arraySelectedFriendPhotos.count <= 4) {
                self.lblCntSelectedPhoto.textColor = [UIColor yellowColor];
            } else if (arraySelectedFriendPhotos.count <= 8) {
                self.lblCntSelectedPhoto.textColor = [UIColor greenColor];
            }else {
                self.lblCntSelectedPhoto.textColor = [UIColor redColor];
            }

        }
    } else {
        if ([arraySelected indexOfObject:[NSNumber numberWithInteger:indexPath.row]] == NSNotFound) {
            if (arraySelected.count >= 10) {
                [[[UIAlertView alloc] initWithTitle:@"" message:@"You can't choose more 10 images." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                return;
            } else {
                [arraySelected addObject:[NSNumber numberWithInteger:indexPath.row]];
            }
        } else {
            [arraySelected removeObject:[NSNumber numberWithInteger:indexPath.row]];
        }
        self.lblCntSelectedPhoto.text = [NSString stringWithFormat:@"Selected Photos: %d", (int)arraySelected.count];
        if (arraySelected.count == 0) {
            self.lblCntSelectedPhoto.textColor = [UIColor blackColor];
        } else if (arraySelected.count <= 4) {
            self.lblCntSelectedPhoto.textColor = [UIColor yellowColor];
        } else if (arraySelected.count <= 8) {
            self.lblCntSelectedPhoto.textColor = [UIColor greenColor];
        }else {
            self.lblCntSelectedPhoto.textColor = [UIColor redColor];
        }

    }
    [collectionView reloadData];

}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView * resView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        UserSectionCollectionReusableView * view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"user_header_profile" forIndexPath:indexPath];
        view.imgView.layer.masksToBounds = YES;
        view.imgView.layer.cornerRadius = view.imgView.frame.size.width / 2;
        view.imgView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        view.imgView.layer.borderWidth = 2;
        NSString * name = @"Me";
        if (self.isFromAddFriend) {
            name = [self.arraySelectedFriends[indexPath.section] name];
        } else {
            if (indexPath.section) {
                name = [self.arraySelectedFriends[indexPath.section - 1] name];
            }
        }
        view.lblName.text = name;
        if (!self.isFromAddFriend && !indexPath.section) {
            if (myImage) {
                [view.imgView setImage:myImage];
            } else {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSString * strPhoto = [PFUser currentUser][@"profileImageURL"];
                    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:strPhoto]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImage * image = [UIImage imageWithData:data];
                        if (image) {
                            if (view) {
                                [view.imgView setImage:image];
                            }
                            myImage = image;
                        }
                    });
                });
  
            }
        } else {
            FriendModel * model;
            if (self.isFromAddFriend) {
                model = self.arraySelectedFriends[indexPath.section];
            } else {
                model = self.arraySelectedFriends[indexPath.section - 1];
            }
            if (model.imgPhoto) {
                view.imgView.image = model.imgPhoto;
            } else {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.strPhotoURL]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImage * image = [UIImage imageWithData:data];
                        if (image) {
                            if (view) {
                                [view.imgView setImage:image];
                            }
                            model.imgPhoto = image;
                        }
                    });
                });
                
            }
        }
        resView = view;
    }
    return resView;
}
#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary * model;
    if (self.isFromAddFriend) {
        model = [self getPhotosFromIndex:indexPath.section][indexPath.row];
    } else {
        if (indexPath.section) {
            model = [self getPhotosFromIndex:indexPath.section - 1][indexPath.row];
        } else {
            model = myFacebookPhotos[indexPath.row];
        }
    }
    if (model[@"imgFace"]) {
        return CGSizeMake(collectionView.frame.size.width / 2 - 15, collectionView.frame.size.width / 2 - 15);
    }
    return CGSizeMake(collectionView.frame.size.width / 2 - 15, 44);
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

@end
