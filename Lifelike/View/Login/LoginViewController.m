//
//  LoginViewController.m
//  Lifelike
//
//  Created by LoveStar_PC on 1/28/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <Parse/Parse.h>

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "GlobalProc.h"

#import <Quickblox/Quickblox.h>
#import "Global.h"

@interface LoginViewController ()
{
    BOOL isLogging;
    NSInteger colorValue;
    NSArray * colorArray;
    NSInteger stepInteval;
    
    NSArray * locationArray;
    NSInteger indexLocation;
    
    CGPoint originalLocation;

}
@property (weak, nonatomic) IBOutlet UIImageView *imgSpinnerCenter;
@property (weak, nonatomic) IBOutlet UIImageView *imgSpinner;
@property (weak, nonatomic) IBOutlet UIImageView *imgTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consCenterY;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    colorArray = @[@[@0, @57, @142, @214, @39, @18],
                   @[@228, @102, @33, @158, @160, @164],
                   @[@248, @208, @0, @21, @172, @150],
                   @[@113, @187, @50, @147, @152, @157],
                   @[@137, @80, @145, @228, @101, @31]
                   ];
    locationArray = @[@[@(0), @0],
                      @[@(-1), @0],
                      @[@(0), @(0)],
                      @[@(-1), @(0)],
                      @[@(-1), @(-1)],
                      @[@(-1), @(0)],
                      @[@(-1), @(1)],
                      @[@(0), @(1)],
                      @[@(0), @(0)],
                      @[@(0), @(-1)],
                      @[@(1), @(-1)],
                      @[@(1), @(0)],
                      @[@(0), @(0)],
                      @[@(0), @(1)]
                      ];
    
    stepInteval = 10;
    isLogging = NO;
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTimerForColor) userInfo:nil repeats:YES];
    originalLocation = CGPointZero;
}
- (void) viewWillAppear:(BOOL)animated {
    UIImage * img = self.imgSpinner.image;
    UIImage * curImage = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imgSpinner.image = curImage;
    
    UIImage * img_1 = self.imgTitle.image;
    UIImage * curImage_1 = [img_1 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imgTitle.image = curImage_1;
    
    UIImage * img_2 = self.imgSpinnerCenter.image;
    UIImage * curImage_2 = [img_2 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imgSpinnerCenter.image = curImage_2;
    
    indexLocation = 0;
    static BOOL isInitial = YES;
    if (isInitial) {
        originalLocation = CGPointMake(self.consCenter.constant, self.consCenterY.constant);
        isInitial = NO;
    }
    
//    [self runSpinAnimationOnView:self.imgSpinner duration:1.0 rotations:1 repeat:100000];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) onTimerForColor {
    static CGFloat cnt = 0;
    cnt += kDeltaMove;
    self.consCenter.constant = originalLocation.x + kSizeIntervalMove / 2 - (CGFloat)rand() / (CGFloat)RAND_MAX * kSizeIntervalMove;
    self.consCenterY.constant = originalLocation.y + kSizeIntervalMove / 2 - (CGFloat)rand() / (CGFloat)RAND_MAX * kSizeIntervalMove;
    if (cnt > kSizeIntervalMove) {
        cnt = 0;
        indexLocation ++;
        if (indexLocation >= locationArray.count) {
            indexLocation = 0;
        }
    }
    NSInteger nextIndex = indexLocation + 1;
    if (nextIndex >= locationArray.count) {
        nextIndex = 0;
    }
//    self.consCenter.constant = originalLocation.x + [locationArray[indexLocation][0] floatValue] * kSizeIntervalMove + ([locationArray[nextIndex][0] floatValue] - [locationArray[indexLocation][0] floatValue]) * cnt;
//    self.consCenterY.constant = originalLocation.y + [locationArray[indexLocation][1] floatValue] * kSizeIntervalMove + ([locationArray[nextIndex][1] floatValue] - [locationArray[indexLocation][1] floatValue]) * cnt;
    
    colorValue ++;
    if (colorValue >= stepInteval * 5) {
        colorValue = 0;
    }
    CGFloat value = colorValue % stepInteval;
    NSInteger cur_i = colorValue / stepInteval;
    NSInteger next_j = colorValue / stepInteval + 1;
    if (next_j >= 5) {
        next_j = 0;
    }
    self.imgSpinner.tintColor = [self getColorValueWithCurrentIndex:cur_i withNextIndex:next_j withDelta:value withIndex:0];
    self.imgSpinnerCenter.tintColor = [self getColorValueWithCurrentIndex:cur_i withNextIndex:next_j withDelta:value withIndex:3];
    self.imgTitle.tintColor = self.imgSpinner.tintColor;
    
}
- (UIColor *) getColorValueWithCurrentIndex:(NSInteger) cur_i withNextIndex:(NSInteger) next_j withDelta:(NSInteger) value withIndex:(NSInteger) index {
    CGFloat curPercent = (CGFloat)value / (CGFloat)stepInteval;
    CGFloat colorR = [colorArray[cur_i][index + 0] floatValue] / 255.0 - ([colorArray[cur_i][index + 0] floatValue] - [colorArray[next_j][index + 0] floatValue]) * curPercent / 255.0;
    CGFloat colorG = [colorArray[cur_i][index + 1] floatValue] / 255.0 - ([colorArray[cur_i][index + 1] floatValue] - [colorArray[next_j][index + 1] floatValue]) * curPercent / 255.0;
    CGFloat colorB = [colorArray[cur_i][index + 2] floatValue] / 255.0 - ([colorArray[cur_i][index + 2] floatValue] - [colorArray[next_j][index + 2] floatValue]) * curPercent / 255.0;
    return [UIColor colorWithRed:colorR green:colorG blue:colorB alpha:1.0];
}
- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full  rotation */ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
- (IBAction)onSiginInWithFacebook:(id)sender {
    
    [self.imgSpinner.layer removeAllAnimations];
    if (isLogging) {
        return;
    }
    isLogging = YES;
    NSArray *permissionsArray = @[@"public_profile", @"email", @"user_friends", @"user_photos"];
//    FBSDKLoginManager * login = [[FBSDKLoginManager alloc] init];
//    login.loginBehavior = FBSDKLoginBehaviorNative;
//    [login logInWithReadPermissions:permissionsArray fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//        if (!error) {
//            
//        }
//    }];
    // Login PFUser using Facebook
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            dispatch_async(dispatch_get_main_queue(), ^{
                isLogging = NO;
                [[AppDelegate sharedAppDelegate] hideWaitingScreen];
            });
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
            [self loadDataForFirstTime:YES];
            [self setupPush];
        } else {
            [self loadDataForFirstTime:NO];
            [self setupPush];
        }
    }];
}
-(void)setupPush {
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation.channels = @[[NSString stringWithFormat:@"id_%@", [PFUser currentUser][@"facebookId"]]];
//    [installation setObject:[PFUser currentUser][@"facebookId"] forKey:@"userFacebookId"];
    [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error)
            NSLog(@"%@", [error localizedDescription]);
    }];
}

- (void)loadDataForFirstTime:(BOOL)firstTime {
    dispatch_async(dispatch_get_main_queue(), ^{
        

        if ([PFUser currentUser] && ![Global sharedInstance].isTriedLoading) {
            [[Global sharedInstance] loadAllPhotosWithFacebookID:[PFUser currentUser][@"facebookId"]];
            if ([PFUser currentUser][@"userIdInstagram"]) {
                if ([[PFUser currentUser][@"userIdInstagram"] length]) {
                    [[Global sharedInstance] loadAllPhotosForFacebookId:[PFUser currentUser][@"facebookId"] WithInstagramID:[PFUser currentUser][@"userIdInstagram"] withToken:[PFUser currentUser][@"accessTokenInstagram"]];
                }
            }
        }
        [GlobalProc loadAllPushnotificationsWithCompletion:^(NSArray *arrayPN) {
            [AppDelegate sharedAppDelegate].arrayPushnotifications = [NSMutableArray arrayWithArray:arrayPN];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadedPN" object:nil userInfo:nil];
        }];

        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"email,name"}];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            NSDictionary *userData = (NSDictionary *)result;
            PFUser *currentUser = [PFUser currentUser];
            
            // Condition incase user denies us access to their email via facebook permissions.
            if (userData[@"email"]) {
                currentUser[@"email"] = userData[@"email"];
            }
            if (userData[@"name"]) {
                currentUser[@"name"] = userData[@"name"];
            }
            currentUser[@"facebookId"] = userData[@"id"];
            currentUser[@"profileImageURL"] = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", userData[@"id"]];
            [currentUser save];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIViewController * viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateDateRangeViewController"];
//                viewController.isNeedNextButton = YES;
                [self.navigationController pushViewController:viewController animated:YES];
            });
        }];
    });

    isLogging = NO;
}

@end
