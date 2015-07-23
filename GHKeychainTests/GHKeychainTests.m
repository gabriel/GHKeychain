//
//  GHKeychainTests.m
//  GHKeychainTests
//
//  Created by Sam Soffes on 10/3/11.
//  Copyright (c) 2011-2014 Sam Soffes. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <GHKeychain/GHKeychain.h>

static NSString *const kGHKeychainServiceName = @"Test";
static NSString *const kGHKeychainAccountName = @"TestAccount";
static NSString *const kGHKeychainPassword = @"TestPassword";
static NSString *const kGHKeychainLabel = @"MyLabel";

@interface GHKeychainTests : XCTestCase
@end

@implementation GHKeychainTests

- (void)testNewItem {
	// New item
	GHKeychainQuery *query = [[GHKeychainQuery alloc] init];
	query.data = [kGHKeychainPassword dataUsingEncoding:NSUTF8StringEncoding];
	query.service = kGHKeychainServiceName;
	query.account = kGHKeychainAccountName;
	query.label = kGHKeychainLabel;

	NSError *error;
	XCTAssertTrue([query save:&error], @"Unable to save item: %@", error);

	// Look up
	query = [[GHKeychainQuery alloc] init];
	query.service = kGHKeychainServiceName;
	query.account = kGHKeychainAccountName;
	query.data = nil;

	XCTAssertTrue([query fetch:&error], @"Unable to fetch keychain item: %@", error);
	XCTAssertEqualObjects(query.data, [kGHKeychainPassword dataUsingEncoding:NSUTF8StringEncoding], @"Passwords were not equal");

	// Search for all accounts
	query = [[GHKeychainQuery alloc] init];
	NSArray *accounts = [query fetchAll:&error];
	XCTAssertNotNil(accounts, @"Unable to fetch accounts: %@", error);
	XCTAssertTrue([self _accounts:accounts containsAccountWithName:kGHKeychainAccountName], @"Matching account was not returned");

	// Check accounts for service
	query.service = kGHKeychainServiceName;
	accounts = [query fetchAll:&error];
	XCTAssertNotNil(accounts, @"Unable to fetch accounts: %@", error);
	XCTAssertTrue([self _accounts:accounts containsAccountWithName:kGHKeychainAccountName], @"Matching account was not returned");

	// Delete
	query = [[GHKeychainQuery alloc] init];
	query.service = kGHKeychainServiceName;
	query.account = kGHKeychainAccountName;
	XCTAssertTrue([query deleteItem:&error], @"Unable to delete password: %@", error);
}

- (void)testMissingInformation {
	GHKeychainQuery *query = [[GHKeychainQuery alloc] init];
	query.service = kGHKeychainServiceName;
	query.account = kGHKeychainAccountName;

	NSError *error;
	XCTAssertFalse([query save:&error], @"Function should return NO as not all needed information is provided: %@", error);
	
	query = [[GHKeychainQuery alloc] init];
	query.data = [kGHKeychainPassword dataUsingEncoding:NSUTF8StringEncoding];
	query.account = kGHKeychainAccountName;
	XCTAssertFalse([query save:&error], @"Function should return NO as not all needed information is provided: %@", error);

	query = [[GHKeychainQuery alloc] init];
	query.data = [kGHKeychainPassword dataUsingEncoding:NSUTF8StringEncoding];
	query.service = kGHKeychainServiceName;
	XCTAssertFalse([query save:&error], @"Function save should return NO if not all needed information is provided: %@", error);
}

- (void)testDeleteWithMissingInformation {
	GHKeychainQuery *query = [[GHKeychainQuery alloc] init];
	query.account = kGHKeychainAccountName;

	NSError *error;
	XCTAssertFalse([query deleteItem:&error], @"Function deleteItem should return NO if not all needed information is provided: %@", error);

	query = [[GHKeychainQuery alloc] init];
	query.service = kGHKeychainServiceName;
	XCTAssertFalse([query deleteItem:&error], @"Function deleteItem should return NO if not all needed information is provided: %@", error);
	
	// check if fetch handels missing information correctly
	query = [[GHKeychainQuery alloc] init];
	query.account = kGHKeychainAccountName;
	XCTAssertFalse([query fetch:&error], @"Function fetch should return NO if not all needed information is provided: %@", error);
	
	query = [[GHKeychainQuery alloc] init];
	query.service = kGHKeychainServiceName;
	XCTAssertFalse([query fetch:&error], @"Function fetch should return NO if not all needed information is provided: %@", error);

	query = [[GHKeychainQuery alloc] init];
	query.service = kGHKeychainServiceName;
	XCTAssertFalse([query fetch:NULL], @"Function fetch should return NO if not all needed information is provided and error is NULL");
}


- (void)testSynchronizable {
	GHKeychainQuery *query = [[GHKeychainQuery alloc] init];
	query.service = kGHKeychainServiceName;
	query.account = kGHKeychainAccountName;
	query.data = [kGHKeychainPassword dataUsingEncoding:NSUTF8StringEncoding];
	query.synchronizationMode = GHKeychainQuerySynchronizationModeYes;

	NSError *error;
	XCTAssertTrue([query save:&error], @"Unable to save item: %@", error);

	query = [[GHKeychainQuery alloc] init];
	query.service = kGHKeychainServiceName;
	query.account = kGHKeychainAccountName;
	query.data = nil;
	query.synchronizationMode = GHKeychainQuerySynchronizationModeNo;
	XCTAssertFalse([query fetch:&error], @"Fetch should fail when trying to fetch an unsynced password that was saved as synced: %@", error);
	XCTAssertFalse([query fetch:NULL], @"Fetch should fail when trying to fetch an unsynced password that was saved as synced. error == NULL");

	XCTAssertNotEqualObjects(query.data, [kGHKeychainPassword dataUsingEncoding:NSUTF8StringEncoding], @"Passwords should not be equal when trying to fetch an unsynced password that was saved as synced.");
  
	query = [[GHKeychainQuery alloc] init];
	query.service = kGHKeychainServiceName;
	query.account = kGHKeychainAccountName;
	query.data = nil;
	query.synchronizationMode = GHKeychainQuerySynchronizationModeAny;
	XCTAssertTrue([query fetch:&error], @"Unable to fetch keychain item: %@", error);
	XCTAssertEqualObjects(query.data, [kGHKeychainPassword dataUsingEncoding:NSUTF8StringEncoding], @"Passwords were not equal");
}


// Test Class Methods of GHKeychain
- (void)testGHKeychain {
	NSError *error = nil;
	
	// create a new keychain item
  XCTAssertTrue([GHKeychain setData:[kGHKeychainPassword dataUsingEncoding:NSUTF8StringEncoding] forService:kGHKeychainServiceName account:kGHKeychainAccountName type:GHKeychainItemTypeGenericPassword error:&error], @"Unable to save item: %@", error);
	
	// check password
  XCTAssertEqualObjects([GHKeychain dataForService:kGHKeychainServiceName account:kGHKeychainAccountName type:GHKeychainItemTypeGenericPassword error:nil], [kGHKeychainPassword dataUsingEncoding:NSUTF8StringEncoding], @"Passwords were not equal");
	
	// check all accounts
  XCTAssertTrue([self _accounts:[GHKeychain allAccounts:nil] containsAccountWithName:kGHKeychainAccountName], @"Matching account was not returned");
	// check account
  XCTAssertTrue([self _accounts:[GHKeychain accountsForService:kGHKeychainServiceName error:nil] containsAccountWithName:kGHKeychainAccountName], @"Matching account was not returned");
	
	// delete password
	XCTAssertTrue([GHKeychain deleteForService:kGHKeychainServiceName account:kGHKeychainAccountName type:GHKeychainItemTypeGenericPassword error:&error], @"Unable to delete password: %@", error);
	
	// set password and delete it without error function
#if __IPHONE_4_0 && TARGET_OS_IPHONE
	[GHKeychain setAccessibilityType:kSecAttrAccessibleWhenUnlockedThisDeviceOnly];
	XCTAssertTrue([GHKeychain accessibilityType] == kSecAttrAccessibleWhenUnlockedThisDeviceOnly, @"Unable to verify accessibilityType");
#endif
}


#pragma mark - Private

- (BOOL)_accounts:(NSArray *)accounts containsAccountWithName:(NSString *)name {
	for (NSDictionary *dictionary in accounts) {
		if ([[dictionary objectForKey:@"acct"] isEqualToString:name]) {
			return YES;
		}
	}
	return NO;
}

@end
