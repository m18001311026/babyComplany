#import <Foundation/Foundation.h>


@interface Contact : NSObject

@property (nonatomic, retain) NSString *pinyin;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *phone;

@end


typedef void ( ^FetchedCallback )(bool succeeded, NSArray *contacts);


@interface AddressBookManager : NSObject {

}

+ (AddressBookManager *)me;
- (void)fetchContacts:(FetchedCallback)block;

@end
