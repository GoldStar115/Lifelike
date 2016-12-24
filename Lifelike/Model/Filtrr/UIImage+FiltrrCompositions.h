//
//  UIImage+FiltrrCompositions.h
//  FilterTest
//
//  Created by Omid Hashemi & Stefan Klefisch on 2/6/12.
//  Copyright (c) 2012 42dp. All rights reserved.
//  http://www.42dp.com
//  Github: https://github.com/OmidH/Filtrr
//
//  Based on Alex Michael's filtrr for Javascript (thanks for sharing Alex)
//  https://github.com/alexmic/filtrr


#import <UIKit/UIKit.h>

#import "UIImage+Filtrr.h"

@interface UIImage (FiltrrCompositions)

-(id) trackTime:(NSString *)method;

- (id) effect10;
- (id) effect11;
- (id) effect12;
- (id) effect13;
- (id) effect14;
- (id) effect15;
- (id) effect16;
- (id) effect17;
- (id) effect18;
- (id) effect19;

- (id) e2;
- (id) e3;
- (id) e4;
- (id) e5;
- (id) e6;
- (id) e7;
- (id) e8;
- (id) e9;
- (id) e10;
- (id) e11;

-(id) e1WithMinRGB:(RGBA)minRGB MaxRGB:(RGBA)maxRGB;
-(id) e6WithMinRGB:(RGBA)minRGB MaxRGB:(RGBA)maxRGB;
- (id) e9WithMinRGB:(RGBA)minRGB MaxRGB:(RGBA)maxRGB;

@end
