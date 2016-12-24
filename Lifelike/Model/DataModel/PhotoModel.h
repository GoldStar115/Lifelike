//
//  PhotoModel.h
//  Lifelike
//
//  Created by LoveStar_PC on 2/23/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface PhotoModel : NSObject

@property NSString * idPhoto;
@property NSURL * urlSmall;
@property NSURL * urlBig;
@property NSString * strSmall;
@property NSString * strBig;
@property UIImage * imgSmall;
@property UIImage * imgBig;
@property UIImage * imgFace;
@property NSDate * created;
@property NSDate * updated;

@property BOOL isInstagram;

+ (PhotoModel *) getPhotoObjectFromDictionary:(NSDictionary *) dictionary;
+ (PhotoModel *) getPhotoObjectInstagramFromDictionary:(NSDictionary *) dictionary;
+ (BOOL) isInDateRange:(NSInteger) range withDate:(NSDate *) created;

@end
