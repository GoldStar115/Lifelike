//
//  ShareViewController.m
//  Lifelike
//
//  Created by LoveStar_PC on 2/5/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//

#import "ShareViewController.h"
#import "SlideNavigationController.h"
#import <MessageUI/MessageUI.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

#import "CreateDateRangeViewController.h"
@interface ShareViewController ()<MFMessageComposeViewControllerDelegate, FBSDKSharingDelegate>

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onMenu:(id)sender {
    [[SlideNavigationController sharedInstance] leftMenuSelected:nil];
}
- (IBAction)onShareFacebook:(id)sender {
    FBSDKShareLinkContent * content = [[FBSDKShareLinkContent alloc] init];
    content.contentDescription = @"I just created an animation of my face.";
    content.contentTitle = @"Check out my Likelife Spin!";
    content.contentURL = self.urlGIF;
//    content.ref = @"adasdasd";
    
    FBSDKShareDialog * dialog = [[FBSDKShareDialog alloc] init];
    dialog.fromViewController = self;
    dialog.shareContent = content;
    dialog.delegate = self;
    dialog.mode = FBSDKShareDialogModeAutomatic;
    if (![dialog canShow]) {
        dialog.mode = FBSDKShareDialogModeFeedBrowser;
    }
    [dialog show];
//    [FBSDKShareDialog showFromViewController:self withContent:content  delegate:self];
    
}
- (void) gotoHomeScreen {
    for (UIViewController * theViewController in self.navigationController.viewControllers) {
        if ([theViewController isKindOfClass:[CreateDateRangeViewController class]]) {
            [self.navigationController popToViewController:theViewController animated:YES];
            break;
        }
    }

}
- (IBAction)onShareInstagram:(id)sender {
}
- (IBAction)onShareSMS:(id)sender {
    MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
    if ([MFMessageComposeViewController canSendText]) {
        controller.body = [NSString stringWithFormat:@"I just created an animation of my face.\n\n%@", self.urlGIF];
        controller.subject = @"Check out my Likelife Spin!";
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    switch (result) {
        case MessageComposeResultCancelled:
            
            break;
            
        case MessageComposeResultFailed:
            
            break;
            
        case MessageComposeResultSent:
            [self gotoHomeScreen];
            break;
            
        default:
            break;
    }
    
    
}
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    [self gotoHomeScreen];

}
- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    
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
