//
//  KeychainHelper.h
//  ContactuallySample
//
//  Created by Scott Carter on 2/8/13.
//
// Credit for this class goes to following sources:
// http://useyourloaf.com/blog/2010/03/29/simple-iphone-keychain-access.html
// http://josebolanos.wordpress.com/2012/03/16/core-data-passwords-in-keychain/
// http://stackoverflow.com/questions/11012860/getting-error-using-cftyperef-with-arc
//

#import <Foundation/Foundation.h>

@interface KeychainHelper : NSObject

+ (NSString*)getPasswordForKey:(NSString*)aKey;
+ (void)setPassword:(NSString*)aPassword forKey:(NSString*)aKey;
+ (void)removePasswordForKey:(NSString*)aKey;


@end
