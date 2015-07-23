# GHKeychain

GHKeychain is a simple wrapper for accessing accounts, getting passwords, setting passwords, and deleting passwords using the system Keychain on Mac OS X and iOS.

This is a fork of SSKeychain.

## Adding to Your Project

Simply add the following to your Podfile if you're using CocoaPods:

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
+ (NSArray *)allAccounts;
+ (NSArray *)accountsForService:(NSString *)serviceName error:(NSError **)error;
+ (NSString *)dataForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;
+ (BOOL)deleteForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;
+ (BOOL)setData:(NSData *)data forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;
```

If you are storing a text password, you can convert:

```objc
NSData *data = [@"the password" dataUsingEncoding:NSUTF8StringEncoding]
NSString *password = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
```
