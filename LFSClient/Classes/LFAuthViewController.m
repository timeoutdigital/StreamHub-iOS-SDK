//
//  LFAuthViewController.m
//  LFToken
//
//  Created by Narendra Kumar on 5/1/16.
//  Copyright Â© 2016 Narendra. All rights reserved.
//

#import "LFAuthViewController.h"
#import "LFHUD.h"
@interface LFAuthViewController ()<UIWebViewDelegate>
@property(nonatomic,strong) NSString* environment;
@property(nonatomic,strong) NSString* network;
@property(nonatomic,strong) NSString *next;
@end

@implementation LFAuthViewController

- (instancetype)initWithEnvironment:(NSString*)environment network:(NSString*)network next:(NSString*)next
{
    self = [super init];
    if (self) {
        self.network =network;
        self.next = next;
        self.environment = environment;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];  //Change self.view.bounds to a smaller CGRect if you don't want it to take up the whole screen
    NSString *encodedURLParamString = [self escapeValueForURLParameter:[NSString stringWithFormat:@"https://identity.%@/%@",self.environment,self.network]];
    NSString *urlString = [NSString stringWithFormat:@"https://identity.%@/%@/pages/auth/engage/?app=%@&next=%@",self.environment,self.network,encodedURLParamString,self.next];
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    
    webView.delegate=self;
    [self.view addSubview:webView];
    
}

- (NSString *)escapeValueForURLParameter:(NSString *)valueToEscape {
    return (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) valueToEscape,
                                                                                  NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
        NSLog(@"%@",request);
    [self getDataFromCookie];
//    NSString *urlString = [request.URL absoluteString];
//    NSLog(@"%@",urlString);
//    if([urlString containsString:@"jwtProfileToken"]){
//        [self successLWithJWT:request.URL];
//        return NO;
//    }else if([urlString containsString:@"lftoken"]){
//        [self successWithLFToken:request.URL];
//        return NO;
//    }else
    if([[request.URL absoluteString] containsString:@"AuthCanceled"]){
        [self failAuth];
        return NO;
    }
    
    return YES;
}


- (NSString *)valueForKey:(NSString *)key
           fromQueryItems:(NSArray *)queryItems
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    NSURLQueryItem *queryItem = [[queryItems
                                  filteredArrayUsingPredicate:predicate]
                                 firstObject];
    
    return queryItem.value;
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
    [LFHUD showHUD:self.view message:@""];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [self getDataFromCookie];
    [LFHUD hideHud:self.view];
}
-(void)getDataFromCookie{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSHTTPCookie *cookie;
    for(cookie in [storage cookies])
    {
        if([cookie.name isEqualToString:@"lfsp-profile"]){
            NSLog(@"cookie is :%@", cookie);
            [self dismissViewControllerAnimated:YES completion:^{
                if([self.delegate respondsToSelector:@selector(didReceiveLFAuthToken:)]){
                    [self.delegate didReceiveLFAuthToken:cookie.value];
                    [storage deleteCookie:cookie];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }];
        }
    }
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [LFHUD hideHud:self.view];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)successLWithJWT:(NSURL*)url{
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url
                                                resolvingAgainstBaseURL:NO];
    
    NSArray *queryItems = urlComponents.queryItems;
    NSString *jwtToken =[self  valueForKey:@"jwtProfileToken" fromQueryItems:queryItems];
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        if([self.delegate respondsToSelector:@selector(didReceiveLFAuthToken:)]){
            [self.delegate didReceiveLFAuthToken:jwtToken];
        }
    }];
}
-(void)successWithLFToken:(NSURL*)url{
    
    NSArray* fragmentArray = [url.fragment componentsSeparatedByString: @":"];
    if(fragmentArray.count>1){
        NSString* token = [fragmentArray objectAtIndex: 1];
        
        
        [self dismissViewControllerAnimated:YES completion:^{
            if([self.delegate respondsToSelector:@selector(didReceiveLFAuthToken:)]){
                [self.delegate didReceiveLFAuthToken:token];
            }
        }];
    }else{
        [self failAuth];
    }
}

-(void)failAuth{
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        if([self.delegate respondsToSelector:@selector(didFailLFRequest)]){
            [self.delegate didFailLFRequest];
        }
    }];
}

@end