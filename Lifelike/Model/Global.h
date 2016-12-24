//
//  Global.h
//  Lifelike
//
//  Created by LoveStar_PC on 3/23/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define NOTI_GOT_FACE   @"notificationGotFace"
#define NOTI_COMPLETE_FACE   @"notificationCompleteFace"

#define MAX_TRYING  5

@interface Global : NSObject {
    
}
@property NSMutableDictionary * dictionaryFacePhotos;

@property BOOL isTriedLoading;


+ (instancetype) sharedInstance;

- (void) loadAllPhotosWithFacebookID:(NSString *) idFacebook;
- (void) loadAllPhotosForFacebookId:(NSString *) idFacebook WithInstagramID:(NSString *) idInstagram withToken:(NSString *) token;

+ (void) saveAllPhotosToDevice;
+ (void) loadAllPhotosFromDevice;

+ (BOOL) loadingPhotosFromService;

+ (UIImage *)scaleAndRotateImage:(UIImage *)image;

@end
