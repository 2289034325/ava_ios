//
//  AppDelegate.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/8/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

import DrawerController
import SVProgressHUD

import JWTDecode
import ObjectMapper

import DropDown

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        URLProtocol.registerClass(WebViewImageProtocol.self)
        
        self.window = UIWindow();
        self.window?.frame=UIScreen.main.bounds;
        self.window?.makeKeyAndVisible();

        //判断是否登陆，token是否过期
        let loginController = LoginViewController();
        if let token = V2EXSettings.sharedInstance[kUserToken] {
            do {
                if token.isEmpty{
                    self.window?.rootViewController = loginController;
                }
                else{
                    let jwt = try decode(jwt: token)
                    let name = jwt.body["name"] as! String
                    let exp = jwt.body["exp"] as! Int
                    let now = Int(Date().timeIntervalSince1970)
                    if(exp < now){
                        self.window?.rootViewController = loginController;
                    }
                    else {
                        if let su = V2UsersKeychain.sharedInstance.users[name]{
                        var map = [String:String]()
                        map["name"] =  name
                        map["roles"] =  su.roles
//                        map["password"] = su?.password
//                        map["avatar_large"] = su?.avatar
//                        map["avatar_normal"] = su?.avatar
                        
                        V2User.sharedInstance.user = Mapper<UserModel>().map(JSON: map)
                        let rootNav = LayoutViewController()
                        self.window?.rootViewController = rootNav;
                        }
                        else{
                            self.window?.rootViewController = loginController;
                        }
                    }
                }
            }
            catch let exp{
                print(exp)
            }
        }
        else{
            self.window?.rootViewController = loginController;
        }

        SVProgressHUD.setForegroundColor(UIColor(white: 1, alpha: 1))
        SVProgressHUD.setBackgroundColor(UIColor(white: 0.15, alpha: 0.85))
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setMinimumDismissTimeInterval(1.5)
        SVProgressHUD.setContainerView(self.window!)
        
        //只有放这里才起作用，放其他controller里面，不起作用，fuck
        UITabBar.appearance().tintColor = #colorLiteral(red: 0, green: 0.5032967925, blue: 1, alpha: 1)
        
        DropDown.startListeningToKeyboard()
        
        // 防止屏幕关闭
        UIApplication.shared.isIdleTimerDisabled = true
 
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    fileprivate var lastPasteString: String?
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

