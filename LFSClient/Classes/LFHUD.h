//
//  MumsyHUD.h
//  Mumsy
//
//  Created by Kvana Inc 1 on 06/05/15.
//  Copyright (c) 2015 Kvana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface LFHUD : NSObject
+(void)showHUD:(UIView *)view message:(NSString*)message;
+(void)hideHud:(UIView *)view;
@end
