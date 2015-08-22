//
//  LocationEngine.h
//  phonebook
//
//  Created by zhang da on 10-10-30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import <CoreLocation/CoreLocation.h>

extern NSString * const LocationUpdateSucceededNotification;
extern NSString * const LocationUpdateFailedNotification;

typedef enum {
	LocationEngineUpdating,
	LocationEngineTimeout,
	LocationEngineError,
	LocationEngineSuccess,
	LocationEngineEnd
} LocationEngineStates;


@interface LocationManager : NSObject < CLLocationManagerDelegate> {
	LocationEngineStates currentSta;
    CLLocationManager *locationManager;
    NSMutableArray *locationMeasurements;
    
    CLLocation *bestLocation;
    double latitude, longitude;
}

@property (nonatomic ) LocationEngineStates currentSta;
@property (nonatomic, retain) NSMutableArray *locationMeasurements;
@property (nonatomic, retain) CLLocation *bestLocation;

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

+ (LocationManager *)me;

- (void)start;
- (void)reset;
- (void)stop;
- (BOOL)locationExpired;

- (void)getLocationDescFor:(CLLocation *)location;
- (double)metersFormPositonWithLatitude:(double)latitude1 longitude:(double)longitude1
                 toPositionWithLatitude:(double)latitude2 longitude:(double)longitude2;


@end

