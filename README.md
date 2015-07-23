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

## Working with the Keychain

GHKeychain has the following class methods for working with the system keychain:

```objc
+ (NSArray *)allAccounts:(NSError **)error;
+ (NSArray *)accountsForService:(NSString *)serviceName type:(GHKeychainItemType)type error:(NSError **)error;
+ (NSString *)dataForService:(NSString *)serviceName account:(NSString *)account type:(GHKeychainItemType)type error:(NSError **)error;
+ (BOOL)deleteForService:(NSString *)serviceName account:(NSString *)account type:(GHKeychainItemType)type error:(NSError **)error;
+ (BOOL)setData:(NSData *)data forService:(NSString *)serviceName account:(NSString *)account type:(GHKeychainItemType)type error:(NSError **)error;
```

If you are storing a text password, you can convert:

```objc
NSData *data = [@"the password" dataUsingEncoding:NSUTF8StringEncoding]
NSString *password = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
```
