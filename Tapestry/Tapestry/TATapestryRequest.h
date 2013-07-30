//
//  TATapestryRequest.h
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 30.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
  A mutable class for building requests that are sent with @see TATapestryClient.  Building a request adds parameters to the HTTP query string that will be sent to Tapestry Web API.

  An example of building a request:
 
 	TATapestryRequest* request = [TATapestryRequest request];
    [request addAudiences:@"aud1", @"aud2", @"aud3"];
    [request addData:@"blue" forKey:@"color"];
    [request addData:@"ford" forKey:@"ford"];
    [request listDevices];
    [request depth:2];
 */

@interface TATapestryRequest : NSObject

+ (TATapestryRequest*) request;
- (void)addData:(NSString*)data forKey:(NSString*)key;
- (void)addAudiences:(NSString *)audiences, ...;
- (void)listDevices;
- (void)setDepth:(NSInteger)depth;


@end