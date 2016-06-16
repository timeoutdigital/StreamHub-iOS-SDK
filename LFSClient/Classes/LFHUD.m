#import "LFHUD.h"

@implementation LFHUD{

}

+(void)showHUD:(UIView *)view message:(NSString*)message{
    MBProgressHUD *HUD=[MBProgressHUD showHUDAddedTo:view animated:YES];
    HUD.detailsLabelText=message;
    [HUD.layer setBackgroundColor:[[UIColor colorWithWhite: 0.0 alpha:0.30] CGColor]];
    [HUD show:YES];
}
+(void)hideHud:(id)view{
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
}


@end
