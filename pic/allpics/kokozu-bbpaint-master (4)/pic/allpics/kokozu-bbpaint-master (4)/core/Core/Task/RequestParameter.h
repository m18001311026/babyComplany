//
//  RequestParameter.h
//  TestTaskQueue
//
//  Created by zhang da on 11-5-16.
//  Copyright 2011 alfaromeo.dev. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RequestParameter : NSObject {

}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) id value;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) NSStringEncoding enc;
@property (nonatomic, assign) BOOL valueIsData;

- (id)initWithName:(NSString *)aName value:(NSString *)aValue enc:(NSStringEncoding)enc;
- (id)initWithName:(NSString *)aName data:(NSData *)aData fileName:(NSString *)fileName;

- (NSString *)URLEncodedNameValuePair;

@end
