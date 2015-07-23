//
//  GHKeychain.m
//  GHKeychain
//
//  Created by Sam Soffes on 5/19/10.
//  Copyright (c) 2010-2014 Sam Soffes. All rights reserved.
//

#import "GHKeychain.h"

NSString *const kGHKeychainErrorDomain = @"GHKeychain";
NSString *const kGHKeychainAccountKey = @"acct";
NSString *const kGHKeychainCreatedAtKey = @"cdat";
NSString *const kGHKeychainClassKey = @"labl";
NSString *const kGHKeychainDescriptionKey = @"desc";
NSString *const kGHKeychainLabelKey = @"labl";
NSString *const kGHKeychainLastModifiedKey = @"mdat";
NSString *const kGHKeychainWhereKey = @"svce";

#if __IPHONE_4_0 && TARGET_OS_IPHONE
static CFTypeRef GHKeychainAccessibilityType = NULL;
#endif

@implementation GHKeychain

+ (NSData *)dataForService:(NSString *)serviceName account:(NSString *)account type:(GHKeychainItemType)type error:(NSError **)error {
  GHKeychainQuery *query = [[GHKeychainQuery alloc] init];
  query.service = serviceName;
  query.account = account;
  query.type = type;
  [query fetch:error];
  return query.data;
}

+ (BOOL)deleteForService:(NSString *)serviceName account:(NSString *)account type:(GHKeychainItemType)type error:(NSError **)error {
  GHKeychainQuery *query = [[GHKeychainQuery alloc] init];
  query.service = serviceName;
  query.account = account;
  query.type = type;
  return [query deleteItem:error];
}

+ (BOOL)setData:(NSData *)data forService:(NSString *)serviceName account:(NSString *)account type:(GHKeychainItemType)type error:(NSError **)error {
  GHKeychainQuery *query = [[GHKeychainQuery alloc] init];
  query.service = serviceName;
  query.account = account;
  query.data = data;
  query.type = type;
  return [query save:error];
}

+ (NSArray *)allAccounts:(NSError **)error {
  return [self accountsForService:nil error:error];
}


+ (NSArray *)accountsForService:(NSString *)serviceName error:(NSError **)error {
  GHKeychainQuery *query = [[GHKeychainQuery alloc] init];
  query.service = serviceName;
  return [query fetchAll:error];
}

#if __IPHONE_4_0 && TARGET_OS_IPHONE
+ (CFTypeRef)accessibilityType {
  return GHKeychainAccessibilityType;
}

+ (void)setAccessibilityType:(CFTypeRef)accessibilityType {
  CFRetain(accessibilityType);
  if (GHKeychainAccessibilityType) {
    CFRelease(GHKeychainAccessibilityType);
  }
  GHKeychainAccessibilityType = accessibilityType;
}
#endif

@end
