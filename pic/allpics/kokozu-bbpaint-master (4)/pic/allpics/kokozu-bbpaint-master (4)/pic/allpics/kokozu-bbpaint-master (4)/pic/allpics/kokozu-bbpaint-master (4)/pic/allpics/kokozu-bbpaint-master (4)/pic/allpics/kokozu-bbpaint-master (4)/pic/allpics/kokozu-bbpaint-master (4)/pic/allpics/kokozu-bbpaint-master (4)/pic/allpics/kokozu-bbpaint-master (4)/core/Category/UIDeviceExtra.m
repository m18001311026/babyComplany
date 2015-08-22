//
//  UIDeviceExtra.m
//  phonebook
//
//  Created by zhang da on 11-1-24.
//  Copyright 2011 alfaromeo.dev. All rights reserved.
//

#import "UIDeviceExtra.h"
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@implementation UIDevice(Hardware)

- (NSString *)platform {
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = (char *)malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}

- (BOOL)hasRetinaDisplay {
    NSString *platform = [self platform];
    BOOL ret = YES;
    if ([platform isEqualToString:@"iPhone1,1"]) {
        ret = NO;
    }
    else if ([platform isEqualToString:@"iPhone1,2"]) {
        ret = NO;
    }    
    else if ([platform isEqualToString:@"iPhone2,1"]) {
        ret = NO;
    }    
    else if ([platform isEqualToString:@"iPod1,1"]) {
        ret = NO; 
    }     
    else if ([platform isEqualToString:@"iPod2,1"]) {
        ret = NO;
    }     
    else if ([platform isEqualToString:@"iPod3,1"]) {
        ret = NO;
    }
    else if ([platform isEqualToString:@"i386"]) {
        ret = NO;
    }
    
    return ret;
}

- (BOOL)hasMultitasking {
    if ([self respondsToSelector:@selector(isMultitaskingSupported)]) {
        return [self isMultitaskingSupported];
    }
    return NO;
}

- (BOOL)hasCamera {
    BOOL ret = NO;
    // check camera availability
    return ret;
}

- (BOOL)under3gs {
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone1,1"])
        return YES;
    if ([platform isEqualToString:@"iPhone1,2"])
        return YES;
    if ([platform isEqualToString:@"iPod1,1"])
        return YES;
    if ([platform isEqualToString:@"iPod2,1"])
        return YES;
    return NO;
}

- (NSString *)platformString {
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone1,1"])
        return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])
        return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])
        return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])
        return @"iPhone 4";
    if ([platform isEqualToString:@"iPod1,1"])
        return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])
        return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])
        return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])
        return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])
        return @"iPad";
    if ([platform isEqualToString:@"i386"])
        return @"Simulator";
    return platform;
}

- (BOOL)isIpad {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
#endif
    return NO;
}

@end
