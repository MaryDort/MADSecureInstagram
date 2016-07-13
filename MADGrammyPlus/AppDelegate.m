//
//  AppDelegate.m
//  MADGrammyPlus
//
//  Created by Mariia Cherniuk on 11.07.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "AppDelegate.h"
#import "NXOAuth2.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[NXOAuth2AccountStore sharedStore] setClientID:@"2226b6a1a3d74ed5819ff157be16c1b6"
                                             secret:@"eb6d6d5d7d6c483f9d322c668b6b4fd3"
                                   authorizationURL:[NSURL URLWithString:@"https://api.instagram.com/oauth/authorize"]
                                           tokenURL:[NSURL URLWithString:@"https://api.instagram.com/oauth/access_token"]
                                        redirectURL:[NSURL URLWithString:@"scheme://thing.com"]
                                     forAccountType:@"Instagram"];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options {
    NSLog(@"url = %@", url);
    
    return [[NXOAuth2AccountStore sharedStore] handleRedirectURL:url];
}

@end
