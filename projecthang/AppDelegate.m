//
//  AppDelegate.m
//  projecthang
//
//  Created by toeinriver on 7/28/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "AppDelegate.h"
#import "JLRoutes.h"
#import "DemoMessagesViewController.h"
#import "projecthang-Swift.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    NSLog(@"Registering for push notifications...");
    
    UIMutableUserNotificationAction *notificationAction1 = [[UIMutableUserNotificationAction alloc] init];
    notificationAction1.identifier = @"Accept";
    notificationAction1.title = @"Accept";
    notificationAction1.activationMode = UIUserNotificationActivationModeBackground;
    notificationAction1.destructive = NO;
    notificationAction1.authenticationRequired = NO;
    
    UIMutableUserNotificationAction *notificationAction2 = [[UIMutableUserNotificationAction alloc] init];
    notificationAction2.identifier = @"Reject";
    notificationAction2.title = @"Reject";
    notificationAction2.activationMode = UIUserNotificationActivationModeBackground;
    notificationAction2.destructive = YES;
    notificationAction2.authenticationRequired = YES;
    
    UIMutableUserNotificationAction *notificationAction3 = [[UIMutableUserNotificationAction alloc] init];
    notificationAction3.identifier = @"Reply";
    notificationAction3.title = @"Reply";
    notificationAction3.activationMode = UIUserNotificationActivationModeForeground;
    notificationAction3.destructive = NO;
    notificationAction3.authenticationRequired = YES;
    
    UIMutableUserNotificationCategory *notificationCategory = [[UIMutableUserNotificationCategory alloc] init];
    notificationCategory.identifier = @"Email";
    [notificationCategory setActions:@[notificationAction1,notificationAction2,notificationAction3] forContext:UIUserNotificationActionContextDefault];
    [notificationCategory setActions:@[notificationAction1,notificationAction2] forContext:UIUserNotificationActionContextMinimal];
    
    NSSet *categories = [NSSet setWithObjects:notificationCategory, nil];
    
    UIUserNotificationType notificationType = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationType categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];

    [JLRoutes addRoute:@"/events/:id" handler:^BOOL(NSDictionary *parameters) {
        NSString *id = parameters[@"id"];
        NSLog(@"event id from router: %@", id);
        DemoMessagesViewController *vc = [DemoMessagesViewController messagesViewController];
        NSLog(@"message vc: %@", vc);
        UINavigationController *topNavVC = ((UITabBarController*) application.keyWindow.rootViewController).selectedViewController;
        if ([topNavVC isKindOfClass:[UINavigationController class]]) {
            [topNavVC pushViewController:vc animated:YES];
        }
        else {
            @throw @"topNavVC is not an instance of UINavigationController";
        }
        return YES;
    }];
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [DropboxFileListViewController setUpKey];
    });
    
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]]
     setTitleTextAttributes:
     @{
       NSFontAttributeName:[UIFont systemFontOfSize:18.0]
       }
     forState:UIControlStateNormal];
    
    [self.window makeKeyAndVisible];

    return YES;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    [self.window setFrame:bounds];
    [self.window setBounds:bounds];
    
    return YES;
}

- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)(void))completionHandler {
    NSLog(@"action triggered");
    NSLog(@"identifier, %@", identifier);
    NSLog(@"userInfo, %@", userInfo);
    completionHandler();
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings // NS_AVAILABLE_IOS(8_0);
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    
    NSLog(@"deviceToken: %@", deviceToken);
    NSString * token = [NSString stringWithFormat:@"%@", deviceToken];
    //Format token as you need:
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [DropboxFileListViewController  run_application:application openURL:url options:nil];
    NSString* query = [url query];
    NSLog(@"%@", query);
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [query componentsSeparatedByString:@"&"];
    
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        
        [queryStringDictionary setObject:value forKey:key];
    }
    NSLog(@"%@", queryStringDictionary);
    if ([queryStringDictionary[@"loginSuccess"] isEqualToString:@"YES"]) {
        [[NSUserDefaults standardUserDefaults] setObject:queryStringDictionary[@"userId"] forKey:@"userId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if ([self.loginVC.currentAction isEqualToString:@"enroll"]) {
            [self.loginVC checkoutAfterSuccessfulLogin];
        }
        
    }
    if ([queryStringDictionary[@"paymentSuccess"] isEqualToString:@"YES"]) {
        if (self.loginVC) {
            self.loginVC.evc.redirectStatus = @"paymentSuccess";
            [self.loginVC popAfterSuccessfulPayment];
        }
        else {
            self.eVC.redirectStatus = @"paymentSuccess";
            [self.eVC showInfoOnSuccessfulPayment];
        }
        
    }
    if ([queryStringDictionary[@"paymentSuccess"] isEqualToString:@"NO"]) {
        if (self.loginVC) {
            [self.loginVC showInfoOnFailedPayment];
        }
        else {
            [self.eVC showInfoOnFailedPayment];
        }
        
    }
    return [JLRoutes routeURL:url];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"remote notification user info %@", userInfo);
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler {
    NSLog(@"another remote notification user info %@", userInfo);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *editPost = [NSURL URLWithString:@"han://events/123?debug=true&foo=bar&front_end=true"];
        [[UIApplication sharedApplication] openURL:editPost];
    });
    
    if(application.applicationState == UIApplicationStateInactive) {
        
        NSLog(@"Inactive");
        
        //Show the view with the content of the push
        
        handler(UIBackgroundFetchResultNewData);
        
    } else if (application.applicationState == UIApplicationStateBackground) {
        
        NSLog(@"Background");
        
        //Refresh the local model
        
        handler(UIBackgroundFetchResultNewData);
        
    } else {
        
        NSLog(@"Active");
        
        //Show an in-app banner
        
        handler(UIBackgroundFetchResultNewData);
        
    }
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    return [self application:app handleOpenURL:url];
}

@end
