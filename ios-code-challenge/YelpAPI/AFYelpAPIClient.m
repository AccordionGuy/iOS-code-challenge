//
//  AFYelpAPIClient.m
//  ios-code-challenge
//
//  Created by Dustin Lange on 1/20/18.
//  Copyright © 2018 Dustin Lange. All rights reserved.
//

#import "AFYelpAPIClient.h"
#import "AFOAuth2Manager.h"
#import "Secrets.h"

/**
 
SECURITY NOTICE
As a security measure, passwords, API keys and other sensitive information for accessing systems are stored
in Secrets.h. In a non-test scenario application, Secrets.h would NOT be tracked with regular code files,
but in a limited-access repository.
 
 */
// static NSString *const kYelpAPIKey = @""; *** See Secrets.h for this value ***

static NSString *const kYelpAPIBaseURL = @"https://api.yelp.com/v3/";

@interface AFYelpAPIClient()

@property (nonatomic, strong) AFOAuthCredential *credentials;
    
@end

@implementation AFYelpAPIClient

+ (AFYelpAPIClient *)sharedClient
{
    static AFYelpAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFYelpAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kYelpAPIBaseURL]];
    });
    
    return _sharedClient;
}
    
- (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(id)parameters progress:(void (^)(NSProgress * _Nonnull))downloadProgress success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
{
    [self.requestSerializer setAuthorizationHeaderFieldWithCredential:self.credentials];
    
    return [super GET:URLString
           parameters:parameters
             progress:downloadProgress
              success:success
              failure:failure];
}
    
#pragma mark - Properties
- (AFOAuthCredential *)credentials
{
    if(_credentials == nil) {
        _credentials = [AFOAuthCredential credentialWithOAuthToken:kYelpAPIKey tokenType:@"bearer"];
    }
    
    return _credentials;
}
    
@end
