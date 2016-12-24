//
//  LoginWithInstagramViewController.m
//  Lifelike
//
//  Created by LoveStar_PC on 4/21/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//

#import "LoginWithInstagramViewController.h"
#import <Parse/Parse.h>
#import "SlideNavigationController.h"
#import "Global.h"

@interface LoginWithInstagramViewController ()
{
    NSString *client_id;
    NSString *secret;
    NSString *callback;
    NSMutableData *receivedData;

}
@property (nonatomic, retain) IBOutlet UIWebView *webview;

@end

@implementation LoginWithInstagramViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    client_id = @"8ef46144563c42f096a3ea246fb4a05f";
    secret = @"a30ebf49844f465ea1ae90d2f5153ce4";
    callback = @"https://www.snapstats.com";
    NSString *url = [NSString stringWithFormat:@"https://api.instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=code",client_id,callback];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onMenu:(id)sender {
    [[SlideNavigationController sharedInstance] leftMenuSelected:nil];
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
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    //    [indicator startAnimating];
    NSLog([[request URL] host]);
    if ([[[request URL] host] isEqualToString:@"www.snapstats.com"]) {
        
        // Extract oauth_verifier from URL query
        NSString* verifier = nil;
        NSArray* urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
        for (NSString* param in urlParams) {
            NSArray* keyValue = [param componentsSeparatedByString:@"="];
            NSString* key = [keyValue objectAtIndex:0];
            if ([key isEqualToString:@"code"]) {
                verifier = [keyValue objectAtIndex:1];
                break;
            }
            if ([key isEqualToString:@"client_id"]) {
                verifier = [keyValue objectAtIndex:1];
                break;
            }
        }
        
        if (verifier) {
            
            NSString *data = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@",client_id,secret,callback,verifier];
            
            NSString *url = [NSString stringWithFormat:@"https://api.instagram.com/oauth/access_token"];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
            NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
            receivedData = [[NSMutableData alloc] init];
        } else {
            // ERROR!
        }
        
        [webView removeFromSuperview];
        
        return NO;
    }
    return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    // [indicator stopAnimating];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data

{
    [receivedData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[NSString stringWithFormat:@"%@", error]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary * dicData = [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:receivedData options:0 error:nil]];
    NSLog(@"%@", dicData);
    if (dicData[@"user"][@"id"]) {
        [PFUser currentUser][@"userIdInstagram"] = [NSString stringWithFormat:@"%@", dicData[@"user"][@"id"]];
        [PFUser currentUser][@"accessTokenInstagram"] = [NSString stringWithFormat:@"%@", dicData[@"access_token"]];
        [[PFUser currentUser] saveEventually];
        [[Global sharedInstance] loadAllPhotosForFacebookId:[PFUser currentUser][@"facebookId"] WithInstagramID:[PFUser currentUser][@"userIdInstagram"] withToken:[PFUser currentUser][@"accessTokenInstagram"]];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoggedInInstagramPN" object:self userInfo:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
//    NSString *pdata = [NSString stringWithFormat:@"type=3&token=%@", [dicData objectForKey:@"access_token"]];
//    UIAlertView *alertView = [[UIAlertView alloc]
//                              initWithTitle:@"Instagram Access TOken"
//                              message:pdata
//                              delegate:nil
//                              cancelButtonTitle:@"OK"
//                              otherButtonTitles:nil];
//    [alertView show];
}

@end
