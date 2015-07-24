//
//  GHKeychain.h
//  GHKeychain
//
//  Created by Sam Soffes on 5/19/10.
//  Copyright (c) 2010-2014 Sam Soffes. All rights reserved.
//

#import "GHKeychainQuery.h"

/**
 Error code specific to GHKeychain that can be returned in NSError objects.
 For codes returned by the operating system, refer to SecBase.h for your
 platform.
 */
typedef NS_ENUM(OSStatus, GHKeychainErrorCode) {
  /** Some of the arguments were invalid. */
  GHKeychainErrorBadArguments = -1001,
};

/** GHKeychain error domain */
extern NSString *const kGHKeychainErrorDomain;

/** Account name. */
extern NSString *const kGHKeychainAccountKey;

/**
 Time the item was created.

 The value will be a string.
 */
extern NSString *const kGHKeychainCreatedAtKey;

/** Item class. */
extern NSString *const kGHKeychainClassKey;

/** Item description. */
extern NSString *const kGHKeychainDescriptionKey;

/** Item label. */
extern NSString *const kGHKeychainLabelKey;

/** Time the item was last modified.

 The value will be a string.
 */
extern NSString *const kGHKeychainLastModifiedKey;

/** Where the item was created. */
extern NSString *const kGHKeychainWhereKey;

/**
 Simple wrapper for accessing accounts, getting passwords, setting passwords, and deleting passwords using the system
 Keychain on Mac OS X and iOS.

 This was originally inspired by EMKeychain and SDKeychain (both of which are now gone). Thanks to the authors.
 GHKeychain has since switched to a simpler implementation that was abstracted from [SSToolkit](http://sstoolk.it).
 */
@interface GHKeychain : NSObject

/**
 Returns data for a given account and service, or `nil` if the Keychain doesn't have a password for the given parameters.

 @param service The service for which to return the corresponding password.

 @param account The account for which to return the corresponding password.

 @return Returns data for a given account and service, or `nil` if the Keychain doesn't have data for the given parameters.
 */
+ (NSData *)dataForService:(NSString *)service account:(NSString *)account error:(NSError **)error;


/**
 Deletes from the Keychain.

 @param service The service for which to delete the corresponding password.

 @param account The account for which to delete the corresponding password.

 @return Returns `YES` on success, or `NO` on failure.
 */
+ (BOOL)deleteForService:(NSString *)service account:(NSString *)account error:(NSError **)error;


/**
 Sets an item in the Keychain.

 @param data The data to store in the Keychain.

 @param service The service for which to set the corresponding password.

 @param account The account for which to set the corresponding password.

 @return Returns `YES` on success, or `NO` on failure.
 */
+ (BOOL)setData:(NSData *)password service:(NSString *)service account:(NSString *)account error:(NSError **)error;

/**
 Returns an array containing the Keychain's accounts, or `nil` if the Keychain has no accounts.

 See the `NSString` constants declared in GHKeychain.h for a list of keys that can be used when accessing the
 dictionaries returned by this method.

 @return An array of dictionaries containing the Keychain's accounts, or `nil` if the Keychain doesn't have any
 accounts. The order of the objects in the array isn't defined.
 */
+ (NSArray *)allAccounts:(NSError **)error;


/**
 Returns an array containing the Keychain's accounts for a given service, or `nil` if the Keychain doesn't have any
 accounts for the given service.

 See the `NSString` constants declared in GHKeychain.h for a list of keys that can be used when accessing the
 dictionaries returned by this method.

 @param service The service for which to return the corresponding accounts.

 @return An array of dictionaries containing the Keychain's accounts for a given `service`, or `nil` if the Keychain
 doesn't have any accounts for the given `service`. The order of the objects in the array isn't defined.
 */
+ (NSArray *)accountsForService:(NSString *)service error:(NSError **)error;


#pragma mark - Configuration

#if __IPHONE_4_0 && TARGET_OS_IPHONE
/**
 Returns the accessibility type for all future passwords saved to the Keychain.

 @return Returns the accessibility type.

 The return value will be `NULL` or one of the "Keychain Item Accessibility
 Constants" used for determining when a keychain item should be readable.

 @see setAccessibilityType
 */
+ (CFTypeRef)accessibilityType;

/**
 Sets the accessibility type for all future passwords saved to the Keychain.

 @param accessibilityType One of the "Keychain Item Accessibility Constants"
 used for determining when a keychain item should be readable.

 If the value is `NULL` (the default), the Keychain default will be used.

 @see accessibilityType
 */
+ (void)setAccessibilityType:(CFTypeRef)accessibilityType;
#endif

@end
