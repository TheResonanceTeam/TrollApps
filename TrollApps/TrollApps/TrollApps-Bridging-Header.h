//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Foundation/Foundation.h>

@interface
 LSApplicationWorkspace : NSObject
- (id)allInstalledApplications;
- (BOOL)unregisterApplication:(NSURL *)url;
- (BOOL)registerApplication:(NSURL *)url;
@end


@interface
 LSBundleProxy
@property
(readonly, nonatomic) NSURL *bundleURL;
@end


@interface
 LSApplicationProxy : LSBundleProxy
@end
