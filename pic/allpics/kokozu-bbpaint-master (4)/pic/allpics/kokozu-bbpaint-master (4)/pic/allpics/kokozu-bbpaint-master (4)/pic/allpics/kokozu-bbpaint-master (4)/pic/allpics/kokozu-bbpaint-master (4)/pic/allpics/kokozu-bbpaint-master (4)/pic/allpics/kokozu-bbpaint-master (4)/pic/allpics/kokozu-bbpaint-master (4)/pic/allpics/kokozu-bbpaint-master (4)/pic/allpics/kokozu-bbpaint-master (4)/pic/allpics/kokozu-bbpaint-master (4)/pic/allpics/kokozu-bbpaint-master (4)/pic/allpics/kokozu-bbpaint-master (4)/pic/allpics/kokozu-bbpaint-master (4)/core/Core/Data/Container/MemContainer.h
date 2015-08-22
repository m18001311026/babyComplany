//
//  MemContainer.h
//  baby
//
//  Created by zhang da on 14-2-5.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Container.h"

@interface MemContainer : NSObject <Container> {

}


@property (nonatomic, retain) NSDictionary *holder;

+ (MemContainer *)me;

@end
