
#import <Foundation/Foundation.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface LFHUD : NSObject
+(void)showHUD:(UIView *)view message:(NSString*)message;
+(void)hideHud:(UIView *)view;
@end
