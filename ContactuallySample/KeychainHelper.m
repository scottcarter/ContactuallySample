//
//  KeychainHelper.m
//  ContactuallySample
//
//  Created by Scott Carter on 2/8/13.
//  
//

#import "KeychainHelper.h"
#import <Security/Security.h>

@interface KeychainHelper ()
+ (NSMutableDictionary*)dictionaryForKey:(NSString*)aKey;
@end

@implementation KeychainHelper


+ (NSMutableDictionary*)dictionaryForKey:(NSString*)aKey
{
    NSData *encodedKey = [aKey dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *searchDictionary = [NSMutableDictionary dictionary];
    
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [searchDictionary setObject:encodedKey forKey:(__bridge id)kSecAttrGeneric];
    [searchDictionary setObject:encodedKey forKey:(__bridge id)kSecAttrAccount];
    [searchDictionary setObject:[[NSBundle mainBundle] bundleIdentifier] forKey:(__bridge id)kSecAttrService];
    
    return searchDictionary;
}

+ (NSString*)getPasswordForKey:(NSString*)aKey
{
    NSString *password = nil;
    
    NSMutableDictionary *searchDictionary = [self dictionaryForKey:aKey];
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [searchDictionary setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    CFTypeRef result = NULL;
    OSStatus statusCode = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &result);
    if (statusCode == errSecSuccess) {
        NSData *resultData = CFBridgingRelease(result);
        password = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    }
    
    return password;
}

+ (void)removePasswordForKey:(NSString*)aKey
{
    NSMutableDictionary *keyDictionary = [self dictionaryForKey:aKey];
    SecItemDelete((__bridge CFDictionaryRef)keyDictionary);
}

+ (void)setPassword:(NSString*)aPassword forKey:(NSString*)aKey
{
    [KeychainHelper removePasswordForKey:aKey];
    
    NSData *encodedPassword = [aPassword dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *keyDictionary = [self dictionaryForKey:aKey];
    [keyDictionary setObject:encodedPassword forKey:(__bridge id)kSecValueData];
    SecItemAdd((__bridge CFDictionaryRef)keyDictionary, NULL);
}

@end

