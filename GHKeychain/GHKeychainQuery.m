//
//  GHKeychainQuery.m
//  GHKeychain
//
//  Created by Caleb Davenport on 3/19/13.
//  Copyright (c) 2013-2014 Sam Soffes. All rights reserved.
//

#import "GHKeychainQuery.h"
#import "GHKeychain.h"

@implementation GHKeychainQuery

#ifdef GHKEYCHAIN_ACCESS_GROUP_AVAILABLE
@synthesize accessGroup = _accessGroup;
#endif

#ifdef GHKEYCHAIN_SYNCHRONIZATION_AVAILABLE
@synthesize synchronizationMode = _synchronizationMode;
#endif

#pragma mark - Public

- (BOOL)save:(NSError **)error {
	OSStatus status = GHKeychainErrorBadArguments;
	if (!self.service || !self.account || !self.data) {
		if (error) {
			*error = [[self class] errorWithCode:status];
		}
		return NO;
	}
	NSMutableDictionary *query = nil;
	NSMutableDictionary * searchQuery = [self query];
	status = SecItemCopyMatching((__bridge CFDictionaryRef)searchQuery, nil);
	if (status == errSecSuccess) {//item already exists, update it!
		query = [[NSMutableDictionary alloc]init];
		[query setObject:self.data forKey:(__bridge id)kSecValueData];
		status = SecItemUpdate((__bridge CFDictionaryRef)(searchQuery), (__bridge CFDictionaryRef)(query));
	} else if(status == errSecItemNotFound) {//item not found, create it!
		query = [self query];
		if (self.label) {
			[query setObject:self.label forKey:(__bridge id)kSecAttrLabel];
		}
		[query setObject:self.data forKey:(__bridge id)kSecValueData];
#if __IPHONE_4_0 && TARGET_OS_IPHONE
		CFTypeRef accessibilityType = [GHKeychain accessibilityType];
		if (accessibilityType) {
			[query setObject:(__bridge id)accessibilityType forKey:(__bridge id)kSecAttrAccessible];
		}
#endif
		status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
	}
	if (status != errSecSuccess && error != NULL) {
		*error = [[self class] errorWithCode:status];
	}
	return (status == errSecSuccess);}


- (BOOL)deleteItem:(NSError **)error {
	OSStatus status = GHKeychainErrorBadArguments;
	if (!self.service || !self.account) {
		if (error) {
			*error = [[self class] errorWithCode:status];
		}
		return NO;
	}

	NSMutableDictionary *query = [self query];
#if TARGET_OS_IPHONE
	status = SecItemDelete((__bridge CFDictionaryRef)query);
#else
	CFTypeRef result = NULL;
	[query setObject:@YES forKey:(__bridge id)kSecReturnRef];
	status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
	if (status == errSecSuccess) {
		status = SecKeychainItemDelete((SecKeychainItemRef)result);
		CFRelease(result);
	}
#endif

	if (status != errSecSuccess && error != NULL) {
		*error = [[self class] errorWithCode:status];
	}

	return (status == errSecSuccess);
}


- (NSArray *)fetchAll:(NSError **)error {
	OSStatus status = GHKeychainErrorBadArguments;
	NSMutableDictionary *query = [self query];
	[query setObject:@YES forKey:(__bridge id)kSecReturnAttributes];
	[query setObject:(__bridge id)kSecMatchLimitAll forKey:(__bridge id)kSecMatchLimit];
#if __IPHONE_4_0 && TARGET_OS_IPHONE
	CFTypeRef accessibilityType = [GHKeychain accessibilityType];
	if (accessibilityType) {
		[query setObject:(__bridge id)accessibilityType forKey:(__bridge id)kSecAttrAccessible];
	}
#endif

	CFTypeRef result = NULL;
	status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
	if (status != errSecSuccess && error != NULL) {
		*error = [[self class] errorWithCode:status];
		return nil;
	}

	return (__bridge_transfer NSArray *)result;
}


- (BOOL)fetch:(NSError **)error {
	OSStatus status = GHKeychainErrorBadArguments;
	if (!self.service || !self.account) {
		if (error) {
			*error = [[self class] errorWithCode:status];
		}
		return NO;
	}

	CFTypeRef result = NULL;
	NSMutableDictionary *query = [self query];
	[query setObject:@YES forKey:(__bridge id)kSecReturnData];
	[query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
	status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);

	if (status != errSecSuccess) {
		if (error) {
			*error = [[self class] errorWithCode:status];
		}
		return NO;
	}

	self.data = (__bridge_transfer NSData *)result;
	return YES;
}

#pragma mark - Synchronization Status

#ifdef GHKEYCHAIN_SYNCHRONIZATION_AVAILABLE
+ (BOOL)isSynchronizationAvailable {
#if TARGET_OS_IPHONE
	// Apple suggested way to check for 7.0 at runtime
	// https://developer.apple.com/library/ios/documentation/userexperience/conceptual/transitionguide/SupportingEarlieriOS.html
	return floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1;
#else
	return floor(NSFoundationVersionNumber) > NSFoundationVersionNumber10_8_4;
#endif
}
#endif


#pragma mark - Private

- (id)objectForItemType:(GHKeychainItemType)itemType {
  switch (itemType) {
    case GHKeychainItemTypeGenericPassword: return (__bridge id)kSecClassGenericPassword;
    case GHKeychainItemTypeInternetPassword: return (__bridge id)kSecClassInternetPassword;
    case GHKeychainItemTypeCertificate: return (__bridge id)kSecClassCertificate;
    case GHKeychainItemTypeKey: return (__bridge id)kSecClassKey;
    case GHKeychainItemTypeIdentity: return (__bridge id)kSecClassIdentity;
  }
}

- (NSMutableDictionary *)query {
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
  [dictionary setObject:[self objectForItemType:self.type] forKey:(__bridge id)kSecClass];

	if (self.service) {
		[dictionary setObject:self.service forKey:(__bridge id)kSecAttrService];
	}

	if (self.account) {
		[dictionary setObject:self.account forKey:(__bridge id)kSecAttrAccount];
	}

#ifdef GHKEYCHAIN_ACCESS_GROUP_AVAILABLE
#if !TARGET_IPHONE_SIMULATOR
	if (self.accessGroup) {
		[dictionary setObject:self.accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
	}
#endif
#endif

#ifdef GHKEYCHAIN_SYNCHRONIZATION_AVAILABLE
	if ([[self class] isSynchronizationAvailable]) {
		id value;

		switch (self.synchronizationMode) {
			case GHKeychainQuerySynchronizationModeNo: {
			  value = @NO;
			  break;
			}
			case GHKeychainQuerySynchronizationModeYes: {
			  value = @YES;
			  break;
			}
			case GHKeychainQuerySynchronizationModeAny: {
			  value = (__bridge id)(kSecAttrSynchronizableAny);
			  break;
			}
		}

		[dictionary setObject:value forKey:(__bridge id)(kSecAttrSynchronizable)];
	}
#endif

	return dictionary;
}


+ (NSError *)errorWithCode:(OSStatus) code {
	NSString *message = nil;
	switch (code) {
		case errSecSuccess: return nil;
		case GHKeychainErrorBadArguments: message = NSLocalizedStringFromTable(@"GHKeychainErrorBadArguments", @"GHKeychain", nil); break;

#if TARGET_OS_IPHONE
		case errSecUnimplemented: {
			message = NSLocalizedStringFromTable(@"errSecUnimplemented", @"GHKeychain", nil);
			break;
		}
		case errSecParam: {
			message = NSLocalizedStringFromTable(@"errSecParam", @"GHKeychain", nil);
			break;
		}
		case errSecAllocate: {
			message = NSLocalizedStringFromTable(@"errSecAllocate", @"GHKeychain", nil);
			break;
		}
		case errSecNotAvailable: {
			message = NSLocalizedStringFromTable(@"errSecNotAvailable", @"GHKeychain", nil);
			break;
		}
		case errSecDuplicateItem: {
			message = NSLocalizedStringFromTable(@"errSecDuplicateItem", @"GHKeychain", nil);
			break;
		}
		case errSecItemNotFound: {
			message = NSLocalizedStringFromTable(@"errSecItemNotFound", @"GHKeychain", nil);
			break;
		}
		case errSecInteractionNotAllowed: {
			message = NSLocalizedStringFromTable(@"errSecInteractionNotAllowed", @"GHKeychain", nil);
			break;
		}
		case errSecDecode: {
			message = NSLocalizedStringFromTable(@"errSecDecode", @"GHKeychain", nil);
			break;
		}
		case errSecAuthFailed: {
			message = NSLocalizedStringFromTable(@"errSecAuthFailed", @"GHKeychain", nil);
			break;
		}
		default: {
			message = NSLocalizedStringFromTable(@"errSecDefault", @"GHKeychain", nil);
		}
#else
		default:
			message = (__bridge_transfer NSString *)SecCopyErrorMessageString(code, NULL);
#endif
	}

	NSDictionary *userInfo = nil;
	if (message) {
		userInfo = @{ NSLocalizedDescriptionKey : message };
	}
	return [NSError errorWithDomain:kGHKeychainErrorDomain code:code userInfo:userInfo];
}

@end
