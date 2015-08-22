//
//  PropertyDescription.h
//  ETRSimpleORM
//
//  Created by Matthew Brochstein on 1/31/13.
//  Copyright (c) 2013 Expand The Room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef enum {
    UNKNOWN = 0,
    NSOBJECT,
    
    CHAR, UNCHAR,
    INT, UNINT,
    SHORT, UNSHORT,
    LONG, UNLONG,
    LONGLONG, UNLONGLONG,
    FLOAT,
    DOUBLE,
    BOOLEAN,
    CSTRING,
    SELECTOR,
    ARRAY,
    STRUCT,
    
    VOID // We should never see this
} ObjectiveCPropertyType;

typedef enum {
    Atomic = 0,
    Nonatomic
} ObjectiveCPropertyAtomicity;

@interface PropertyDescription : NSObject

@property (nonatomic, assign) ObjectiveCPropertyType type;
@property (nonatomic, assign) ObjectiveCPropertyAtomicity atomicity;
@property (nonatomic, retain) NSString *objectClass;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *reflectName;

@property (nonatomic, readonly) const char *getterImplementationTypeList;
@property (nonatomic, readonly) const char *setterImplementationTypeList;

+ (id)propertyDescriptionForProperty:(NSString *)propertyName
                         reflectName:(NSString *)reflectName
                             inClass:(Class)c;
- (id)initWithProperty:(objc_property_t)property
           reflectName:(NSString *)reflectName;

- (BOOL)isPointer;
- (BOOL)isPrimative;
- (BOOL)isObject;
- (BOOL)isReadonly;

@end
