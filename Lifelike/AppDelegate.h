//
//  AppDelegate.h
//  Lifelike
//
//  Created by LoveStar_PC on 1/28/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "SlideNavigationController.h"
#import "LeftMenuViewController.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#define SCREEN_WIDTH			[[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT			[[UIScreen mainScreen] bounds].size.height

#define MULTIPLY_VALUE          (IS_IPAD ? 2.0 : 1.0)

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property LeftMenuViewController *leftMenu;
@property BOOL isLoggedInAlready;
@property NSInteger selectedDateRange;
@property NSMutableArray * arrayInvitableFriends;
@property NSMutableArray * arrayMyFriends;
@property NSMutableArray * myFacebookPhotos;
@property NSMutableArray * arrayPushnotifications;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)showWaitingScreen:(NSString *)strText bShowText:(BOOL)bShowText withSize : (CGSize) size;
- (void)hideWaitingScreen;

+(AppDelegate *) sharedAppDelegate;

@end

