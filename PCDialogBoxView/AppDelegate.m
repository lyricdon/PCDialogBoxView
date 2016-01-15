//
//  AppDelegate.m
//  PCDialogBoxView
//
//  Created by lyricdon on 16/1/13.
//  Copyright © 2016年 lyricdon. All rights reserved.
//

#import "AppDelegate.h"
#import "PCDialogBoxView.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    UIButton *nameButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    nameButton.backgroundColor = [UIColor redColor];
    [nameButton setTitle:@"昵称/性别" forState:UIControlStateNormal];
    nameButton.tag = PCDialogBoxViewStyleNickname;
    [nameButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *phoneButton = [[UIButton alloc] initWithFrame:CGRectMake(210, 100, 100, 100)];
    phoneButton.backgroundColor = [UIColor redColor];
    [phoneButton setTitle:@"电话" forState:UIControlStateNormal];
    phoneButton.tag = PCDialogBoxViewStylePhone;
    [phoneButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *addressButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 210, 100, 100)];
    addressButton.backgroundColor = [UIColor redColor];
    [addressButton setTitle:@"地址" forState:UIControlStateNormal];
    addressButton.tag = PCDialogBoxViewStyleAdress;
    [addressButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *emailButton = [[UIButton alloc] initWithFrame:CGRectMake(210, 210, 100, 100)];
    emailButton.backgroundColor = [UIColor redColor];
    [emailButton setTitle:@"邮箱" forState:UIControlStateNormal];
    emailButton.tag = PCDialogBoxViewStyleEmail;
    [emailButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view.backgroundColor = [UIColor orangeColor];
    [viewController.view addSubview:nameButton];
    [viewController.view addSubview:phoneButton];
    [viewController.view addSubview:addressButton];
    [viewController.view addSubview:emailButton];
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];

    
    return YES;
}

- (void)clickButton:(UIButton *)sender
{
    PCDialogBoxView *showView = [[PCDialogBoxView alloc] initWithDetailView:self.window.rootViewController.view];
    [showView showDetailInfoHudWithButton:sender animated:YES];
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

@end
