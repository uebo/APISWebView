//
//  AppDelegate.m
//  APISWebView
//
//  Created by 植田 洋次 on 2015/03/27.
//  Copyright (c) 2015年 Yoji Ueda. All rights reserved.
//

#import "AppDelegate.h"
#import <AppiariesSDK/AppiariesSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //アピアリーズのセッションを初期化する
    [[APISSession sharedSession] configureWithDatastoreId:@"_sandbox" applicationId:@"APISWebView" applicationToken:@"app41b90619525d1529c93763da62"];
    
    // APNs: プッシュ通知機能利用登録（デバイストークン発行要求）
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
#ifdef __IPHONE_8_0
        // iOS8以降のプッシュ通知登録処理
        UIUserNotificationType types = UIUserNotificationTypeBadge |  UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notifSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notifSettings];
#endif
    } else {
        // iOS8以前のプッシュ通知登録処理
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    //開封通知
    NSDictionary *notificationUserInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(notificationUserInfo){
        [self showPushNotificationAlertViewIfNeeded:notificationUserInfo];
    }
    return YES;
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}
#endif

// APNs: デバイストークン発行成功時ハンドラ
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"APNs: デバイストークン発行成功 [デバイストークン:%@]", [deviceToken description]);
    // デバイストークン登録APIの実行
    APISPushAPIClient *api = [[APISSession sharedSession] createPushAPIClient];
    [api registerDeviceToken:deviceToken attributes:nil];
}

// APNs: デバイストークン発行失敗時ハンドラ
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"APNs: デバイストークン発行失敗 [原因:%@]", [error localizedDescription]);
}

//アプリがフォアグラウンド or バックグラウンドでのリモート通知処理
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //開封通知
    [self showPushNotificationAlertViewIfNeeded:userInfo];
}

- (void)showPushNotificationAlertViewIfNeeded:(NSDictionary*)userInfo
{
    //通知＆バッジを消す
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    if (!aps) {
        return;
    }
    //プッシュ通知メッセージを表示
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle", nil)
                                                    message:aps[@"alert"]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    //APIS PUSH 開封通知を送信（userInfoのpushIdキーにトークンが入っている）
    NSString* pushId = (NSString*) [userInfo objectForKey:@"pushId"];
    if (pushId != nil) {
        APISPushAPIClient *api = [[APISSession sharedSession] createPushAPIClient];
        [api notifyMessageOpenedWithPushId:[pushId integerValue]];
    }
}


@end
