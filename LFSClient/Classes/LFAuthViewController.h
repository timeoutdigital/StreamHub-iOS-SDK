//
//  LFAuthViewController.h
//  LFToken
//
//  Created by Narendra Kumar on 5/1/16.
//  Copyright © 2016 Narendra. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LFAuthenticationDelegate;
@interface LFAuthViewController : UIViewController
@property(nonatomic,strong) id<LFAuthenticationDelegate> delegate;

- (instancetype)initWithEnvironment:(NSString*)environment network:(NSString*)network next:(NSString*)next;

@end

@protocol LFAuthenticationDelegate <NSObject>
@required
-(void)didReceiveLFAuthToken:(id)profile;
-(void)didFailLFRequest;
@end