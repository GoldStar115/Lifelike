//
//  AppDelegate.m
//  Lifelike
//
//  Created by LoveStar_PC on 1/28/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "FaceppAPI.h"
#import "UIImage+ImageEffects.h"

#import <Quickblox/Quickblox.h>

#import "Global.h"
#import "GlobalProc.h"

@interface AppDelegate ()
{
    NSDictionary * dicPN;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    
    [QBSettings setApplicationID:37714];
    [QBSettings setAuthKey:@"GbgbbqFt9aDG5p-"];
    [QBSettings setAuthSecret:@"9gYLnRO3Tjgvuqq"];
    [QBSettings setAccountKey:@"Qm1xDxjngqSxL4stkEKR"];
    
    // Override point for customization after application launch.
    [Fabric with:@[[Crashlytics class]]];
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"oeM1xBtOQmt7ha32qkcVkyZyo4RklJCXiJeyfc8U"
                  clientKey:@"f8XO3oUjp4h8RnRc9noalwwx6PnXamdTcUmDW6ua"];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    // initialize
    [FaceppAPI initWithApiKey:@"8412dbff152d20cd011331b5f643163e" andApiSecret:@"twKy5rK0V5Kb5M7aOr7WvELOpLrX1ULU" andRegion:APIServerRegionUS];
    
    // turn on the debug mode
    [FaceppAPI setDebugMode:NO];
    self.arrayMyFriends = [NSMutableArray array];
    self.arrayInvitableFriends = [NSMutableArray array];
    [Global loadAllPhotosFromDevice];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    self.leftMenu = (LeftMenuViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"LeftMenuViewController"];
    
    [SlideNavigationController sharedInstance].leftMenu = self.leftMenu;
    [SlideNavigationController sharedInstance].portraitSlideOffset = 0;
    [SlideNavigationController sharedInstance].landscapeSlideOffset = 0;
    [SlideNavigationController sharedInstance].enableSwipeGesture = NO;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidClose object:nil queue:nil usingBlock:^(NSNotification *notification) {
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidOpen object:nil queue:nil usingBlock:^(NSNotification *notification) {
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidReveal object:nil queue:nil usingBlock:^(NSNotification *notification) {
        
        //        [self getSectionFromServer];
        
    }];

//    QBUUser * user = [QBUUser user];
//    user.login = @"adrianTester";
//    user.password = @"abc_12345";
//    [QBRequest signUp:user successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
//        
//    } errorBlock:^(QBResponse * _Nonnull response) {
//        
//    }];
    
//    [QBRequest logInWithUserLogin:@"adrianTester" password:@"abc_12345" successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
//        
//    } errorBlock:^(QBResponse * _Nonnull response) {
//        
//    }];
    return YES;
}
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [Global saveAllPhotosToDevice];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    if ([PFUser currentUser]) {
        [GlobalProc loadAllPushnotificationsWithCompletion:^(NSArray *arrayPN) {
            self.arrayPushnotifications = [NSMutableArray arrayWithArray:arrayPN];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadedPN" object:nil userInfo:nil];
            
        }];

    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}
#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif
#pragma mark - RemoteNotifications
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"push error %@", [error localizedDescription]);
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if ([PFUser currentUser]) {
        [currentInstallation setObject:[PFUser currentUser][@"facebookId"] forKey:@"userFacebookId"];
    }
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (![PFUser currentUser]) {
        return;
    }
    NSString * typePN = userInfo[@"type"];
    dicPN = userInfo;
    NSLog(@"%@", userInfo);
    
//    [PFPush handlePush:userInfo];
    if (application.applicationState == UIApplicationStateActive) {
        [GlobalProc loadAllPushnotificationsWithCompletion:^(NSArray *arrayPN) {
            self.arrayPushnotifications = [NSMutableArray arrayWithArray:arrayPN];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadedPN" object:nil userInfo:nil];

        }];
        if ([typePN isEqualToString:@"requestPhoto"]) {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"LifeLike" message:userInfo[@"aps"][@"alert"] delegate:self cancelButtonTitle:@"Not now" otherButtonTitles:@"Yes", nil];
            alertView.tag = 1;
            [alertView show];
        }
        if ([typePN isEqualToString:@"hasAcceptedRequestToUsePhotos"]) {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"LifeLike" message:userInfo[@"aps"][@"alert"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alertView.tag = 2;
            [alertView show];
        }
    } else {
        
    }
}
#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 1:
            if (buttonIndex) {
                [self showWaitingScreen:@"Accepting ..." bShowText:YES withSize:CGSizeMake(150 * MULTIPLY_VALUE, 100 * MULTIPLY_VALUE)];
                
                [GlobalProc acceptRequestToUsePhotosWithFacebookID:dicPN[@"sentUser"] withCompletion:^(BOOL isSuccess) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self hideWaitingScreen];
                        for (PFObject * theObject in self.arrayPushnotifications) {
                            if ([theObject.objectId isEqualToString:dicPN[@"idPN"]]) {
                                [theObject deleteInBackground];
                                [self.arrayPushnotifications removeObject:theObject];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadedPN" object:nil userInfo:nil];
                                break;
                            }
                        }

                    });

                }];
            }
            break;
            
        case 2:
            for (PFObject * theObject in self.arrayPushnotifications) {
                if ([theObject.objectId isEqualToString:dicPN[@"idPN"]]) {
                    [theObject deleteInBackground];
                    [self.arrayPushnotifications removeObject:theObject];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadedPN" object:nil userInfo:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AcceptedPhotosPN" object:nil userInfo:dicPN];
                    break;
                }
            }

            break;
            
        case 3:
            
            break;
            
        default:
            break;
    }
}
#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "IT.Lifelike" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Lifelike" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Lifelike.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
#pragma mark - Custom Functions
+(AppDelegate *) sharedAppDelegate
{
    AppDelegate * delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    return delegate;
}

#pragma mark - Indicator views
#define TAG_WAIT_SCREEN_VIEW            1025
#define TAG_WAIT_SCREEN_INDICATOR       1026
#define TAG_WAIT_SCREEN_LABEL           1027


- (void)showWaitingScreen:(NSString *)strText bShowText:(BOOL)bShowText withSize : (CGSize) size
{
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    [view setTag:TAG_WAIT_SCREEN_VIEW];
    [view setBackgroundColor:[UIColor clearColor]];
    [view setAlpha:1.0f];
    
    if (bShowText) {
        UIView *subView = [[UIView alloc] init];
        [subView setBackgroundColor:[UIColor blackColor]];
        [subView setAlpha:0.7];
        
        int width = size.width;
        int height = size.height;
        
        [subView setFrame:CGRectMake(view.frame.size.width/2-width/2, view.frame.size.height/2-height/2, width, height)];
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [indicatorView setTag:TAG_WAIT_SCREEN_INDICATOR];
        
        CGRect rectIndicatorViewFrame = [indicatorView frame];
        
        width = rectIndicatorViewFrame.size.width;
        height = rectIndicatorViewFrame.size.height;
        
        [indicatorView setFrame:CGRectMake(subView.frame.size.width/2-width/2, subView.frame.size.height/3-width/2, width, height)];
        
        [indicatorView startAnimating];
        [subView addSubview:indicatorView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, subView.frame.size.height * 2/3, subView.frame.size.width, subView.frame.size.height/3)];
        [label setText:strText];
        
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        
        [label setTextColor:[UIColor whiteColor]];
        [label setTag:TAG_WAIT_SCREEN_LABEL];
        
        [label setFont:[UIFont fontWithName:@"Caflisch Script Web" size:17 * MULTIPLY_VALUE]];
        
        [subView addSubview:label];
        subView.layer.cornerRadius = 10.0f;//  = [Common roundCornersOnView:subView onTopLeft:YES topRight:YES bottomLeft:YES bottomRight:YES radius:10.0f];
        
        [view addSubview:subView];
    }
    
    [_window addSubview:view];
}

- (void)hideWaitingScreen {
    
    UIView *view = [_window viewWithTag:TAG_WAIT_SCREEN_VIEW];
    
    if (view) {
        UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView*)[view viewWithTag:TAG_WAIT_SCREEN_INDICATOR];
        
        if (indicatorView)
            [indicatorView stopAnimating];
        
        [view removeFromSuperview];
        
        UILabel *label = (UILabel *)[view viewWithTag:TAG_WAIT_SCREEN_LABEL];
        if (label) {
            [label removeFromSuperview];
        }
    }
}

@end
