//
//  PropertyDescription.m
//  ETRSimpleORM
//
//  Created by Matthew Brochstein on 1/31/13.
//  Copyright (c) 2013 Expand The Room. All rights reserved.
//

#import "PropertyDescription.h"

@interface PropertyDescription ()

@property (nonatomic, assign) ObjectiveCPropertyAtomicity internalAtomicity;
@property (nonatomic, strong) NSString *attributesDescriptionString;
@property (nonatomic, strong) NSString *typeCharacter;

- (void)inferTypeFromAttributeDescription;
- (NSString *)objectTypeFromAttributeString;

@end


@implementation PropertyDescription

+ (id)propertyDescriptionForProperty:(NSString *)propertyName
                         reflectName:(NSString *)reflectName
                             inClass:(Class)c {
    objc_property_t property = class_getProperty(c, [propertyName cStringUsingEncoding:NSUTF8StringEncoding]);
    return [[[[self class] alloc] initWithProperty:property reflectName:reflectName] autorelease];
}

- (id)initWithProperty:(objc_property_t)property reflectName:(NSString *)reflectName {
    const char *attributes = property_getAttributes(property);
    const char *propertyName = property_getName(property);
    
    // printf("Property Name:%s, attributes=%s\n", propertyName, attributes);

    self = [super init];
    if (self) {
        
        self.name = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        self.reflectName = reflectName;
        self.attributesDescriptionString = [NSString stringWithCString:attributes encoding:NSUTF8StringEncoding];
        
        [self inferTypeFromAttributeDescription];

    }
    return self;
    
}

- (void)dealloc {
    self.typeCharacter = nil;
    self.objectClass = nil;
    self.name = nil;
    self.reflectName = nil;
    
    [super dealloc];
}

- (void)inferTypeFromAttributeDescription {
    self.type = UNKNOWN;
    if ([self.attributesDescriptionString rangeOfString:@"@"].location != NSNotFound) {
        self.type = NSOBJECT;
        // Parse out the class and assign it
        self.objectClass = [self objectTypeFromAttributeString];
    } else {
        // Get the second character
        NSString *typeCharacter = [self.attributesDescriptionString substringWithRange:NSMakeRange(1, 1)];
        self.typeCharacter = typeCharacter;
        
        // Handle the primative types
        if ([typeCharacter isEqualToString:@"i"]) {
            self.type = INT;
        } else if ([typeCharacter isEqualToString:@"I"]) {
            self.type = UNINT;
        } else if ([typeCharacter isEqualToString:@"c"]) {
            self.type = CHAR;
        } else if ([typeCharacter isEqualToString:@"C"]) {
            self.type = UNCHAR;
        } else if ([typeCharacter isEqualToString:@"l"]) {
            self.type = LONG;
        } else if ([typeCharacter isEqualToString:@"L"]) {
            self.type = UNLONG;
        } else if ([typeCharacter isEqualToString:@"q"]) {
            self.type = LONGLONG;
        } else if ([typeCharacter isEqualToString:@"Q"]) {
            self.type = UNLONGLONG;
        } else if ([typeCharacter isEqualToString:@"s"]) {
            self.type = SHORT;
        } else if ([typeCharacter isEqualToString:@"S"]) {
            self.type = UNSHORT;
        } else if ([typeCharacter isEqualToString:@"d"]) {
            self.type = DOUBLE;
        } else if ([typeCharacter isEqualToString:@"f"]) {
            self.type = FLOAT;
        } else if ([typeCharacter isEqualToString:@"{"]) {
            self.type = STRUCT;
        } else if ([typeCharacter isEqualToString:@"B"]) {
            self.type = BOOLEAN;
        }
    }
}


#pragma mark - Private Methods
- (NSString *)objectTypeFromAttributeString {
    
    // Create a scanner for the string
    NSScanner *scanner = [NSScanner scannerWithString:self.attributesDescriptionString];
    [scanner scanUpToString:@"@" intoString:NULL];
    if (scanner.isAtEnd) {
        return nil;
    }
    
    // Eat the @
    [scanner scanString:@"@" intoString:NULL];
    if (scanner.isAtEnd) {
        return @"id";
    }
    
    // Eat the "
    [scanner scanString:@"\"" intoString:NULL];
    
    // Grab the type
    NSString *type = nil;
    [scanner scanUpToString:@"\"" intoString:&type];
    
    // Return
    return type;
    
}


#pragma mark - Internal Properties
- (BOOL)isPointer {
    return ([self.attributesDescriptionString rangeOfString:@"^"].location != NSNotFound);
}

- (BOOL)isPrimative {
    return (self.type != NSOBJECT);
}

- (BOOL)isObject {
    return (self.type == NSOBJECT);
}

- (BOOL)isReadonly {
    return ([self.attributesDescriptionString rangeOfString:@",R"].location != NSNotFound);
}

- (NSString *)description {
    
    NSMutableString *description = [NSMutableString stringWithString:self.name];
    [description appendString:@": "];
    
    if (!self.isPrimative) {
        [description appendFormat:@"Object of type %@", self.objectClass];
    } else {
        [description appendString:@"Primative of type unknown"];
    }
    
    return description;
    
}

- (const char *)getterImplementationTypeList {
    return [[NSString stringWithFormat:@"%@@:", self.typeCharacter] cStringUsingEncoding:NSUTF8StringEncoding];
}

- (const char *)setterImplementationTypeList {
    return [[NSString stringWithFormat:@"v@:%@", self.typeCharacter] cStringUsingEncoding:NSUTF8StringEncoding];
}

@end
