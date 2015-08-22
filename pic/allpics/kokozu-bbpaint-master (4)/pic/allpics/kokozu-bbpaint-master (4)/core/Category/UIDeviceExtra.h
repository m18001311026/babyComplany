//
//  UIDeviceExtra.h
//  phonebook
//
//  Created by zhang da on 11-1-24.
//  Copyright 2011 alfaromeo.dev. All rights reserved.
//

#include <sys/types.h>
#include <sys/sysctl.h>

@interface UIDevice(Hardware)

- (NSString *) platform;

- (BOOL)hasRetinaDisplay;

- (BOOL)hasMultitasking;

- (BOOL)hasCamera;

- (NSString *)platformString;

- (BOOL)under3gs;

- (BOOL)isIpad;

@end

