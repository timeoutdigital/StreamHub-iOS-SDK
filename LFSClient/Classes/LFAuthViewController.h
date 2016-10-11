
#import <UIKit/UIKit.h>
@protocol LFAuthenticationDelegate;
@interface LFAuthViewController : UIViewController
@property(nonatomic,strong) id<LFAuthenticationDelegate> delegate;

- (instancetype)initWithEnvironment:(NSString*)environment network:(NSString*)network next:(NSString*)next;
+(id)getLFProfile;
+(NSString*)getToken;
+(void)logout;
+(void)clearCokiee;
@end

@protocol LFAuthenticationDelegate <NSObject>
@required
-(void)didReceiveLFAuthToken:(id)profile;
-(void)didFailLFRequest;
@end