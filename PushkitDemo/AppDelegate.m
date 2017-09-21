//
//  AppDelegate.m
//  PushkitDemo
//
//  Created by heweihua on 2017/9/19.
//  Copyright © 2017年 heweihua. All rights reserved.
//  http://www.jianshu.com/p/5939dcb5fcd2

#import "AppDelegate.h"
#import <PushKit/PushKit.h>
#import <AVFoundation/AVSpeechSynthesis.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] \
compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IOS8 (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))

@interface AppDelegate ()

@end

@implementation AppDelegate

-(void) dealloc{
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 后台播报
    NSError *error = NULL;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if(error) {
        // Do some error handling
    }
    [session setActive:YES error:&error];
    if (error) {
        // Do some error handling
    }
    //让app支持接受远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [self registerPush];
    return YES;
}


-(void) registerPush{
    
    // common push:这是给本地推送用的
    UIUserNotificationSettings *userNotifiSetting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:userNotifiSetting];
    
    // PKPush: VoIP Push Notification
    if (IOS8) {

        // 移除本地通知
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [self registerForVoIPPushes];
    }
}

- (void)registerForVoIPPushes {
    
    PKPushRegistry* voipRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    voipRegistry.delegate = (id<PKPushRegistryDelegate>)self;
    
    // Initiate registration.
    voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


// 与apns推送不同，pushkit的token获取跟apnstoken的获取方法不同，apps在
#pragma mark - common push
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    
    [application registerForRemoteNotifications];//必须先实现这个方法，才会走下面的方法
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    //获取终端设备标识，这个标识需要通过接口发送到服务器端，服务器端推送消息到APNS时需要知道终端的标识，APNS通过注册的终端标识找到终端设备
    NSLog(@"regisger success:%@", deviceToken);
}

//获取设备的token，这两个token的值是不同的，注意不要搞混了。

#pragma mark - 实现代理方法1
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type{
    
//    NSString *str = [NSString stringWithFormat:@"%@",credentials.token];
    NSLog(@"PKPush token: %@",credentials.token);
    //这个代理方法是获取了设备的唯tokenStr，是要给服务器的
}


#pragma mark - 实现代理方法2
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type {
    
    NSLog(@"pushRegistry: didReceiveIncomingPushWithPayload: forType:");
    NSLog(@"type: %@", type);
    NSLog(@"payload.dictionaryPayload: %@", payload.dictionaryPayload);
    NSLog(@"--------------------------------------------------------");
    
    NSDictionary* apsInfo = payload.dictionaryPayload[@"aps"];
    if (!apsInfo) return;

    NSString* alert = apsInfo[@"alert"];
    if (!alert) return;
    NSString* voiceOpen = apsInfo[@"voiceOpen"];

    // PKPushTypeVoIP --> 本地推送: pushkit,它的默认行为里面是不会弹出通知, 需要提示的话，本地通知推送
    UILocalNotification *localNoti = [[UILocalNotification alloc] init];
    if (localNoti) {
        
        //设置本地通知的触发时间（如果要立即触发，无需设置），这里设置为20妙后
//        localNoti.fireDate = [NSDate dateWithTimeIntervalSinceNow:20];
        //设置本地通知的时区
        localNoti.timeZone = [NSTimeZone defaultTimeZone];
        //设置通知的内容
        localNoti.alertBody = alert;
        localNoti.applicationIconBadgeNumber =1;
        //设置通知动作按钮的标题
//        localNoti.alertAction = @"查看";
        //设置提醒的声音，可以自己添加声音文件，这里设置为默认提示声
//        localNoti.soundName = UILocalNotificationDefaultSoundName;
        //设置通知的相关信息，这个很重要，可以添加一些标记性内容，方便以后区分和获取通知的信息
        NSDictionary *infoDic = [NSDictionary dictionaryWithObjectsAndKeys:@"key",@"value", nil];
        localNoti.userInfo = infoDic;
        //在规定的日期触发通知
        //[[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
        
        //立即触发一个通知
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNoti];
    }

    // voice open play
    if ([voiceOpen boolValue]) {
        [self playObject:alert];
    }
}

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type{
    
    NSLog(@"pushRegistry: didInvalidatePushTokenForType:");
}


-(void)playObject:(NSString*)message {
    
    AVSpeechUtterance *utt = [AVSpeechUtterance speechUtteranceWithString:message];
    AVSpeechSynthesisVoice* voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];//chinese
    utt.voice = voice;
    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
    [synth speakUtterance:utt];
}


    
// 收到推送--- common push
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary * _Nonnull)userInfo fetchCompletionHandler:(void (^ _Nonnull)(UIBackgroundFetchResult))completionHandler{
    NSLog(@"didReceiveRemoteNotification:%@",userInfo);
    
    //回调
    completionHandler(UIBackgroundFetchResultNewData);
    
//    _message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    /*
     // 本地音频文件播放
     NSString *path = [[NSBundle mainBundle] pathForResource:@"Cosmic" ofType:@"m4r"];
     //组装并播放音效
     SystemSoundID soundID;
     NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
     AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
     AudioServicesPlaySystemSound(soundID);
     */
    
    /*
     // 系统声音
     AudioServicesPlaySystemSound(1351);//系统声音
     AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);//震动
     */
    
    //语音播报
    //    [NSThread sleepForTimeInterval:0.05];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        [self playObject];
//    });
}




- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"test" message:notification.alertBody delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:notification.alertAction, nil];
//    [alert show];
}

@end





