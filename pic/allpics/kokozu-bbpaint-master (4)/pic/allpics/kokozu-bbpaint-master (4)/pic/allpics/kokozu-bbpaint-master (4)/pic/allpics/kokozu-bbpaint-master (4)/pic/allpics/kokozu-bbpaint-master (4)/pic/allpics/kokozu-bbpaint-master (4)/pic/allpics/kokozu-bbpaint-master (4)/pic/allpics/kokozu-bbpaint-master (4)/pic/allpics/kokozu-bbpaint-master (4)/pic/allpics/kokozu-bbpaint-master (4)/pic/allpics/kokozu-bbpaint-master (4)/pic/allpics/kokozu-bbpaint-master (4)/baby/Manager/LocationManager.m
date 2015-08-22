//
//  LocationManager
//  phonebook
//
//  Created by zhang da on 10-10-30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LocationManager.h"

#define LOC_FAILED_ALERT [[NSUserDefaults standardUserDefaults] valueForKey:@"loc_failed"]
#define LOC_FAILED_ALERT_WRITE(updateTime) [[NSUserDefaults standardUserDefaults] setValue:updateTime forKey:@"loc_failed"]

#define kDesiredAccuracy 500 //:meter
#define KLocationAge 60 //:s
#define kTimeout 20 //:s

NSString * const LocationUpdateSucceededNotification = @"LocationUpdateSucceededNotification";
NSString * const LocationUpdateFailedNotification = @"LocationUpdateFailedNotification";

@interface LocationManager ()


- (void)stop:(NSNumber *)state error:(NSError *)error;

@end


@implementation LocationManager

@synthesize currentSta;
@synthesize locationMeasurements, bestLocation;
@synthesize latitude, longitude;

static LocationManager * _me = nil;

+ (LocationManager *)me {
	@synchronized(self) {
        if ( _me == nil ) {
            _me = [[LocationManager alloc] init];
        }
        return _me;
    }
}

- (id)init {
	self = [super init];
    if (self) {
        locationMeasurements = [[NSMutableArray alloc] init];
        locationManager = [[CLLocationManager alloc] init];
    }
	return self;
}

- (void)dealloc {
    [locationManager release];
    [locationMeasurements release];
    [bestLocation release];
    [super dealloc];
}

- (double)latitude {
    return bestLocation.coordinate.latitude;
}

- (double)longitude {
    return bestLocation.coordinate.longitude;
}

- (void)start {
	//if (self.currentSta == LocationEngineUpdating) return;
	self.currentSta = LocationEngineUpdating;
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kDesiredAccuracy;
	[locationManager startUpdatingLocation];
    
	[self performSelector:@selector(stop:error:)
               withObject:[NSNumber numberWithInt:LocationEngineTimeout] afterDelay:kTimeout];
}

- (void)reset {
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(stop:error:)
                                               object:[NSNumber numberWithInt:LocationEngineTimeout]];
	self.currentSta = LocationEngineEnd;
	[locationMeasurements removeAllObjects];
    locationManager.delegate = nil;
	[locationManager stopUpdatingLocation];
}

- (void)stop {
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(stop:error:)
                                               object:[NSNumber numberWithInt:LocationEngineTimeout]];
	[locationManager stopUpdatingLocation];
}

- (void)stop:(NSNumber *)state error:(NSError *)error {
	self.currentSta = (LocationEngineStates)[state intValue];
    
	if ( currentSta == LocationEngineTimeout && bestLocation )
		self.currentSta = LocationEngineSuccess;
	
	if (self.currentSta == LocationEngineTimeout && !bestLocation) {
		NSNotification *n = [NSNotification notificationWithName:LocationUpdateFailedNotification
                                                          object:nil
                                                        userInfo:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotification:n];
        });
	} else if ( currentSta == LocationEngineSuccess ) {
		NSNotification *n = [NSNotification notificationWithName:LocationUpdateSucceededNotification
                                                          object:nil
                                                        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  bestLocation.timestamp, @"updateTime",
                                                                  bestLocation, @"location", nil]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotification:n];
        });

	} else if ( currentSta == LocationEngineError ){
        NSNotification *n = [NSNotification notificationWithName:LocationUpdateFailedNotification
                                                          object:nil
                                                        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error,@"error",nil]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotification:n];
        });
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(stop:error:)
                                               object:[NSNumber numberWithInt:LocationEngineTimeout]];
    
	[locationManager stopUpdatingLocation];
	[locationMeasurements removeAllObjects];
    locationManager.delegate = nil;
}

- (BOOL)locationExpired {
    if (!bestLocation
        || [bestLocation.timestamp timeIntervalSinceNow] < -3600
        || self.latitude == 0
        || self.longitude == 0) {
        return YES;
    }
    return NO;
}



#pragma mark utility
- (double)metersFormPositonWithLatitude:(double)latitude1 longitude:(double)longitude1
                 toPositionWithLatitude:(double)latitude2 longitude:(double)longitude2 {
    return sqrtf( powf( (latitude1 - latitude2) * 111000, 2)
                 + powf( (longitude1- longitude2) * 111000 * cosf(longitude1), 2) );
}



#pragma mark locationManager delegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
    
    [locationMeasurements addObject:newLocation];
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    DLog(@"new location arrived");
    
    if (locationAge > KLocationAge || newLocation.horizontalAccuracy < 0) return;
    
    if (bestLocation == nil || bestLocation.horizontalAccuracy >= newLocation.horizontalAccuracy) {
        DLog(@"post location get notification");
        
        self.bestLocation = newLocation;
        [self getLocationDescFor:self.bestLocation];
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            [self stop:[NSNumber numberWithInt:LocationEngineSuccess] error:nil];
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stop:error:) object:nil];
            
        }
        //NSString *bestlatitude = [NSString stringWithFormat:@"%f",self.bestLocation.coordinate.latitude];
        //NSString *bestlongitude = [NSString stringWithFormat:@"%f",self.bestLocation.coordinate.longitude];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self stop:[NSNumber numberWithInt:LocationEngineError] error:error];
    
    NSDate *updateTime = LOC_FAILED_ALERT;
    
    /*
     kCLErrorLocationUnknown  = 0,         // location is currently unknown, but CL will keep trying
     
     kCLErrorNetwork,                      // general, network-related error
     kCLErrorHeadingFailure,               // heading could not be determined
     
     kCLErrorDenied,                       // CL access has been denied (eg, user declined location use)
     kCLErrorRegionMonitoringDenied,       // Location region monitoring has been denied by the user
     
     kCLErrorRegionMonitoringFailure,      // A registered region cannot be monitored
     kCLErrorRegionMonitoringSetupDelayed, // CL could not immediately initialize region monitoring
     kCLErrorRegionMonitoringResponseDelayed, // While events for this fence will be delivered, delivery will not occur immediately
     kCLErrorGeocodeFoundNoResult,         // A geocode request yielded no result
     kCLErrorGeocodeFoundPartialResult,    // A geocode request yielded a partial result
     kCLErrorGeocodeCanceled
     */
    
    if (!updateTime || [updateTime timeIntervalSinceNow] < -3600) {
        LOC_FAILED_ALERT_WRITE([NSDate date]);
        
        NSInteger errorCode = [error code];
        
        NSString *errorDesc = nil;
        if (error && ( errorCode == kCLErrorDenied || errorCode == kCLErrorRegionMonitoringDenied ) ) {
            errorDesc = @"您还没有开启定位功能";
        } else {
            errorDesc = @"暂时无法确定您的位置";
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:errorDesc
                                                           delegate:nil
                                                  cancelButtonTitle:@"好的"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
}





#pragma mark GPS relate delegate
- (void)getLocationDescFor:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error) {
        if (array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            NSString *country = placemark.ISOcountryCode;
            NSString *city = placemark.locality;
            
            NSLog(@"%@-%@", country, city);
        }
    }];
}

@end

