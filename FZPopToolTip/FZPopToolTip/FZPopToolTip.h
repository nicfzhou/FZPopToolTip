//
//  FZPopToolTip.h
//  FZPopToolTip
//
//  Created by 周峰 on 15/7/2.
//  Copyright (c) 2015年 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FZPopToolTip : UIView

-(void) addAction:(void(^)()) action forTitle:(NSString*) title;

-(void) showOnView:(UIView*) view;

-(void) dismiss;

@end
