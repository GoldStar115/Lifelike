//
//  GlobalProc.h
//  Lifelike
//
//  Created by LoveStar_PC on 3/9/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define kDeltaMove 3.0
#define kSizeIntervalMove 5.0

@interface GlobalProc : NSObject
+ (UIImage *) compositeImagesWithOrigial:(UIImage *) imgOriginal withImages:(UIImage *) imgCurrent withAlpha:(CGFloat) alpha withTotalFrames:(NSInteger) totalFrames withCurrentFrame:(NSInteger) currentFrame;
+ (UIImage *) compositeImagesWithImageSize:(CGSize) size withOrigial:(UIImage *) imgOriginal withImages:(UIImage *) imgCurrent withAlpha:(CGFloat) alpha withTotalFrames:(NSInteger) totalFrames withCurrentFrame:(NSInteger) currentFrame;
+ (UIImage *) compositeImagesWithOrigial:(UIImage *) imgOriginal withFriendImage:(UIImage *) imgCurrent withAlpha:(CGFloat) alpha;

//+ (NSArray *) getFacesFromImage :(UIImage *) image;
+ (UIImage *) getFaceWithImage:(UIImage *) originImage fromArray:(NSArray *) array withSize:(CGSize) sizeTotal;

//+ (CGRect) getFaceRectFromData:(NSData *) dataPhoto;
+ (void) getImageFromURL:(NSString * ) strPhoto withCompletion:(void (^)(UIImage * imageDownloaded))completion;

+ (UIImage *) detectFaceFromImage:(UIImage *) image;

+ (NSInteger) getLCMFromValue:(NSInteger) a withValue:(NSInteger) b;

+ (UIImage *) changeImage:(UIImage *)image withTintColor:(UIColor *) tintColor;

+ (void) loadAllPushnotificationsWithCompletion:(void (^)(NSArray * arrayPN))completion;

#pragma mark - Send Push Notification Methods
+ (void) sendRequestToUsePhotosWithFacebookID:(NSString *) facebookId withCompletion:(void (^)(BOOL isSuccess))completion;
+ (void) acceptRequestToUsePhotosWithFacebookID:(NSString *) facebookId withCompletion:(void (^)(BOOL isSuccess))completion;
#pragma mark - Instagram Methods
+ (void) getPostsInstagramWithUserId:(NSString *) userId withToken:(NSString *) strToken completion:(void (^)(NSArray * arrayPhotoModels))completion  failure:(void (^)(NSString *errorMessage))failure;

@end
