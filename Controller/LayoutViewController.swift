//
// Created by ac on 2019-06-28.
// Copyright (c) 2019 Fin. All rights reserved.
//

import UIKit
import SwiftIconFont

class LayoutViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let dicNav = UINavigationController(rootViewController:UserBookViewController())
        let speechNav = UINavigationController(rootViewController:SpeechListController())
        let readNav = UINavigationController(rootViewController:ReadingViewController())
        let myNav = UINavigationController(rootViewController:MeViewController())

//        let dicNav = UserBookViewController()
//        let speechNav = SpeechViewController()
//        let myNav = LeftViewController()

        dicNav.tabBarItem.title = "词典"
        speechNav.tabBarItem.title = "演讲"
        readNav.tabBarItem.title = "阅读"
        myNav.tabBarItem.title = "我"

//        dicNav.tabBarItem.image = UIImage(named: "word")
//        speechNav.tabBarItem.image = UIImage(named: "speech")
//        myNav.tabBarItem.image = UIImage(named: "user")

//        self.tabBar.tintColor = UIColor.red
//        dicNav.tabBarItem.ti
        
//          UITabBar.appearance().barTintColor = UIColor.red
//        UITabBar.appearance().backgroundColor = UIColor.green
        
        tabBar.unselectedItemTintColor = .black
        
//        dicNav.tabBarItem.tintColor = UIColor.red
        dicNav.tabBarItem.icon(from: .segoeMDL2, code: "Dictionary", iconColor: #colorLiteral(red: 0.3686772585, green: 0.6366325021, blue: 0.9931303859, alpha: 1), imageSize: CGSize(width: 20, height: 20), ofSize: 20)
        speechNav.tabBarItem.icon(from: .segoeMDL2, code: "SubtitlesAudio", iconColor: #colorLiteral(red: 0.3686772585, green: 0.6366325021, blue: 0.9931303859, alpha: 1), imageSize: CGSize(width: 20, height: 20), ofSize: 20)
        readNav.tabBarItem.icon(from: .segoeMDL2, code: "AlignCenter", iconColor: #colorLiteral(red: 0.3686772585, green: 0.6366325021, blue: 0.9931303859, alpha: 1), imageSize: CGSize(width: 20, height: 20), ofSize: 20)
        myNav.tabBarItem.icon(from: .segoeMDL2, code: "Contact", iconColor: #colorLiteral(red: 0.3686772585, green: 0.6366325021, blue: 0.9931303859, alpha: 1), imageSize: CGSize(width: 20, height: 20), ofSize: 20)


        self.viewControllers = [dicNav, speechNav, readNav, myNav]

        // 文字图片颜色一块修改
        self.tabBar.tintColor = UIColor.blue


//        self.selectedViewController = speechNav
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.title = item.title
    }

}
