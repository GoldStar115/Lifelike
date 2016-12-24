//
//  InviteViewController.m
//  Lifelike
//
//  Created by LoveStar_PC on 2/1/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

#import "InviteViewController.h"

#import "InviteTableViewCell.h"
#import "SlideNavigationController.h"
#import "FriendModel.h"
#import "AppDelegate.h"
@interface InviteViewController ()<FBSDKAppInviteDialogDelegate, FBSDKGameRequestDialogDelegate>
{
    NSString * nextURL;
    NSInteger totalCount;
}
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@property (weak, nonatomic) IBOutlet UITableView *tblView;
@end

@implementation InviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [AppDelegate sharedAppDelegate].arrayInvitableFriends = [NSMutableArray array];
    [self loadFacebookFriends];
}
- (void) viewWillAppear:(BOOL)animated {
    self.btnBack.hidden = self.isNeedNextButton;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) loadFacebookFriends {
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"me/invitable_friends"
                                  parameters:nil
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
                    [[AppDelegate sharedAppDelegate].arrayInvitableFriends addObject:model];
                }
            }
            if ([dic[@"summary"] isKindOfClass:[NSDictionary class]]) {
                totalCount = [dic[@"summary"][@"total_count"] integerValue];
            }
            nextURL = @"";
            if ([dic[@"paging"] isKindOfClass:[NSDictionary class]]) {
                if (dic[@"paging"][@"next"]) {
                    nextURL = dic[@"paging"][@"next"];
                }
            }
            [AppDelegate sharedAppDelegate].arrayInvitableFriends = [self arrangeArrayWithIndicatorWithArray:[AppDelegate sharedAppDelegate].arrayInvitableFriends];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tblView reloadData];
        });

    }];

}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (NSMutableArray *) arrangeArrayWithIndicatorWithArray:(NSMutableArray *) array {
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return [NSMutableArray arrayWithArray:[array sortedArrayUsingDescriptors:sortDescriptors]];
    
}

- (void) onInvite:(UIButton *) theButton {
//    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
//    content.appLinkURL = [NSURL URLWithString:@"https://www.mydomain.com/myapplink"];
//    //optionally set previewImageURL
//    content.appInvitePreviewImageURL = [NSURL URLWithString:@"https://www.mydomain.com/my_invite_image.jpg"];
//    
//    // present the dialog. Assumes self implements protocol `FBSDKAppInviteDialogDelegate`
//    [FBSDKAppInviteDialog showFromViewController:self withContent:content delegate:self];
    
    
    FriendModel * model = [AppDelegate sharedAppDelegate].arrayInvitableFriends[theButton.tag];
    FBSDKGameRequestContent * content = [[FBSDKGameRequestContent alloc] init];
//    content.actionType = FBSDKGameRequestActionTypeSend;
    content.message = @"IT's a nice app";
    content.title = @"Invitation";
    content.recipients = @[model.idFB];
    content.data = @"Test data";
    [FBSDKGameRequestDialog showWithContent:content delegate:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) loadNextFriend:(NSString *) strURL completion:(void (^)(NSArray * arrFriend))completion {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSLog(@"%@", request.URL);
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = -1;
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
        }
        NSError *localError = nil;
        NSDictionary * dicData = [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:&localError]];
        if (dicData[@"data"]) {
            NSMutableArray * array = [NSMutableArray array];
           if ([dicData[@"data"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary * theDic in dicData[@"data"]) {
                    FriendModel * model = [[FriendModel alloc] init];
                    model.name = theDic[@"name"];
                    model.idFB = theDic[@"id"];
                    model.strPhotoURL = theDic[@"picture"][@"data"][@"url"];
                    [array addObject:model];
                }
            }
            if ([dicData[@"summary"] isKindOfClass:[NSDictionary class]]) {
                totalCount = [dicData[@"summary"][@"total_count"] integerValue];
            }
            nextURL = @"";
            if ([dicData[@"paging"] isKindOfClass:[NSDictionary class]]) {
                if (dicData[@"paging"][@"next"]) {
                    nextURL = dicData[@"paging"][@"next"];
                }
            }
            completion(array);
        } else {
            completion(nil);
        }
        NSLog(@"%li", (long)statusCode);
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy]);
        
        
    }] resume];
}
#pragma mark - FBSDKGameRequestDialog Delegate
- (void)gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didCompleteWithResults:(NSDictionary *)results {
    
}
- (void)gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didFailWithError:(NSError *)error {
    
}
- (void)gameRequestDialogDidCancel:(FBSDKGameRequestDialog *)gameRequestDialog {
    
}
#pragma mark - FBSDKAppInviteDialog Delegate
- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results {
    
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error {
    
}
#pragma mark - UITableView Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [AppDelegate sharedAppDelegate].arrayInvitableFriends.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80 * 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"cell_invite";
    InviteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    FriendModel * model = [AppDelegate sharedAppDelegate].arrayInvitableFriends[indexPath.row];
    cell.imgProfile.layer.masksToBounds = YES;
    cell.imgProfile.layer.cornerRadius = 6;
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

    cell.lblName.text = model.name;
    cell.btnInvite.tag = indexPath.row;
    [cell.btnInvite addTarget:self action:@selector(onInvite:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.tblView.contentOffset.y > self.tblView.contentSize.height - self.tblView.frame.size.height) {
        if (!nextURL.length) {
            return;
        }
        [[AppDelegate sharedAppDelegate] showWaitingScreen:@"Loading..." bShowText:YES withSize:CGSizeMake(150 * MULTIPLY_VALUE, 100 * MULTIPLY_VALUE)];
        
        [self loadNextFriend:nextURL completion:^(NSArray * arrFriend) {
            [[AppDelegate sharedAppDelegate].arrayInvitableFriends addObjectsFromArray:arrFriend];
            [AppDelegate sharedAppDelegate].arrayInvitableFriends = [self arrangeArrayWithIndicatorWithArray:[AppDelegate sharedAppDelegate].arrayInvitableFriends];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[AppDelegate sharedAppDelegate] hideWaitingScreen];
                [self.tblView reloadData];
            });

        }];
        
        
    }
}

@end
