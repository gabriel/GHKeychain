# GHKeychain

GHKeychain is a framework for accessing accounts, getting, setting, and deleting items in the system Keychain on Mac OS X and iOS.

This is a fork of SSKeychain.

## Adding to Your Project

Add the following to your Podfile if you're using CocoaPods:

``` ruby
pod 'GHKeychain'
```

or Cartfile if you're using Carthage:

```
github "gabriel/GHKeychain"
```

## Usage

```objc
NSString *password = @"toomanysecrets";

[GHKeychain setData:[password dataUsingEncoding:NSUTF8StringEncoding] 
  service:@"MyApp" account:@"frank" type:GHKeychainItemTypeGenericPassword 
  error:&error]

NSData *data = [GHKeychain dataForService:@"MyApp" account:kGHKeychainAccountName 
  type:GHKeychainItemTypeGenericPassword error:&error];

NSString *checkPassword = [[NSString alloc] initWithData:data encoding:NSUTF8Encoding];

[GHKeychain deleteForService:@"MyApp" account:@"frank" 
  type:GHKeychainItemTypeGenericPassword error:&error];
```

GHKeychain has the following class methods for working with the system keychain:

```objc
+ (NSArray *)allAccounts:(NSError **)error;
+ (NSArray *)accountsForService:(NSString *)service type:(GHKeychainItemType)type error:(NSError **)error;
+ (NSString *)dataForService:(NSString *)service account:(NSString *)account type:(GHKeychainItemType)type error:(NSError **)error;
+ (BOOL)deleteForService:(NSString *)service account:(NSString *)account type:(GHKeychainItemType)type error:(NSError **)error;
+ (BOOL)setData:(NSData *)data forService:(NSString *)service account:(NSString *)account type:(GHKeychainItemType)type error:(NSError **)error;
```

### Types

```objc
GHKeychainItemTypeGenericPassword, // kSecClassGenericPassword
GHKeychainItemTypeInternetPassword, // kSecClassInternetPassword
GHKeychainItemTypeCertificate, // kSecClassCertificate
GHKeychainItemTypeKey, // kSecClassKey
GHKeychainItemTypeIdentity, //kSecClassIdentity
```
