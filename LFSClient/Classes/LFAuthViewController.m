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
    

    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSHTTPCookie *cookie;
    
    NSString *domain = [NSString stringWithFormat:@"identity.%@",self.environment];
    for(cookie in [storage cookies])
    {
        if([cookie.domain isEqualToString:domain] || [cookie.name isEqualToString:@"lfsp-profile"]){
            NSLog(@"cookie is :%@", cookie);
            [storage deleteCookie:cookie];
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];  
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
        if([cookie.name isEqualToString:@"lfsp-profile"] && cookie.value.length>0){
            NSLog(@"cookie is :%@", cookie);
            
            [self dismissViewControllerAnimated:YES completion:^{
                if([self.delegate respondsToSelector:@selector(didReceiveLFAuthToken:)]){
                    [self.delegate didReceiveLFAuthToken:cookie.value];
                }
            }];
            break;
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

-(void)failAuth{
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        if([self.delegate respondsToSelector:@selector(didFailLFRequest)]){
            [self.delegate didFailLFRequest];
        }
    }];
}

@end