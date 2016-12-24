//
//  GlobalProc.m
//  Lifelike
//
//  Created by LoveStar_PC on 3/9/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//
#import <Parse/Parse.h>

#import "GlobalProc.h"
#import "FaceppAPI.h"
//#import "FaceppLocalDetector.h"
#import "Global.h"

#import "PhotoModel.h"

@implementation GlobalProc
+ (UIImage *) compositeImagesWithOrigial:(UIImage *) imgOriginal withImages:(UIImage *) imgCurrent withAlpha:(CGFloat) alpha withTotalFrames:(NSInteger) totalFrames withCurrentFrame:(NSInteger) currentFrame {
    
    return [self compositeImagesWithImageSize:imgOriginal.size withOrigial:imgOriginal withImages:imgCurrent withAlpha:alpha withTotalFrames:totalFrames withCurrentFrame:currentFrame];
}
+ (UIImage *) compositeImagesWithImageSize:(CGSize) size withOrigial:(UIImage *) imgOriginal withImages:(UIImage *) imgCurrent withAlpha:(CGFloat) alpha withTotalFrames:(NSInteger) totalFrames withCurrentFrame:(NSInteger) currentFrame {
    if (!imgCurrent) {
        return imgOriginal;
    }
    UIGraphicsBeginImageContext(size);
    [imgOriginal drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [imgCurrent drawInRect:CGRectMake(size.width - size.width * currentFrame / totalFrames, 0, size.width, size.height) blendMode:kCGBlendModeNormal alpha:alpha];
    UIImage * resImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resImage;
}
+ (UIImage *) compositeImagesWithOrigial:(UIImage *) imgOriginal withFriendImage:(UIImage *) imgCurrent withAlpha:(CGFloat) alpha {
    if (!imgCurrent) {
        return imgOriginal;
    }
    UIGraphicsBeginImageContext(imgOriginal.size);
    [imgOriginal drawInRect:CGRectMake(0, 0, imgOriginal.size.width, imgOriginal.size.height)];
    [imgCurrent drawInRect:CGRectMake(0, 0, imgOriginal.size.width, imgOriginal.size.height) blendMode:kCGBlendModeNormal alpha:alpha];
    UIImage * resImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resImage;
}
+ (CGFloat) getFloatValue:(NSDictionary *) dictionary forKey:(NSString *) key {
    if (!dictionary) {
        return 0;
    }
    if (!dictionary[key]) {
        return 0;
    }
    if ([dictionary[key] isKindOfClass:[NSNull class]]) {
        return 0;
    }
    return [dictionary[key] floatValue];
}
+ (NSInteger) getLCMFromValue:(NSInteger) a withValue:(NSInteger) b {
    
    NSInteger res = a < b ? a : b;
    if (res <= 1) {
        return 2;
    }
    return res;
    //    NSInteger lcm = (a > b) ? a : b;
    //    while (true) {
    //        if (lcm % a == 0 && lcm % b == 0) {
    //            return lcm;
    //        }
    //        lcm ++;
    //    }
    
}

+ (UIImage *) changeImage:(UIImage *)image withTintColor:(UIColor *) tintColor {
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [image drawInRect:rect];
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [tintColor CGColor]);
    CGContextFillRect(context, rect);
    CGContextRestoreGState(context);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
+ (void) loadAllPushnotificationsWithCompletion:(void (^)(NSArray * arrayPN))completion {
    if (![PFUser currentUser]) {
        completion(nil);
        
    } else {
        PFQuery * query = [PFQuery queryWithClassName:@"NotificationsClass"];
        [query whereKey:@"receiveUser" equalTo:[PFUser currentUser][@"facebookId"]];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (!error && objects) {
                NSMutableArray * arrayAcceptedRequestsToUsePhotos = [NSMutableArray arrayWithArray:[PFUser currentUser][@"AcceptedRequestsToUsePhotos"]];
                NSMutableArray * arrayPendingRequestsToUsePhotos = [NSMutableArray arrayWithArray:[PFUser currentUser][@"PendingRequestsToUsePhotos"]];
                if (!arrayAcceptedRequestsToUsePhotos) {
                    arrayAcceptedRequestsToUsePhotos = [NSMutableArray array];
                }
                if (!arrayPendingRequestsToUsePhotos) {
                    arrayPendingRequestsToUsePhotos = [NSMutableArray array];
                }
                for (PFObject * theObject in objects) {
                    if ([theObject[@"typePN"] isEqualToString:@"hasAcceptedRequestToUsePhotos"]) {
//                        PFUser * sentUser = theObject[@"sentUser"];
                        if ([arrayAcceptedRequestsToUsePhotos indexOfObject:theObject[@"sentUser"]] == NSNotFound) {
                            [arrayAcceptedRequestsToUsePhotos addObject:theObject[@"sentUser"]];
                            [arrayPendingRequestsToUsePhotos removeObject:theObject[@"sentUser"]];
                        }
                    }
                }
                [PFUser currentUser][@"AcceptedRequestsToUsePhotos"] = arrayAcceptedRequestsToUsePhotos;
                [PFUser currentUser][@"PendingRequestsToUsePhotos"] = arrayPendingRequestsToUsePhotos;
                [[PFUser currentUser] saveInBackground];
                completion(objects);
            } else {
                completion(nil);
            }
        }];
    }
    
}
#pragma mark - Instagram Methods
+ (void) getPostsInstagramWithUserId:(NSString *) userId withToken:(NSString *) strToken completion:(void (^)(NSArray * arrayPhotoModels))completion  failure:(void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary * dicParams = [NSMutableDictionary dictionary];
    dicParams[@"access_token"] = strToken;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicParams options:0 error:nil];
    //  NSLog(@"%@", [leadModel getDictionaryFromObject]);
    NSLog(@"Lead update json request : %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent?access_token=%@&count=%d", userId, strToken, (int)1000]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    
    
    //    [request setValue:@"application/vnd.buzzmove.v2+json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //    [request setHTTPBody:jsonData];
    NSLog(@"%@", request.URL);
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = -1;
        if (error) {
            failure(error.description);
        } else {
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                statusCode = [(NSHTTPURLResponse *)response statusCode];
            }
            NSError *localError = nil;
            NSDictionary * dicData = [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:&localError]];
            if (dicData[@"data"]) {
                NSMutableArray * array = [NSMutableArray array];
                for (NSDictionary * theDic in dicData[@"data"]) {
                    PhotoModel * model = [PhotoModel getPhotoObjectInstagramFromDictionary:theDic];
                    if (model) {
                        [array addObject:model];
                    }
                }
                completion(array);
            } else {
                failure(dicData[@"message"]);
//                LeadModel * model = [LeadModel leadModelFromDictionary:dicData];
//                if (model) {
//                    completion(model);
//                } else {
//                    failure(@"Failed to update the lead");
//                }
            }
            NSLog(@"%li", (long)statusCode);
//            NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy]);
        }
    }] resume];
}
#pragma mark - Face Detect Methods
+ (void) getImageFromURL:(NSString * ) strPhoto withCompletion:(void (^)(UIImage * imageDownloaded))completion {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:strPhoto]];
        UIImage * image = [UIImage imageWithData:data];
        if (image) {
            completion(image);
        } else {
            completion(nil);
        }
        
    });
}
+ (UIImage *) detectFaceFromImage:(UIImage *) image {
    CIImage * imgCI = [CIImage imageWithCGImage:image.CGImage];
    int exifOrientation;
    switch (image.imageOrientation) {
        case UIImageOrientationUp:
            exifOrientation = 1;
            break;
        case UIImageOrientationDown:
            exifOrientation = 3;
            break;
        case UIImageOrientationLeft:
            exifOrientation = 8;
            break;
        case UIImageOrientationRight:
            exifOrientation = 6;
            break;
        case UIImageOrientationUpMirrored:
            exifOrientation = 2;
            break;
        case UIImageOrientationDownMirrored:
            exifOrientation = 4;
            break;
        case UIImageOrientationLeftMirrored:
            exifOrientation = 5;
            break;
        case UIImageOrientationRightMirrored:
            exifOrientation = 7;
            break;
        default:
            break;
    }
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    NSDictionary *imageOptions = @{CIDetectorImageOrientation : @(exifOrientation)};
    NSArray *faces = [faceDetector featuresInImage:imgCI options:imageOptions];
    image = [self getFaceWithImage:image fromArray:faces withSize:image.size];
    return image;
}
+ (UIImage *) getFaceWithImage:(UIImage *) originImage fromArray:(NSArray *) array withSize:(CGSize) sizeTotal {
    NSMutableArray * arrayDetect = [NSMutableArray array];
    for (CIFaceFeature * theFace in array) {
        CGFloat rateFace = theFace.bounds.size.width / theFace.bounds.size.height;
        if (rateFace > 0.5 && rateFace < 2) {
            [arrayDetect addObject:theFace];
        }
    }
    if (!arrayDetect.count) {
        return nil;
    }
    CIFaceFeature * resFace = arrayDetect[0];
    
    for (CIFaceFeature * theFace in arrayDetect) {
        if (resFace.bounds.size.width < theFace.bounds.size.width && theFace.bounds.size.width < sizeTotal.width) {
            resFace = theFace;
        }
    }
    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform, 0, -originImage.size.height);
    
    CGRect faceRect = CGRectApplyAffineTransform(resFace.bounds, transform);// resFace.bounds;
    
    return [self getOnlyFaceFromPhoto:originImage withFaceRect:faceRect withDelta:faceRect.size.width * 0.3];
}
+ (UIImage *) getOnlyFaceFromPhoto:(UIImage *) photo withFaceRect:(CGRect) faceRect withDelta:(CGFloat) delta {
    CGRect rectOnlyFace = CGRectMake(faceRect.origin.x - delta, faceRect.origin.y - delta, faceRect.size.width + delta * 2, faceRect.size.height + delta * 2);
    if (rectOnlyFace.size.width > photo.size.width) {
        rectOnlyFace.origin.x = 0;
        rectOnlyFace.size.width = photo.size.width;
    }
    if (rectOnlyFace.size.height > photo.size.height) {
        rectOnlyFace.origin.y = 0;
        rectOnlyFace.size.height = photo.size.height;
    }
    if (rectOnlyFace.origin.x < 0) {
        rectOnlyFace.origin.x = 0;
    }
    if (rectOnlyFace.origin.y < 0) {
        rectOnlyFace.origin.y = 0;
    }
    if (rectOnlyFace.origin.x + rectOnlyFace.size.width > photo.size.width) {
        rectOnlyFace.origin.x -= rectOnlyFace.origin.x + rectOnlyFace.size.width - photo.size.width;
    }
    if (rectOnlyFace.origin.y + rectOnlyFace.size.height > photo.size.height) {
        rectOnlyFace.origin.y -= rectOnlyFace.origin.y + rectOnlyFace.size.height - photo.size.height;
    }
    CGImageRef imgRef = CGImageCreateWithImageInRect(photo.CGImage, rectOnlyFace);
    UIImage * resImage = [UIImage imageWithCGImage:imgRef];
    return resImage;
}
#pragma mark - Send Push Notification Methods
+ (void) sendRequestToUsePhotosWithFacebookID:(NSString *) facebookId withCompletion:(void (^)(BOOL isSuccess))completion
{
    PFObject * objectPN = [PFObject objectWithClassName:@"NotificationsClass"];
    objectPN[@"typePN"] = @"requestPhoto";
    objectPN[@"isRead"] = @NO;
    objectPN[@"sentUser"] = [PFUser currentUser][@"facebookId"];
    objectPN[@"receiveUser"] = facebookId;
    objectPN[@"message"] = [NSString stringWithFormat:@"%@ requested to use your photos", [PFUser currentUser][@"name"]];
    [objectPN saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            //                        PFQuery *pushQuery = [PFInstallation query];
            //                        [pushQuery whereKey:@"userFacebookId" notEqualTo:self.selectedFriend.idFB];
            NSMutableArray * arrayPendingRequestsToUsePhotos = [NSMutableArray arrayWithArray:[PFUser currentUser][@"PendingRequestsToUsePhotos"]];
            if (!arrayPendingRequestsToUsePhotos) {
                arrayPendingRequestsToUsePhotos = [NSMutableArray array];
            }
            if ([arrayPendingRequestsToUsePhotos indexOfObject:facebookId] == NSNotFound) {
                [arrayPendingRequestsToUsePhotos addObject:facebookId];
            }
            [PFUser currentUser][@"PendingRequestsToUsePhotos"] = arrayPendingRequestsToUsePhotos;
            [[PFUser currentUser] saveInBackground];
            
            NSDictionary *data = @{
                                   @"alert" : [NSString stringWithFormat:@"%@ requested to use your photos", [PFUser currentUser][@"name"]],
                                   @"type" : @"requestPhoto",
                                   @"badge" : @"Increment",
                                   @"sentUser" : [PFUser currentUser][@"facebookId"],
                                   @"idPN" : objectPN.objectId
                                   };
            
            PFPush *push = [[PFPush alloc] init];
            //                        [push setQuery:pushQuery];
            [push setData:data];
            [push setChannel:[NSString stringWithFormat:@"id_%@", facebookId]];
//            [push setMessage:[NSString stringWithFormat:@"%@ requested to use your photos", [PFUser currentUser][@"name"]]];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
            }];
            completion(YES);
            
        } else {
            completion(NO);
        }
    }];
    
}
+ (void) acceptRequestToUsePhotosWithFacebookID:(NSString *) facebookId withCompletion:(void (^)(BOOL isSuccess))completion
{
    PFObject * objectPN = [PFObject objectWithClassName:@"NotificationsClass"];
    objectPN[@"typePN"] = @"hasAcceptedRequestToUsePhotos";
    objectPN[@"isRead"] = @NO;
    objectPN[@"sentUser"] = [PFUser currentUser][@"facebookId"];
    objectPN[@"receiveUser"] = facebookId;
    objectPN[@"message"] = [NSString stringWithFormat:@"%@ accepted to use photos", [PFUser currentUser][@"name"]];
    [objectPN saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            
            NSDictionary *data = @{
                                   @"alert" : [NSString stringWithFormat:@"%@ accepted to use photos", [PFUser currentUser][@"name"]],
                                   @"type" : @"hasAcceptedRequestToUsePhotos",
                                   @"badge" : @"Increment",
                                   @"sentUser" : [PFUser currentUser][@"facebookId"],
                                   @"idPN" : objectPN.objectId
                                   };
            
            PFPush *push = [[PFPush alloc] init];
            //                        [push setQuery:pushQuery];
            [push setData:data];
            [push setChannel:[NSString stringWithFormat:@"id_%@", facebookId]];
//            [push setMessage:[NSString stringWithFormat:@"%@ accepted to use photos", [PFUser currentUser][@"name"]]];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
            }];
            completion(YES);
            
        } else {
            completion(NO);
        }
    }];
    
}
@end
