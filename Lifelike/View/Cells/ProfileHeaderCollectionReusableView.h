//
//  ProfileHeaderCollectionReusableView.h
//  Lifelike
//
//  Created by LoveStar_PC on 2/5/16.
//  Copyright © 2016 Mobile developer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileHeaderCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *imageProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnFriendImages;

@end
