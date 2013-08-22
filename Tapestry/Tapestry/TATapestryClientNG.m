//
//  TATapestryClientNG.m
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 30.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TARequestOperation.h"
#import "TATapadIdentifiers.h"
#import "UIDevice+Hardware.h"
#import "TATapestryClientNG.h"
#import "TAMacros.h"

static NSString* const kTATapestryClientBaseURL = @"http://tapestry.tapad.com/tapestry/1";

@interface TATapestryClientNG ()
@property(nonatomic, copy) NSString* partnerId;
@property(nonatomic, copy) NSString* baseURL;
@property(nonatomic, strong) NSOperationQueue* requestQueue;
@end

@implementation TATapestryClientNG

+ (TATapestryClientNG *)sharedClient
{
    static dispatch_once_t singleton_guard;
    static TATapestryClientNG* sharedClient;
    dispatch_once(&singleton_guard, ^{
        sharedClient = [[self alloc] init];
    });
    return sharedClient;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.baseURL = kTATapestryClientBaseURL;
        self.requestQueue = [[NSOperationQueue alloc] init];
        [self.requestQueue setMaxConcurrentOperationCount:2];
    }
    return self;
}

- (void)setPartnerId:(NSString *)partnerId
{
    _partnerId = partnerId;
}

- (void)setBaseURL:(NSString *)baseURL
{
    _baseURL = baseURL;
}

- (void)setDefaultBaseURL
{
    _baseURL = kTATapestryClientBaseURL;
}

- (void)queueRequest:(TATapestryRequest*)request
{
    [self queueRequest:request withResponseBlock:nil];
}

- (void)queueRequest:(TATapestryRequest*)request withResponseBlock:(TATapestryResponseHandler)handler
{
    // Include all enabled typed device ids.
    NSDictionary* typedIds = [TATapadIdentifiers typedDeviceIDs];
    for (id key in typedIds) {
        [request addTypedId:[typedIds objectForKey:key] forSource:key];
    }

    // If there's a handler, then we want data back.
    if (handler != nil) {
        [request getData];
    }

    // Set the platform parameter, because we don't control the user agent header.
    [request setPlatform:[[UIDevice currentDevice] ta_platform]];
    
    TALog(@"TATapestryClientNG queueRequest %@", request);
    
    TATapestryResponseHandler innerHandler = ^(TATapestryResponse* response, NSError *error, long millis){
        TALog(@"Inner handler: response received for request:\n%@\nresponse:\n%@\nerror:\n%@", request, response, error);
        
        if (error != nil && [NSURLErrorDomain isEqualToString:error.domain]) {
            // TODO Network error. Pause and retry using a time-since-first-failure backoff strategy.
            if (handler != nil)
            {
                // Call response handler
                handler(response, error, 0 /* FIXME */);
            }
        }
        
        else if (handler != nil)
        {
            // Call response handler
            handler(response, error, 0 /* FIXME */);
        }
    };
    
    TARequestOperation* operation = [TARequestOperation operationWithRequest:request andBaseUrl:self.baseURL andHandler:innerHandler];
    [self.requestQueue addOperation:operation];
}

@end
