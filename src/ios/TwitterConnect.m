
#import <Foundation/Foundation.h>
#import "TwitterConnect.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

@implementation TwitterConnect

- (void)pluginInitialize
{
    
    NSString* consumerKey = [self.commandDelegate.settings objectForKey:[@"TwitterConsumerKey" lowercaseString]];
    NSString* consumerSecret = [self.commandDelegate.settings objectForKey:[@"TwitterConsumerSecret" lowercaseString]];
    [[Twitter sharedInstance] startWithConsumerKey:consumerKey consumerSecret:consumerSecret];
    [Fabric with:@[[Twitter sharedInstance]]];
    
    [Fabric with:@[TwitterKit]];
}


- (void)login:(CDVInvokedUrlCommand*)command
{
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
		__block CDVPluginResult* pluginResult = nil;
		if (session){
            TWTRShareEmailViewController* shareEmailViewController = [[TWTRShareEmailViewController alloc] initWithCompletion:^(NSString* email,   NSError* error) {
                if(error) {
                    email = @"";
                }
                
                NSDictionary *userSession = @{
                                              @"userName": [session userName],
                                              @"userId": [session userID],
                                              @"secret": [session authTokenSecret],
                                              @"token" : [session authToken],
                                              @"email" :  email};
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                             messageAsDictionary:userSession];
                
                
                [self.commandDelegate sendPluginResult:pluginResult
                                            callbackId:command.callbackId];
                
             }];
            
             id currentController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
             [currentController presentViewController:shareEmailViewController
                                            animated:YES
                                          completion:nil];

			
			
		} else {
			NSLog(@"error: %@", [error localizedDescription]);
			pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                             messageAsString:[error localizedDescription]];
		}
		
	}];
}

- (void)logout:(CDVInvokedUrlCommand*)command
{
    [[Twitter sharedInstance] logOut];
	CDVPluginResult* pluginResult = pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
