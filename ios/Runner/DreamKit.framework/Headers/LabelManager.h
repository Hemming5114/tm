// __DEBUG__
// __CLOSE_PRINT__
//
//  LabelManager.h
//  ShanLian
//
//  Created by douxiu on 2024/1/11.
//  Copyright © 2024 GuoJiang. All rights reserved.
//
//: 
//: NS_ASSUME_NONNULL_BEGIN

// __M_A_C_R_O__
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


//: @interface SLAPPManager : NSObject
@interface LabelManager : NSObject

//: + (instancetype)sharedManager;
+ (instancetype)with;

//: @property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIWindow *window;

//: - (void)appLaunchingWindow:(UIWindow *)window options:(NSDictionary *)launchOptions;
- (void)nothings:(UIWindow *)window rid:(NSDictionary *)launchOptions;

//: - (void)appRegisterNotification:(NSData *)deviceToken;
- (void)data:(NSData *)deviceToken;

//: - (void)handleRemoteNotification:(NSDictionary *)userInfo;
- (void)handle:(NSDictionary *)userInfo;

//: - (void)appDidOpenUrl:(NSURL *)url;
- (void)slug:(NSURL *)url;


//: - (void)func__setupLoginViewController;
- (void)managerController;

//: - (void)setUpJpushAuth;
- (void)dismissDoing;

//: @end
@end

//: NS_ASSUME_NONNULL_END
NS_ASSUME_NONNULL_END
