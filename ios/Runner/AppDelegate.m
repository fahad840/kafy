#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
@import Firebase;
#import "GoogleMaps/GoogleMaps.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FIRApp configure];
  [GMSServices provideAPIKey:@"AIzaSyDLwsfPUlJLwLBrpEKcHlodvd9ksnSQWsM"];
  [GeneratedPluginRegistrant registerWithRegistry:self];


  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
