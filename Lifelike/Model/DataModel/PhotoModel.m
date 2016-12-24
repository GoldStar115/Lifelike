//
//  PhotoModel.m
//  Lifelike
//
//  Created by LoveStar_PC on 2/23/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//

#import "PhotoModel.h"

@implementation PhotoModel
+ (PhotoModel *) getPhotoObjectFromDictionary:(NSDictionary *) dictionary {
    if (!dictionary) {
        return nil;
    }
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    if (!dictionary.count) {
        return nil;
    }
    if (!dictionary[@"images"]) {
        return nil;
    }
    if (![dictionary[@"images"] isKindOfClass:[NSArray class]]) {
        return nil;
    }
    PhotoModel * model = [[PhotoModel alloc] init];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"width"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray * photos = [dictionary[@"images"] sortedArrayUsingDescriptors:sortDescriptors];
    if (!photos.count) {
        return nil;
    }
    model.strBig = photos.lastObject[@"source"];
    model.urlBig = [NSURL URLWithString:model.strBig];
    model.strSmall = photos.firstObject[@"source"];
    model.urlSmall = [NSURL URLWithString:model.strSmall];
    model.idPhoto = dictionary[@"id"];
    if (dictionary[@"created_time"]) {
        NSString * strDate = dictionary[@"created_time"];
        strDate = [strDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        strDate = [[strDate componentsSeparatedByString:@"+"] firstObject];
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
        model.created = [formatter dateFromString:strDate];
    }
    if (dictionary[@"updated_time"]) {
        NSString * strDate = dictionary[@"updated_time"];
        strDate = [strDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        strDate = [[strDate componentsSeparatedByString:@"+"] firstObject];
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
        model.updated = [formatter dateFromString:strDate];
    }
    return model;
}
+ (NSDate *) getDateFromDictionary:(NSDictionary *) dictionary withKey:(NSString * )strKey {
    if (!dictionary[strKey]) {
        return nil;
    }
    if ([dictionary[strKey] isKindOfClass:[NSNull class]]) {
        return nil;
    }
    long long  dateInt = [dictionary[strKey] longLongValue];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:dateInt];
    return date;
}
+ (PhotoModel *) getPhotoObjectInstagramFromDictionary:(NSDictionary *) dictionary {
    if (!dictionary) {
        return nil;
    }
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    if (!dictionary.count) {
        return nil;
    }
    if (!dictionary[@"images"]) {
        return nil;
    }
    if (![dictionary[@"users_in_photo"] count]) {
        return nil;
    }
    if (![dictionary[@"type"] isEqualToString:@"image"]) {
        return nil;
    }
    PhotoModel * model = [[PhotoModel alloc] init];
    model.strBig = dictionary[@"images"][@"standard_resolution"][@"url"];
    model.urlBig = [NSURL URLWithString:model.strBig];
    model.strSmall = dictionary[@"images"][@"thumbnail"][@"url"];
    model.urlSmall = [NSURL URLWithString:model.strSmall];
    model.idPhoto = dictionary[@"id"];
    model.created = [PhotoModel getDateFromDictionary:dictionary withKey:@"created_time"];
    model.updated = model.created;
    model.isInstagram = YES;
    return model;
}
+ (BOOL) isInDateRange:(NSInteger) range withDate:(NSDate *) created {
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comp = [cal components:NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd";
    if (range == 0) {
        NSString * str = [NSString stringWithFormat:@"%04d-%02d-01", comp.year, comp.month - 1];
        NSDate * date = [formatter dateFromString:str];
        if ([created compare:date] == NSOrderedDescending) {
            return YES;
        }
    } else if (range == 1) {
        NSDate * date = [formatter dateFromString:[NSString stringWithFormat:@"%04d-01-01", comp.year - 1]];
        if ([created compare:date] == NSOrderedDescending) {
            return YES;
        }
    } else if (range == 2) {
        return YES;
    }
    return NO;
}
@end
