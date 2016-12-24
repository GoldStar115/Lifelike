//
//  AnimationViewController.m
//  Lifelike
//
//  Created by LoveStar_PC on 2/5/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Parse/Parse.h>

#import "AnimationViewController.h"
#import "SlideNavigationController.h"

#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"

#import "GlobalProc.h"
#import "AppDelegate.h"
#import "UIImage+ImageEffects.h"
#import <Quickblox/Quickblox.h>

#import "ShareViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

#import <AssetsLibrary/AssetsLibrary.h>

#import "UIImage+FiltrrCompositions.h"
#import "UIImage+Scale.h"
#import "AddFriendsViewController.h"

typedef enum {
    kGIFAnimateIce = 1,
    kGIFAnimateFun,
    kGIFAnimateFire
} GIFAnimationType;

@interface AnimationViewController ()
{
    NSArray * arrayAnimations;
    NSArray * arrayAnimationTitles;
    NSArray * arrayColorsFire;
    NSArray * arrayColorsIce;
    
    NSArray * effectsScreen;
    
    
    NSArray * fileNames;
    NSInteger curIndexAnimation;
    
    GIFAnimationType typeGIF;
    
    NSString * gifPath;
    NSData * gifDataToUpload;
    
    CGFloat speedGifAnimation;
}
@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnCenter;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *imgPhoto;
@property (weak, nonatomic) IBOutlet UISlider *sliderSpeed;
@property (weak, nonatomic) IBOutlet UILabel *lblSpeed;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintValue;
@property (weak, nonatomic) IBOutlet UIButton *btnInstagram;

@end

@implementation AnimationViewController

- (void)viewDidLoad {

    // Do any additional setup after loading the view.
    arrayAnimations = @[@"ice-spin-small", @"fun-spin-small", @"fire-spin-small"];
    arrayAnimationTitles = @[@"Screen", @"Fun", @"Sketch"];
    fileNames = @[@"animated_Ice.gif", @"animated_Fun.gif", @"animated_Fire.gif"];
    
    [self removeAllGIF];
    curIndexAnimation = 1;
    typeGIF = kGIFAnimateFun;
    speedGifAnimation = 0.1;
    
    effectsScreen = @[@"effect10", @"effect11", @"effect12", @"effect13", @"effect14", @"effect15", @"effect16", @"effect17", @"effect18", @"effect19"];
//    effectsScreen = @[@"effect10", @"e2", @"e3", @"e4", @"e5", @"e6", @"e7", @"e8", @"e10", @"e11"];
    
    CGFloat alphaColor = 0.6;
    arrayColorsFire = @[[UIColor colorWithRed:255.0 / 255.0 green:76.0 / 255.0 blue:63.0 / 255.0 alpha:alphaColor],
                        [UIColor colorWithRed:255.0 / 255.0 green:76.0 / 255.0 blue:7.0 / 255.0 alpha:alphaColor],
                        [UIColor colorWithRed:255.0 / 255.0 green:143.0 / 255.0 blue:100.0 / 255.0 alpha:alphaColor],
                        [UIColor colorWithRed:255.0 / 255.0 green:25.0 / 255.0 blue:100.0 / 255.0 alpha:alphaColor],
                        [UIColor colorWithRed:255.0 / 255.0 green:32.0 / 255.0 blue:0 / 255.0 alpha:alphaColor],
                        [UIColor colorWithRed:255.0 / 255.0 green:76.0 / 255.0 blue:7.0 / 255.0 alpha:alphaColor],
                        [UIColor colorWithRed:255.0 / 255.0 green:143.0 / 255.0 blue:100.0 / 255.0 alpha:alphaColor],
                        [UIColor colorWithRed:255.0 / 255.0 green:25.0 / 255.0 blue:100.0 / 255.0 alpha:alphaColor],
                        [UIColor colorWithRed:255.0 / 255.0 green:32.0 / 255.0 blue:0 / 255.0 alpha:alphaColor],
                        [UIColor colorWithRed:212.0 / 255.0 green:106.0 / 255.0 blue:29.0 / 255.0 alpha:alphaColor]
                        ];
    arrayColorsIce = @[ [UIColor colorWithRed:122.0 / 255.0 green:0.0 / 255.0 blue:255.0 / 255.0 alpha:alphaColor],
                        [UIColor colorWithRed:108.0 / 255.0 green:212.0 / 255.0 blue:255.0 / 255.0 alpha:alphaColor],
                        [UIColor colorWithRed:76.0 / 255.0 green:29.0 / 255.0 blue:255.0 / 255.0 alpha:alphaColor],
                        [UIColor colorWithRed:0.0 / 255.0 green:153.0 / 255.0 blue:255.0 / 255.0 alpha:alphaColor],
                        [UIColor colorWithRed:0.0 / 255.0 green:171.0 / 255.0 blue:216.0 / 255.0 alpha:alphaColor],
                        [UIColor colorWithRed:255.0 / 255.0 green:76.0 / 255.0 blue:7.0 / 255.0 alpha:alphaColor],
                        [UIColor colorWithRed:255.0 / 255.0 green:143.0 / 255.0 blue:100.0 / 255.0 alpha:alphaColor],
                        [UIColor colorWithRed:255.0 / 255.0 green:25.0 / 255.0 blue:100.0 / 255.0 alpha:alphaColor],
                        [UIColor colorWithRed:255.0 / 255.0 green:32.0 / 255.0 blue:0 / 255.0 alpha:alphaColor],
                        [UIColor colorWithRed:160.0 / 255.0 green:212.0 / 255.0 blue:255.0 / 255.0 alpha:alphaColor]
                        ];
    
}
- (void) viewWillAppear:(BOOL)animated {
    NSLog(@"View controllers = %d", (int)self.navigationController.viewControllers.count);
    
    self.btnLeft.layer.masksToBounds = YES;
    self.btnLeft.layer.cornerRadius = self.btnLeft.frame.size.height / 2;
    
    self.btnCenter.layer.masksToBounds = YES;
    self.btnCenter.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btnCenter.layer.borderWidth = 4;
    self.btnCenter.layer.cornerRadius = self.btnCenter.frame.size.height / 2;
    
    self.btnRight.layer.masksToBounds = YES;
    self.btnRight.layer.cornerRadius = self.btnRight.frame.size.height / 2;
    
    if (self.needReload) {
        [self removeAllGIF];
        [self reloadGIFAnimation];
        self.needReload = NO;
    }
    [self reloadAnimationButtons];
    
    
}
- (void) viewDidAppear:(BOOL)animated {
    if ([PFUser currentUser]) {
        if ([PFUser currentUser][@"userIdInstagram"]) {
            if ([[PFUser currentUser][@"userIdInstagram"] length]) {
                self.btnInstagram.hidden = YES;
                self.constraintValue.constant = -13;
            }
        }
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onChangeSpeed:(id)sender {
    UISlider * theSlider = (UISlider *) sender;
    self.lblSpeed.text = [NSString stringWithFormat:@"%d ms", (int)theSlider.value];

}
- (IBAction)onSetSpeed:(id)sender {
    if (fabs(speedGifAnimation - self.sliderSpeed.value / 1000.0) < 0.005) {
        return;
    }
    speedGifAnimation = self.sliderSpeed.value / 1000.0;
    [[AppDelegate sharedAppDelegate] showWaitingScreen:@"Generating GIF..." bShowText:YES withSize:CGSizeMake(150 * MULTIPLY_VALUE, 100 * MULTIPLY_VALUE)];
    
    [self exportAnimatedGifWithChangeSpeed:YES withCompletion:^(NSData *gifData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AppDelegate sharedAppDelegate] hideWaitingScreen];
            FLAnimatedImage *imgGIF = [[FLAnimatedImage alloc] initWithAnimatedGIFData:gifData];
            self.imgPhoto.animatedImage = imgGIF;
        });
        
    }];

}
- (IBAction)onShare:(id)sender {
    if (gifPath.length) {
//        NSString* webStringURL = [gifPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSURL* url =[NSURL URLWithString:webStringURL];
//
//        ALAssetsLibrary* library = [[ALAssetsLibrary alloc]init];
////        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:url])
//        {
//            NSURL *clipURl = url;
//            [library writeVideoAtPathToSavedPhotosAlbum:clipURl completionBlock:^(NSURL * assetURL, NSError * error)
//             {
//                 if (!error) {
//
//                 }
//             }];
//
//        }
//
//        FBSDKShareVideo * video = [[FBSDKShareVideo alloc] init];
//        video.videoURL = [NSURL URLWithString:gifPath];
//
//        FBSDKShareVideoContent * content = [[FBSDKShareVideoContent alloc] init];
//        content.video = video;
////        content.contentDescription = @"I just created an animation of my face.";
////        content.contentTitle = @"Check out my Likelife Spin!";
//        [FBSDKShareDialog showFromViewController:self withContent:content delegate:nil];
        
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy_MM_dd_hh_mm_ss";
        NSString * fileName = [NSString stringWithFormat:@"%@.gif", [formatter stringFromDate:[NSDate date]]];
        [[AppDelegate sharedAppDelegate] showWaitingScreen:@"Processing..." bShowText:YES withSize:CGSizeMake(150 * MULTIPLY_VALUE, 100 * MULTIPLY_VALUE)];
        
        
        PFObject * object = [PFObject objectWithClassName:@"GIFAnimations"];
        object[@"GIF_file"] = [PFFile fileWithName:fileName data:gifDataToUpload];
        object[@"UserCreated"] = [PFUser currentUser];
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[AppDelegate sharedAppDelegate] hideWaitingScreen];
                    ShareViewController * viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
                    viewController.urlGIF = [NSURL URLWithString:((PFFile *)object[@"GIF_file"]).url];
                    [self.navigationController pushViewController:viewController animated:YES];
                });
                
            }
        }];
        
        
        
        
        
//        [QBRequest TUploadFile:gifDataToUpload fileName:fileName contentType:@"image/gif" isPublic:YES successBlock:^(QBResponse * _Nonnull response, QBCBlob * _Nonnull blob) {
//            NSString * url = blob.publicUrl;
//            if (url) {
//                PFObject * object = [PFObject objectWithClassName:@"GIFAnimations"];
//                object[@"GIF_URL"] = url;
//                object[@"UserCreated"] = [PFUser currentUser];
//                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                    if (succeeded) {
//
//                    }
//                }];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [[AppDelegate sharedAppDelegate] hideWaitingScreen];
//                    ShareViewController * viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
//                    viewController.urlGIF = [NSURL URLWithString:url];
//                    [self.navigationController pushViewController:viewController animated:YES];
//                });
//            }
//        } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nullable status) {
//            switch (status.requestType) {
//                case QBRequestTypeUpload:
//
//                    break;
//                    
//                default:
//                    break;
//            }
//        } errorBlock:^(QBResponse * _Nonnull response) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[AppDelegate sharedAppDelegate] hideWaitingScreen];
//            });
//
//        }];
        
        
    }
}
- (void) reloadGIFAnimation {
    if (self.arraySelectedPhotos) {
        if (self.arraySelectedPhotos.count) {
            [[AppDelegate sharedAppDelegate] showWaitingScreen:@"Generating GIF..." bShowText:YES withSize:CGSizeMake(150 * MULTIPLY_VALUE, 100 * MULTIPLY_VALUE)];
            
            [self exportAnimatedGifWithChangeSpeed:NO withCompletion:^(NSData *gifData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[AppDelegate sharedAppDelegate] hideWaitingScreen];
                    FLAnimatedImage *imgGIF = [[FLAnimatedImage alloc] initWithAnimatedGIFData:gifData];
                    self.imgPhoto.animatedImage = imgGIF;
                });
                
            }];
            
        }
    }

}
- (void) reloadAnimationButtons {
    [self.btnCenter setBackgroundImage:[UIImage imageNamed:arrayAnimations[curIndexAnimation]] forState:UIControlStateNormal];
    [self.btnCenter setTitle:arrayAnimationTitles[curIndexAnimation] forState:UIControlStateNormal];

    self.btnLeft.hidden = NO;
    self.btnRight.hidden = NO;
    
    switch (curIndexAnimation) {
        case 0:
            typeGIF = kGIFAnimateIce;
            break;
            
        case 1:
            typeGIF = kGIFAnimateFun;
            break;
            
        case 2:
            typeGIF = kGIFAnimateFire;
            break;
            
        default:
            break;
    }
    if (curIndexAnimation > 0 && curIndexAnimation <= arrayAnimations.count - 1) {
        [self.btnLeft setBackgroundImage:[UIImage imageNamed:arrayAnimations[curIndexAnimation - 1]] forState:UIControlStateNormal];
        [self.btnLeft setTitle:arrayAnimationTitles[curIndexAnimation - 1] forState:UIControlStateNormal];
    } else {
        self.btnLeft.hidden = YES;
    }
    if (curIndexAnimation >= 0 && curIndexAnimation < arrayAnimations.count - 1) {
        [self.btnRight setBackgroundImage:[UIImage imageNamed:arrayAnimations[curIndexAnimation + 1]] forState:UIControlStateNormal];
        [self.btnRight setTitle:arrayAnimationTitles[curIndexAnimation + 1] forState:UIControlStateNormal];
    } else {
        self.btnRight.hidden = YES;
    }
    [self reloadGIFAnimation];


}
- (void) removeAllGIF {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    for (NSString * theFileName in fileNames) {
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:theFileName];
        [fileManager removeItemAtPath:path error:nil];
        
    }
}
- (void)exportAnimatedGifWithChangeSpeed:(BOOL)isChangingSpeed withCompletion:(void (^)(NSData *gifData))completion
{
    CGFloat timeIntervalForImage = 1.0;
    CGFloat framePerSecond = 14.0;
    NSInteger cntPerImage = (NSInteger)(framePerSecond * timeIntervalForImage);
    
    NSString * fileNameGIF;
    switch (typeGIF) {
        case kGIFAnimateIce:
            fileNameGIF = fileNames[0];
            break;
            
        case kGIFAnimateFun:
            fileNameGIF = fileNames[1];
            break;
            
        case kGIFAnimateFire:
            fileNameGIF = fileNames[2];
            break;
            
        default:
            break;
    }
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileNameGIF];
    NSData * theData = [NSData dataWithContentsOfFile:path];
    if (theData && !isChangingSpeed) {
        if (theData.length) {
            gifPath = path;
            gifDataToUpload = theData;
            completion(theData);
            return;
        }
    }
    __block CGImageDestinationRef destination = CGImageDestinationCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path], kUTTypeGIF, self.arraySelectedPhotos.count * cntPerImage, NULL);
    
    __block NSDictionary *frameProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:timeIntervalForImage / framePerSecond] forKey:(NSString *)kCGImagePropertyGIFDelayTime] forKey:(NSString *)kCGImagePropertyGIFDictionary];
    
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount]
                                                              forKey:(NSString *)kCGImagePropertyGIFDictionary];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        if (typeGIF == kGIFAnimateIce || typeGIF == kGIFAnimateFire) {
            NSArray * tmpColorArray = arrayColorsFire;
            if (typeGIF == kGIFAnimateIce) {
                tmpColorArray = arrayColorsIce;
            }
            NSInteger lcm = [GlobalProc getLCMFromValue:self.arraySelectedPhotos.count withValue:effectsScreen.count];
            
            destination = CGImageDestinationCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path], kUTTypeGIF, lcm, NULL);
            
            frameProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:speedGifAnimation] forKey:(NSString *)kCGImagePropertyGIFDelayTime] forKey:(NSString *)kCGImagePropertyGIFDictionary];
            for (int i = 0; i < lcm ; i ++) {
                UIColor * theColor = tmpColorArray[i % tmpColorArray.count];
                RGBA minrgb, maxrgb;
                CGFloat red, green, blue, alpha;
                [theColor getRed:&red green:&green blue:&blue alpha:&alpha];
                minrgb = RGBAMake(red, green, blue, 255);
                if (typeGIF == kGIFAnimateFire)
                {
//                    maxrgb = RGBAMake(red + 90, green + 130, blue + 180, 255);
//                    SEL _selector = NSSelectorFromString(effectsScreen[effectsScreen.count - (i % effectsScreen.count) - 1]);
//                    CGImageDestinationAddImage(destination, [[self.arraySelectedPhotos[i % self.arraySelectedPhotos.count] performSelector:_selector] CGImage], (CFDictionaryRef)frameProperties);
                    
//                    NSString * strFilterName = [CIFilter filterNamesInCategory:@"CICategoryColorEffect"][i];
//
                    
                    UIImage * theImage = self.arraySelectedPhotos[i % self.arraySelectedPhotos.count];
                    theImage = [theImage scaleToSize:CGSizeMake(500, 500)];

                    
//                    CGImageDestinationAddImage(destination, [self effectsWithImage:imgCI withFilterName:@"CIExposureAdjust" withParams:@{kCIInputEVKey: @2}], (CFDictionaryRef)frameProperties);
//                    CGImageDestinationAddImage(destination, [self effectsWithImage:imgCI withFilterName:@"CIVibrance" withParams:@{@"inputAmount": @20}], (CFDictionaryRef)frameProperties);
                    
//                    imgCI = [CIImage imageWithCGImage:[self effectsWithImage:imgCI withFilterName:@"CIColorPosterize" withParams:@{@"inputLevels": @5.5}] options:nil];
//                    CGImageDestinationAddImage(destination, [self effectsWithImage:imgCI withFilterName:@"CITemperatureAndTint" withParams:@{@"inputNeutral": [CIVector vectorWithX:1500 Y:2365], @"inputTargetNeutral": [CIVector vectorWithX:2500 Y:50]}], (CFDictionaryRef)frameProperties);
                    
//                    imgCI = [CIImage imageWithCGImage:[self effectsWithImage:imgCI withFilterName:@"CIToneCurve" withParams:@{@"inputPoint0": [CIVector vectorWithX:0 Y:0], @"inputPoint1":[CIVector vectorWithX:0.25 Y:0.25], @"inputPoint2":[CIVector vectorWithX:0.5 Y:0.875], @"inputPoint3":[CIVector vectorWithX:0.75 Y:0.375], @"inputPoint4":[CIVector vectorWithX:1 Y:1]}] options:nil];
//                    CGImageDestinationAddImage(destination, [self effectsWithImage:imgCI withFilterName:@"CICrystallize" withParams:@{@"inputRadius": @1, @"inputCenter":[CIVector vectorWithX:150 Y:150]}], (CFDictionaryRef)frameProperties);

//                    imgCI = [CIImage imageWithCGImage:[self effectsWithImage:imgCI withFilterName:@"CICrystallize" withParams:@{@"inputRadius": @1, @"inputCenter":[CIVector vectorWithX:theImage.size.width / 2 Y:theImage.size.height / 2]}] options:nil];
//                    imgCI = [CIImage imageWithCGImage:[self effectsWithImage:imgCI withFilterName:@"CIColorPosterize" withParams:@{@"inputLevels": @5.5}] options:nil];
//                    CGImageDestinationAddImage(destination, [self effectsWithImage:imgCI withFilterName:@"CIToneCurve" withParams:@{@"inputPoint0": [CIVector vectorWithX:0 Y:0], @"inputPoint1":[CIVector vectorWithX:104.0 / 255.0 Y:27.0 / 255.0], @"inputPoint2":[CIVector vectorWithX:111.0 / 255.0 Y:94.0 / 255.0], @"inputPoint3":[CIVector vectorWithX:201.0 / 255.0 Y:170.0 / 255.0], @"inputPoint4":[CIVector vectorWithX:1 Y:1]}], (CFDictionaryRef)frameProperties);

//                    theImage = [UIImage imageWithCGImage:[self effectsWithImage:imgCI withFilterName:@"CIHexagonalPixellate" withParams:@{@"inputScale": @8, @"inputCenter":[CIVector vectorWithX:theImage.size.width / 2 Y:theImage.size.height / 2]}]];
                    theImage = [theImage applyFiltrr:^RGBA(int r, int g, int b, int a) {
                        RGBA retVal;
                        CGFloat mulVal = 1.6, minMulVal = 0.8;
                        if (r > g && r > b) {
                            retVal.red = [theImage safe:(CGFloat)r * mulVal];
                            retVal.green = [theImage safe:(CGFloat)g * minMulVal];
                            retVal.blue = [theImage safe:(CGFloat)b * minMulVal];
                            retVal.alpha = a;

                        } else if (g > r && g > b) {
                            retVal.red = [theImage safe:(CGFloat)r * minMulVal];
                            retVal.green = [theImage safe:(CGFloat)g * mulVal];
                            retVal.blue = [theImage safe:(CGFloat)b * minMulVal];
                            retVal.alpha = a;
                        } else {
                            retVal.red = [theImage safe:(CGFloat)r * minMulVal];
                            retVal.green = [theImage safe:(CGFloat)g * minMulVal];
                            retVal.blue = [theImage safe:(CGFloat)b * mulVal];
                            retVal.alpha = a;
                        }
                        return retVal;
   
                    }];
                    CIImage * imgCI = [CIImage imageWithData: UIImagePNGRepresentation(theImage)];
                    theImage = [UIImage imageWithCGImage:[self effectsWithImage:imgCI withFilterName:@"CICrystallize" withParams:@{@"inputRadius": @3, @"inputCenter":[CIVector vectorWithX:theImage.size.width / 2 Y:theImage.size.height / 2]}]];
                    if (self.arraySelectedFriendPhotos.count) {
                        theImage = [GlobalProc compositeImagesWithOrigial:theImage withFriendImage:self.arraySelectedFriendPhotos[i % self.arraySelectedFriendPhotos.count] withAlpha:0.5];
                    }
                    CGImageDestinationAddImage(destination, [theImage CGImage], (CFDictionaryRef)frameProperties);
//                    CGImageDestinationAddImage(destination, [self effectsWithImage:imgCI withFilterName:@"CIColorPolynomial" withParams:@{@"inputRedCoefficients": [CIVector vectorWithX:0 Y:0 Z:0 W:0.4], @"inputGreenCoefficients":[CIVector vectorWithX:0 Y:0 Z:0.5 W:0.8], @"inputBlueCoefficients":[CIVector vectorWithX:0 Y:0 Z:0.5 W:1], @"inputAlphaCoefficients":[CIVector vectorWithX:0 Y:1 Z:1 W:1]}], (CFDictionaryRef)frameProperties);

                    //

                } else if (typeGIF == kGIFAnimateFun) {
                    maxrgb = RGBAMake(red + 90, green + 130, blue + 180, 255);
                    SEL _selector = NSSelectorFromString(effectsScreen[i % effectsScreen.count]);
                    
                    //                    NSString * strFilterName = [CIFilter filterNamesInCategory:@"CICategoryColorEffect"][i];
                    //
                    //                    CGImageDestinationAddImage(destination, [self effectsWithImage:self.arraySelectedPhotos[i % self.arraySelectedPhotos.count] withFilterName:strFilterName], (CFDictionaryRef)frameProperties);
                    UIImage * theImage = [self.arraySelectedPhotos[i % self.arraySelectedPhotos.count] performSelector:_selector];
                    if (self.arraySelectedFriendPhotos.count) {
                        theImage = [GlobalProc compositeImagesWithOrigial:theImage withFriendImage:self.arraySelectedFriendPhotos[i % self.arraySelectedFriendPhotos.count] withAlpha:0.5];
                    }

                    CGImageDestinationAddImage(destination, [theImage CGImage], (CFDictionaryRef)frameProperties);
                    
                } else {
//                    red = rand() % 260;
//                    green = rand() % 250;
//                    blue = rand() % 230;
                    
                    maxrgb = RGBAMake(red + 110, green + 105, blue + 150, 255);
                    minrgb = RGBAMake(red, green, blue, 255);

                    UIImage * theImage = [self.arraySelectedPhotos[i % self.arraySelectedPhotos.count] e5];
                    
                    if (self.arraySelectedFriendPhotos.count) {
                        theImage = [GlobalProc compositeImagesWithOrigial:theImage withFriendImage:self.arraySelectedFriendPhotos[i % self.arraySelectedFriendPhotos.count] withAlpha:0.5];
                    }
                    theImage = [GlobalProc compositeImagesWithImageSize:theImage.size withOrigial:theImage withImages:[UIImage imageNamed:@"lines_horizontal"] withAlpha:1.0 withTotalFrames:1 withCurrentFrame:1];
                    CGImageDestinationAddImage(destination, [theImage CGImage], (CFDictionaryRef)frameProperties);

                }
//                CGImageDestinationAddImage(destination, [self.arraySelectedPhotos[i % self.arraySelectedPhotos.count] applyBlurWithRadius:0 tintColor:theColor saturationDeltaFactor:0 maskImage:nil].CGImage, (CFDictionaryRef)frameProperties);
            }

//        } else {
//            destination = CGImageDestinationCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path], kUTTypeGIF, self.arraySelectedPhotos.count, NULL);
//            
//            frameProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.3] forKey:(NSString *)kCGImagePropertyGIFDelayTime] forKey:(NSString *)kCGImagePropertyGIFDictionary];
//            
//            for (UIImage * theImage in self.arraySelectedPhotos) {
//                UIColor * theColor = [UIColor colorWithRed:(CGFloat)(rand() % 256) / 255.0 green:(CGFloat)(rand() % 256) / 255.0 blue:(CGFloat)(rand() % 256) / 255.0 alpha:0.6];
//                CGImageDestinationAddImage(destination, [GlobalProc changeImage:theImage withTintColor:theColor].CGImage, (CFDictionaryRef)frameProperties);
//            }
////            UIImage * originalImage = nil;
////            for (UIImage * theImage in self.arraySelectedPhotos) {
////                for (NSInteger i = 0; i < cntPerImage; i ++) {
////                    if (!originalImage) {
////                        CGImageDestinationAddImage(destination, theImage.CGImage, (CFDictionaryRef)frameProperties);
////                    } else {
////                        CGImageDestinationAddImage(destination, [GlobalProc compositeImagesWithImageSize:CGSizeMake(300, 300) withOrigial:originalImage withImages:theImage withAlpha:(CGFloat)i / (CGFloat) cntPerImage withTotalFrames:cntPerImage withCurrentFrame:i].CGImage, (CFDictionaryRef)frameProperties);
////                        
////                    }
////                }
////                originalImage = theImage;
////            }
//
//        }
        CGImageDestinationSetProperties(destination, (CFDictionaryRef)gifProperties);
        CGImageDestinationFinalize(destination);
        CFRelease(destination);
        NSData * gifData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
        NSLog(@"animated GIF file created at %@ with length %d", path, gifData.length);
        gifPath = path;
        gifDataToUpload = gifData;
        completion(gifData);
    });
}
-(CGImageRef)effectsWithImage:(CIImage *) image withFilterName:(NSString *) strName withParams:(NSDictionary *) params {
    //apply sepia filter - taken from the Beginning Core Image from iOS5 by Tutorials
//    CIImage *beginImage = [CIImage imageWithData: UIImagePNGRepresentation(image)];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    NSMutableDictionary * dicParam = [NSMutableDictionary dictionaryWithDictionary:params];
    dicParam[kCIInputImageKey] = image;
    
    CIFilter *filter = [CIFilter filterWithName:strName withInputParameters:dicParam];
    CIImage *outputImage = [filter outputImage];
    
    return [context createCGImage:outputImage fromRect:[outputImage extent]];
    
//    return cgimg;
}
- (IBAction)onMenu:(id)sender {
    [[SlideNavigationController sharedInstance] leftMenuSelected:nil];
}
- (IBAction)onLeft:(id)sender {
    if (curIndexAnimation > 0) {
        curIndexAnimation --;
        [self reloadAnimationButtons];
    }
}
- (IBAction)onRight:(id)sender {
    if (curIndexAnimation < arrayAnimations.count - 1) {
        curIndexAnimation ++;
        [self reloadAnimationButtons];
    }
}
- (IBAction)onCenter:(id)sender {
    
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"id_add_facebook"]) {
        AddFriendsViewController * viewController = segue.destinationViewController;
        viewController.isInstagram = NO;
    }
    if ([segue.identifier isEqualToString:@"id_add_instagram"]) {
        AddFriendsViewController * viewController = segue.destinationViewController;
        viewController.isInstagram = YES;
    }
}


@end
