//
//  ZCAddressBook.m
//  通讯录Demo
//
//  Created by ZhangCheng on 14-4-19.
//  Copyright (c) 2014年 zhangcheng. All rights reserved.
//

#import "AddressBookManager.h"
#import "ChineseToPinyin.h"
#import <AddressBook/AddressBook.h>

@implementation Contact

- (void)dealloc {
    self.pinyin = nil;
    self.name = nil;
    self.phone = nil;
    [super dealloc];
}

- (id)initWithName:(NSString *)name phone:(NSString *)phone {
    if (self = [super init]) {
        self.name = name;
        self.pinyin = [ChineseToPinyin pinyinFromChiniseString:name];
        self.phone = phone;
    }
    return self;
}

@end


static AddressBookManager *instance;

@implementation AddressBookManager


- (id)init {
    if (self=[super init]) {
        
    }
    return self;
}

- (void)dealloc {
    
    [super dealloc];
}

// 单列模式
+ (AddressBookManager*)me{
    @synchronized([AddressBookManager class]) {
        if(!instance) {
            instance = [[AddressBookManager alloc] init];
        }
    }
    return instance;
}

#pragma mark 获取通讯录内容
- (void)fetchContacts:(FetchedCallback)block {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:0];
        
        ABAddressBookRef addressBook ;
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)    {
            addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            //等待同意后向下执行
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)                                                 {                                                     dispatch_semaphore_signal(sema);                                                 });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            dispatch_release(sema);
        } else {
            addressBook = ABAddressBookCreate();
        }
        
        //取得本地所有联系人记录
        CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
        //NSLog(@"-----%d",(int)CFArrayGetCount(results));
        
        if (!results) {
            if (addressBook) {
                CFRelease(addressBook);                
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [UI showAlert:@"通讯录为空或者没有权限读取通讯录"];
                if (block) {
                    block(NO, contacts);
                }
            });
        } else {
            for (int i = 0; i < CFArrayGetCount(results); i++) {
                
                ABRecordRef person = CFArrayGetValueAtIndex(results, i);
                
                CFStringRef showName = ABRecordCopyCompositeName(person);
                CFStringRef first = ABRecordCopyValue(person, kABPersonFirstNameProperty);
                CFStringRef last = ABRecordCopyValue(person, kABPersonLastNameProperty);
                ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
                
                NSString *name = nil, *mobile = nil;
                
                if (showName) {
                    name = (NSString *)showName;
                } else if (first || last) {
                    name = [NSString stringWithFormat:@"%@ %@", first, last];
                }
                
                for (CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
                    //获取电话值
                    NSString *personPhone = (NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                    mobile = [personPhone stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    CFRelease((CFTypeRef)personPhone);
                    
                    mobile = [mobile stringByReplacingOccurrencesOfString:@"+86" withString:@""];
                    mobile = [mobile stringByReplacingOccurrencesOfString:@"(" withString:@""];
                    mobile = [mobile stringByReplacingOccurrencesOfString:@")" withString:@""];
                    mobile = [mobile stringByReplacingOccurrencesOfString:@" " withString:@""];
                }
                
                Contact *user = [[Contact alloc] initWithName:name phone:mobile];
                [contacts addObject:user];
                [user release];
                
                if (showName) CFRelease(showName);
                if (first) CFRelease(first);
                if (last) CFRelease(last);
                if (phones) CFRelease(phones);
            }
            
            CFRelease(results);//new
            CFRelease(addressBook);//new
            
            [contacts sortUsingComparator:^NSComparisonResult(Contact *obj1, Contact *obj2) {
                return [obj1.pinyin compare:obj2.pinyin];
            }];
            
            //        for (Contact *c in contacts) {
            //            NSLog(@"%@,%@", c.pinyin, c.phone);
            //        }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(YES, contacts);
                }
            });

        }
    });
}

@end
