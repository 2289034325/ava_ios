//
// Created by ac on 2019-06-28.
// Copyright (c) 2019 Fin. All rights reserved.
//

import UIKit

class LayoutViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let dicNav = UINavigationController(rootViewController:UserBookViewController())
        let speechNav = UINavigationController(rootViewController:SpeechViewController())
        let myNav = UINavigationController(rootViewController:LeftViewController())

//        let dicNav = UserBookViewController()
//        let speechNav = SpeechViewController()
//        let myNav = LeftViewController()

        dicNav.tabBarItem.title = "词典"
        speechNav.tabBarItem.title = "演讲"
        myNav.tabBarItem.title = "我"

        dicNav.tabBarItem.image = UIImage(named: "word")
        speechNav.tabBarItem.image = UIImage(named: "speech")
        myNav.tabBarItem.image = UIImage(named: "user")

        self.viewControllers = [dicNav, speechNav, myNav]

        // 文字图片颜色一块修改
        self.tabBar.tintColor = UIColor.blue


//        self.selectedViewController = speechNav
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.title = item.title
    }

}