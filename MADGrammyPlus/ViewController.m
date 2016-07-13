//
//  ViewController.m
//  MADGrammyPlus
//
//  Created by Mariia Cherniuk on 11.07.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "ViewController.h"
#import "NXOAuth2.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _logoutButton.enabled = NO;
    _refreshButton.enabled = NO;
    _loginButton.enabled = YES;
}

- (IBAction)loginButtonPressed:(UIButton *)sender {
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:@"Instagram"];
    _logoutButton.enabled = YES;
    _refreshButton.enabled = YES;
    _loginButton.enabled = NO;
}

- (IBAction)logoutButtonPressed:(UIButton *)sender {
    NXOAuth2AccountStore *store = [NXOAuth2AccountStore sharedStore];
    NSArray *instagramAccaunts = [store accountsWithAccountType:@"Instagram"];
    
    for (NXOAuth2Account *accaunt in instagramAccaunts) {
        [store removeAccount:accaunt];
    }
    
    _logoutButton.enabled = NO;
    _refreshButton.enabled = NO;
    _loginButton.enabled = YES;
}

- (IBAction)refreshButtonPressed:(UIButton *)sender {
    NSArray *instagramAccaunts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"Instagram"];
    
    if (instagramAccaunts.count == 0) {
        NSLog(@"Warning: %ld Instagram accounts logged in", (long)instagramAccaunts.count);
        return;
    }
    
    NXOAuth2Account *accaunt = instagramAccaunts[0];
    NSString *token = accaunt.accessToken.accessToken;
    NSString *strURL = [@"https://api.instagram.com/v1/users/self/media/recent/?access_token=" stringByAppendingString:token];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self checkError:error statusCode:[(NSHTTPURLResponse *)response statusCode]];
        
//        Check for JSON error
        NSError *err;
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if (!results) {
            NSLog(@"Error: Couldn't parse response: %@", err);
            return;
        }
        
        NSString *imageURLstr = results[@"data"][0][@"images"][@"standard_resolution"][@"url"];
        
        [[session dataTaskWithURL:[NSURL URLWithString:imageURLstr] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [self checkError:error statusCode:[(NSHTTPURLResponse *)response statusCode]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _imageView.image = [UIImage imageWithData:data];
            });
        }] resume];
    }] resume];
}

- (void)checkError:(NSError *)error statusCode:(NSInteger)statusCode {
//  Check for network error
    if (error) {
        NSLog(@"Error: Couldn't finish request: %@", error);
        return;
    }
    
//  Check for HTTP error
    if (statusCode < 200 || statusCode >= 300) {
        NSLog(@"Error: Got status code %ld", (long)statusCode);
        return;
    }
}

@end
