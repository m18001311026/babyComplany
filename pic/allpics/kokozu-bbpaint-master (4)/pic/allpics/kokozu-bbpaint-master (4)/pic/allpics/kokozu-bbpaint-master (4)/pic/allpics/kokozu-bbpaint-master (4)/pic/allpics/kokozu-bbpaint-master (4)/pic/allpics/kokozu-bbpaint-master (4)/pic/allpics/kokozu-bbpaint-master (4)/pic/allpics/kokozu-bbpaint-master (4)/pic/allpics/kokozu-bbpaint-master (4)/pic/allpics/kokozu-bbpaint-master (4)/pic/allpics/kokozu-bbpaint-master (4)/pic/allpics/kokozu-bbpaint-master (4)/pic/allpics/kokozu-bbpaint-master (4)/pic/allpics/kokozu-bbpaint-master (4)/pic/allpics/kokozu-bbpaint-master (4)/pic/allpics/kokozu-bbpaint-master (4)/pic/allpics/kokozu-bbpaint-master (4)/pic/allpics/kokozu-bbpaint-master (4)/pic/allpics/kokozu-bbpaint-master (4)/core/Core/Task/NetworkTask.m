//
//  NetworkTask.m
//  alfaromeo.dev
//
//  Created by zhang da on 11-5-16.
//  Copyright 2011 alfaromeo.dev. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>

#import "NetworkTask.h"
#import "TaskQueue.h"
#import "Constants.h"

#import "NSStringExtra.h"
#import "RequestParameter.h"

@interface NetworkTask ()

@property (nonatomic, copy) NSHTTPURLResponse *response;
@property (nonatomic, retain) NSString *url;
@property (assign) RequestMethod reqMethod;

@end


@implementation NetworkTask
#pragma mark * Properties
+ (BOOL)automaticallyNotifiesObserversOfAcceptableStatusCodes {
    return NO;
}

+ (BOOL)automaticallyNotifiesObserversOfAcceptableContentTypes {
    return NO;
}


#pragma mark Request sending methods
- (id)init {
    self = [super init];
    if (self) {
        self.impl = self;
        _reqParams = [[NSMutableArray alloc] init];
        _respData = [[NSMutableData alloc] initWithCapacity:0];
    }
    return self;
}

- (id)initWithUrl:(NSString *)url method:(RequestMethod)method delegate:(id<NetworkTaskDelegate>)delegate {
    self = [super init];
    if (self) {
        self.impl = self;
        self.delegate = delegate;
        self.url = url;
        self.reqMethod = method;
        
        _reqParams = [[NSMutableArray alloc] init];
        _respData = [[NSMutableData alloc] initWithCapacity:0];
    }
    return self;
}

- (void)dealloc {
	[_reqParams release];
    [_reqHeaders release];
    [_respData release];

    self.url = nil;
    self.response = nil;
    
	[super dealloc];
}


#pragma mark Utility
- (void)addHeader:(NSString *)key value:(NSString *)value {
    if (!_reqHeaders) {
        _reqHeaders = [[NSMutableDictionary alloc] init];
    }
    [_reqHeaders setObject:value forKey:key];
}

- (void)addParameter:(NSString *)key value:(NSString *)value {
    if ( value && key ) {
        [self addParameter:key value:value fileName:nil gbk:NO];
    }
    if ( !value && key ) {
        [self addParameter:key value:@""];
    }
}

- (void)addParameter:(NSString *)key value:(NSData *)value fileName:(NSString *)filename {
    if (value && key && filename) {
        [self addParameter:key value:value fileName:filename gbk:NO];
        _isFormRequest = YES;
    }
}

- (void)addParameter:(NSString *)key value:(id)value fileName:(NSString *)filename gbk:(BOOL)isGBK {
    if ( value && key ) {
        NSStringEncoding encoding = isGBK?
        CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000): NSUTF8StringEncoding;

        RequestParameter *newPara = nil;
        if ([value isKindOfClass:[NSString class]]) {
            newPara = [[RequestParameter alloc] initWithName:key value:value enc:encoding];
        } else if ([value isKindOfClass:[NSData class]]) {
            newPara = [[RequestParameter alloc] initWithName:key data:value fileName:filename];
        }

        if (newPara) {
            if ([_reqParams count]) {
                for (int i = 0; i < [_reqParams count]; i++) {
                    RequestParameter *para = [_reqParams objectAtIndex:i];
                    if ([key compare:para.name] == NSOrderedAscending) {
                        [_reqParams insertObject:newPara atIndex:i];
                        [newPara release];
                        return;
                    }
                }
            }
            [_reqParams addObject:newPara];
            [newPara release];
        }
    }
}

- (void)build:(NSMutableURLRequest *)request {
    //set method
    switch (self.reqMethod) {
        case GET: [request setHTTPMethod:@"GET"]; break;
        case POST: [request setHTTPMethod:@"POST"]; break;
        case PUT: [request setHTTPMethod:@"PUT"]; break;
        case DELETE: [request setHTTPMethod:@"DELETE"]; break;
        default: break;
    }
    
    //set header
    for (id akey in [_reqHeaders allKeys]) {
        [request setValue:[_reqHeaders objectForKey:akey] forHTTPHeaderField:akey];
    }
    
    //set params
    NSMutableString *encodedParams = [[NSMutableString alloc] initWithCapacity:256];
    for (RequestParameter *param in _reqParams) {
        DLog(@"params:%@", [param description]);
        if (!param.valueIsData) {
            [encodedParams appendString:[param URLEncodedNameValuePair]];
            [encodedParams appendString:@"&"];
        }
    }
	
    if ([[request HTTPMethod] isEqualToString:@"GET"]
        || [[request HTTPMethod] isEqualToString:@"DELETE"]) {
        if ([encodedParams length]) {
            NSString *urlStr = [NSString stringWithFormat:@"%@?%@", [[request URL] absoluteString], encodedParams];
            NSURL *tmpUrl = [[NSURL alloc] initWithString:urlStr];
            [request setURL:tmpUrl];
            [tmpUrl release];
        }
        
        DLog(@"\n\n########request:%@#########\n|url: %@\n|paras: %@\n|header: %@\n############################\n\n", 
             self.taskId, [request URL], encodedParams, [request allHTTPHeaderFields]);
        
    } else {
        // POST, PUT
        if (!_isFormRequest)  {
            NSData *postbody = [encodedParams dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:postbody];
            [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postbody length]]
           forHTTPHeaderField:@"Content-Length"];
        } else {
            NSMutableString *debugBody = [[NSMutableString alloc] init];
            NSMutableData *body = [[NSMutableData alloc] init];

            NSString *stringBoundary = [NSString stringWithFormat:@"0xKhTmLbOuNdArY"];
            

            NSString *tmpString = [NSString stringWithFormat:@"--%@\r\n", stringBoundary];
            [debugBody appendString:tmpString];
            [body appendData:[tmpString dataUsingEncoding:NSUTF8StringEncoding]];
            
            // Adds post data
            NSString *seperatorBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary];
            int i = 0;
            for (RequestParameter *param in _reqParams) {
                if (param.valueIsData) {
                    tmpString = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", param.name, param.fileName];
                    
                    [debugBody appendString:tmpString];
                    [body appendData:[tmpString dataUsingEncoding:NSUTF8StringEncoding]];

                    
                    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                                            (CFStringRef)[param.fileName pathExtension],
                                                                            NULL);
                    if (UTI) {
                        CFStringRef mime = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
                        CFRelease(UTI);

                        tmpString = [NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", (NSString *)mime];
                        CFRelease(mime);

                        [debugBody appendString:tmpString];
                        [body appendData:[tmpString dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                    
                    [body appendData:param.value];
                    [debugBody appendString:@"here is form data"];

                } else {
                    tmpString = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param.name];
                    [debugBody appendString:tmpString];
                    [body appendData:[tmpString dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    tmpString = param.value;
                    [debugBody appendString:tmpString];
                    [body appendData:[tmpString dataUsingEncoding:NSUTF8StringEncoding]];
                }
                
                if (++i < [_reqParams count]) {
                    tmpString = seperatorBoundary;
                    [debugBody appendString:tmpString];
                    [body appendData:[tmpString dataUsingEncoding:NSUTF8StringEncoding]];
                } else {
                    tmpString = [NSString stringWithFormat:@"\r\n--%@--\r\n", stringBoundary];

                    [debugBody appendString:tmpString];
                    [body appendData:[tmpString dataUsingEncoding:NSUTF8StringEncoding]];
                }
            }
            
            [request setHTTPBody:body];
            [body release];

            [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
            [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary] forHTTPHeaderField: @"Content-Type"];
            
            DLog(@"####\nbody:\n%@####", debugBody);
            [debugBody release];
			
        }
        DLog(@"\n\n########request:%@#########\n|url: %@\n|paras: %@\n|header: %@\n############################\n\n",
             self.taskId, [request URL], encodedParams, [request allHTTPHeaderFields]);
    }
    
    [encodedParams release];
}


#pragma mark nsoperation utility
- (void)operationWillStart {
    [self.delegate makeRequest];
    
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc]
                                       initWithURL:[NSURL URLWithString:self.url]
                                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                                       timeoutInterval:kHttpRequestTimeout];
    [theRequest setHTTPShouldHandleCookies:NO];
    
    
    [self build:theRequest];
    
    _reqConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:NO];
    [theRequest release];
    
    [_reqConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_reqConnection start];
}

- (void)operationWillFinish {
    [_reqConnection cancel];
    [_reqConnection release];
    _reqConnection = nil;
}

- (void)operationWillCancel {}

- (void)finishWithStatus:(int)status {
    [super finishWithError:nil];
    [self.delegate handleResponse:_respData status:status];
}


#pragma mark NSURLConnection delegate
- (NSURLRequest *)connection:(NSURLConnection *)connection
             willSendRequest:(NSURLRequest *)request 
            redirectResponse:(NSURLResponse *)response {
    
    assert( (response == nil) || [response isKindOfClass:[NSHTTPURLResponse class]] );
    self.response = (NSHTTPURLResponse *)response;
    return request;
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_respData setLength:0];
    self.response = (NSHTTPURLResponse *)response;
    if (self.response.statusCode == 200) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestSucceededResponse)]) {
            [self.delegate requestSucceededResponse];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (data != nil) {
        [_respData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self finishWithStatus:(int)self.response.statusCode];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    DLog(@"error :%@", error);
    [self finishWithStatus:0];
}

- (BOOL)connection:(NSURLConnection *)connection 
canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    if([[protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust]){
        DLog(@"Server Trust will be checked");
        return YES;
    }
    return NO;
}

- (void)connection:(NSURLConnection *)connection 
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    SecTrustRef         trustRef = challenge.protectionSpace.serverTrust;
    SecTrustResultType  result = 0;
    NSURLCredential    *credential = nil;
    
    SecTrustEvaluate(trustRef, &result);
    credential = [NSURLCredential credentialForTrust:trustRef];
    if(credential) {
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    }
    else {
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }   
}

- (void)connection:(NSURLConnection *)connection 
   didSendBodyData:(NSInteger)written 
 totalBytesWritten:(NSInteger)totalWritten 
totalBytesExpectedToWrite:(NSInteger)totalExpectedToWrite {
    //TODO: every 5% make a callback
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(uploadBytesWritten:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.delegate
         uploadBytesWritten:written totalBytesWritten:totalWritten totalBytesExpectedToWrite:totalExpectedToWrite];
    }
}

@end
