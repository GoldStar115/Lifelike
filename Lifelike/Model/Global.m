//
//  Global.m
//  Lifelike
//
//  Created by LoveStar_PC on 3/23/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//

#import "Global.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "PhotoModel.h"
#import "GlobalProc.h"

#define TimerValue 0.5
@interface Global() {
    
}
@property NSString * nextURL;

@property NSTimer * timerForPhoto;



@end

@implementation Global
+ (instancetype) sharedInstance {
    static Global *sharedInstance = nil;
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
        
        sharedInstance.dictionaryFacePhotos = [NSMutableDictionary dictionary];
        sharedInstance.timerForPhoto = [NSTimer scheduledTimerWithTimeInterval:TimerValue target:sharedInstance selector:@selector(onTimerReloadPhotos) userInfo:nil repeats:YES];

    }
    
    return sharedInstance;
    
}
- (void) onTimerReloadPhotos {
    NSMutableArray * tmpArray = [NSMutableArray arrayWithArray:self.dictionaryFacePhotos.allValues];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created"
                                                 ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    tmpArray = [NSMutableArray arrayWithArray:[tmpArray sortedArrayUsingDescriptors:sortDescriptors]];

    for (NSMutableDictionary * theDic in tmpArray) {
//        if ([theDic[@"connectingToFaceServer"] boolValue] && [theDic[@"cntTried"] integerValue] < MAX_TRYING) {
//            return;
//        }
        if (![theDic[@"connectingToFaceServer"] boolValue] && !theDic[@"imgFace"] && [theDic[@"cntTried"] integerValue] < MAX_TRYING) {
            if (theDic[@"image"]) {
                NSMutableDictionary * tmpDic = [[NSMutableDictionary alloc] initWithDictionary:theDic];
                UIImage * imgFace = [GlobalProc detectFaceFromImage:theDic[@"image"]];
                if (imgFace) {
                    NSData * dataFace= UIImageJPEGRepresentation(imgFace, 1.0);
                    tmpDic[@"imgFace"] = dataFace;
                    [tmpDic removeObjectForKey:@"image"];
                } else {
                    tmpDic[@"cntTried"] = @(MAX_TRYING);
                }
                self.dictionaryFacePhotos[[NSString stringWithFormat:@"%@-%@", theDic[@"facebookId"], theDic[@"id"]]] = tmpDic;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_GOT_FACE object:nil userInfo:nil];
            } else {
                [self getPhotoWithPhotoId:theDic[@"id"] withFacebookID:theDic[@"facebookId"]];
            }

            return;
        }
    }
    if (![Global loadingPhotosFromService]) {
//        [self.timerForPhoto invalidate];
        NSLog(@"completed to load the photos.");
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_COMPLETE_FACE object:nil userInfo:nil];

        [Global saveAllPhotosToDevice];
    }

}
- (void) loadAllPhotosForFacebookId:(NSString *) idFacebook WithInstagramID:(NSString *) idInstagram withToken:(NSString *) token {
    [GlobalProc getPostsInstagramWithUserId:idInstagram withToken:token completion:^(NSArray *arrayPhotoModels) {
        for (PhotoModel * model in arrayPhotoModels) {
            [self addPhotoModel:model withFacebookID:idFacebook];
            [self getPhotoWithPhotoId:model.idPhoto withFacebookID:idFacebook];

        }
        if (!self.timerForPhoto.valid) {
            [self.timerForPhoto fire];// = [NSTimer scheduledTimerWithTimeInterval:TimerValue target:self selector:@selector(onTimerReloadPhotos) userInfo:nil repeats:YES];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_GOT_FACE object:nil userInfo:nil];
    } failure:^(NSString *errorMessage) {
        
    }];
}
- (void) loadAllPhotosWithFacebookID:(NSString *) idFacebook {
    if (!self.dictionaryFacePhotos) {
        self.dictionaryFacePhotos = [NSMutableDictionary dictionary];
    }
    if ([PFUser currentUser]) {
        self.isTriedLoading = YES;
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                      initWithGraphPath:[NSString stringWithFormat:@"%@/photos", idFacebook]
                                      parameters:@{@"fields": @"images,created_time,updated_time,tags"}
                                      HTTPMethod:@"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                              id result,
                                              NSError *error) {
            if (!error && result) {
                // Handle the result
                NSDictionary * dic = [NSDictionary dictionaryWithDictionary:result];
                if (dic[@"data"]) {
                    if ([dic[@"data"] isKindOfClass:[NSArray class]]) {
                        for (NSDictionary * theDic in dic[@"data"]) {
                            PhotoModel * model = [PhotoModel getPhotoObjectFromDictionary:theDic];
                            if (model) {
                                [self addPhotoModel:model withFacebookID:idFacebook];
                                [self getPhotoWithPhotoId:model.idPhoto withFacebookID:idFacebook];
                            }
                        }
                        if (!self.timerForPhoto.valid) {
                            self.timerForPhoto = [NSTimer scheduledTimerWithTimeInterval:TimerValue target:self selector:@selector(onTimerReloadPhotos) userInfo:nil repeats:YES];
                        }
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_GOT_FACE object:nil userInfo:nil];
                        
                    }
                    if ([dic[@"paging"] isKindOfClass:[NSDictionary class]]) {
                        if (dic[@"paging"][@"next"]) {
                            self.nextURL = dic[@"paging"][@"next"];
                            if (self.nextURL.length) {
                                [self loadNextPhotos:self.nextURL withFacebookID:idFacebook completion:^(NSArray *arrFriend) {
                                    
                                }];
                                
                            }
                        }
                    }
                } else {
                }

            }
            
        }];

    }
}
- (void) addPhotoModel:(PhotoModel *) model withFacebookID:(NSString *) idFacebook {
    if (self.dictionaryFacePhotos[[NSString stringWithFormat:@"%@-%@", idFacebook, model.idPhoto]]) {
        return;
    }
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";

    NSMutableDictionary * dicPhotoModel = [NSMutableDictionary dictionary];
    dicPhotoModel[@"id"] = model.idPhoto;
    dicPhotoModel[@"failedFaceDetect"] = @YES;
    dicPhotoModel[@"cntTried"] = @0;
    dicPhotoModel[@"facebookId"] = idFacebook;
    dicPhotoModel[@"created"] = [formatter stringFromDate:model.created];
    dicPhotoModel[@"strBig"] = model.strBig;
    dicPhotoModel[@"connectingToFaceServer"] = @YES;
    dicPhotoModel[@"isInstagram"] = @(model.isInstagram);
    self.dictionaryFacePhotos[[NSString stringWithFormat:@"%@-%@", idFacebook, model.idPhoto]] = dicPhotoModel;

}
- (void) getPhotoWithPhotoId:(NSString *) idPhoto withFacebookID:(NSString *) idFacebook {
    NSMutableDictionary * dicPhotoModel = [NSMutableDictionary dictionaryWithDictionary:self.dictionaryFacePhotos[[NSString stringWithFormat:@"%@-%@", idFacebook, idPhoto]]];
    if (self.dictionaryFacePhotos[[NSString stringWithFormat:@"%@-%@", idFacebook, idPhoto]]) {
        if (dicPhotoModel[@"imgFace"]) {
            return;
        }
    }
    dicPhotoModel[@"failedFaceDetect"] = @YES;
    dicPhotoModel[@"connectingToFaceServer"] = @YES;
    dicPhotoModel[@"cntTried"] = @([dicPhotoModel[@"cntTried"] integerValue] + 1);

    self.dictionaryFacePhotos[[NSString stringWithFormat:@"%@-%@", idFacebook, idPhoto]] = dicPhotoModel;

    [GlobalProc getImageFromURL:dicPhotoModel[@"strBig"] withCompletion:^(UIImage *imageDownloaded) {
        dicPhotoModel[@"connectingToFaceServer"] = @NO;
        if (imageDownloaded) {
            dicPhotoModel[@"image"] = imageDownloaded;//UIImageJPEGRepresentation(imageDownloaded, 1.0);
            dicPhotoModel[@"dateDetected"] = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
            dicPhotoModel[@"failedFaceDetect"] = @NO;
            self.dictionaryFacePhotos[[NSString stringWithFormat:@"%@-%@", idFacebook, idPhoto]] = dicPhotoModel;
            
        } else {
            
        }
    }];
    
}
- (void) loadNextPhotos:(NSString *) strURL  withFacebookID:(NSString *) idFacebook completion:(void (^)(NSArray * arrFriend))completion {
    
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
        if (data) {
            NSError *localError = nil;
            NSDictionary * dicData = [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:&localError]];
            if (dicData[@"data"]) {
                NSMutableArray * array = [NSMutableArray array];
                if ([dicData[@"data"] isKindOfClass:[NSArray class]]) {
                    for (NSDictionary * theDic in dicData[@"data"]) {
                        PhotoModel * model = [PhotoModel getPhotoObjectFromDictionary:theDic];
                        if (model) {
                            [self addPhotoModel:model withFacebookID:idFacebook];
                            [self getPhotoWithPhotoId:model.idPhoto withFacebookID:idFacebook];
                        }
                    }
                    if (!self.timerForPhoto.valid) {
                        self.timerForPhoto = [NSTimer scheduledTimerWithTimeInterval:TimerValue target:self selector:@selector(onTimerReloadPhotos) userInfo:nil repeats:YES];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_GOT_FACE object:nil userInfo:nil];
                }
                if ([dicData[@"paging"] isKindOfClass:[NSDictionary class]]) {
                    if (dicData[@"paging"][@"next"]) {
                        self.nextURL = dicData[@"paging"][@"next"];
                        if (self.nextURL.length) {
                            [self loadNextPhotos:self.nextURL withFacebookID:idFacebook completion:^(NSArray *arrFriend) {
                                
                            }];
                            
                        }
                    }
                }
                completion(array);
            } else {
                completion(nil);
            }
            NSLog(@"%li", (long)statusCode);
            NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy]);
            
        }
       
        
    }] resume];
}
+ (BOOL) loadingPhotosFromService {
    for (NSDictionary * theDic in [Global sharedInstance].dictionaryFacePhotos.allValues) {
        if (![theDic[@"cntTried"] integerValue]) {
            return YES;
        }
        if (!theDic[@"imgFace"] && [theDic[@"cntTried"] integerValue] < MAX_TRYING) {
            return YES;
        }
    }
    return NO;
}
+ (void) saveAllPhotosToDevice {
    NSDictionary * tmpDic = [NSDictionary dictionaryWithDictionary:[Global sharedInstance].dictionaryFacePhotos];
    NSMutableDictionary * resDic = [NSMutableDictionary dictionary];
    for (NSString * theKey in tmpDic) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:[Global sharedInstance].dictionaryFacePhotos[theKey]];
        if (dic[@"image"]) {
            [dic removeObjectForKey:@"image"];
        }
        resDic[theKey] = dic;
        
    }
    [[NSUserDefaults standardUserDefaults] setObject:resDic forKey:@"dictionaryFacePhotos"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void) loadAllPhotosFromDevice {
    NSMutableDictionary * dic  = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"dictionaryFacePhotos"]];
    [Global sharedInstance].dictionaryFacePhotos = dic;
    if (![Global sharedInstance].dictionaryFacePhotos) {
        [Global sharedInstance].dictionaryFacePhotos = [NSMutableDictionary dictionary];
    }
    for (NSString * theKey in [Global sharedInstance].dictionaryFacePhotos.allKeys) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:[Global sharedInstance].dictionaryFacePhotos[theKey]];
        dic[@"connectingToFaceServer"] = @NO;
        [Global sharedInstance].dictionaryFacePhotos[theKey] = dic;

    }
}
+ (UIImage *)scaleAndRotateImage:(UIImage *)image {
    static int kMaxResolution = 640;
    
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        } else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
        case UIImageOrientationUp:
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored:
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown:
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeft:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException
                        format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    } else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(),
                       CGRectMake(0, 0, width, height), imgRef);
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return returnImage;
}
@end
