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

        let dicNav = UINavigationController(rootViewController:UserWordStatController())
        let speechNav = UINavigationController(rootViewController:SpeechListController())
        let writingNav = UINavigationController(rootViewController:SampleArticleListController())
        let readNav = UINavigationController(rootViewController:BookMarkListController())
        let myNav = UINavigationController(rootViewController:MeViewController())

//        let dicNav = UserBookViewController()
//        let speechNav = SpeechViewController()
//        let myNav = LeftViewController()

        dicNav.tabBarItem.title = "词汇"
        speechNav.tabBarItem.title = "会话"
        writingNav.tabBarItem.title = "写作"
        readNav.tabBarItem.title = "书签"
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
        let dic_img = UIImage(from: .fontAwesome, code: "paperplaneo", textColor: .gray, backgroundColor: .clear, size: CGSize(width: 28, height: 28))
        let dic_img_sel = UIImage(from: .fontAwesome, code: "paperplane", textColor: .gray, backgroundColor: .clear, size: CGSize(width: 28, height: 28))
        
        let speech_img = UIImage(from: .fontAwesome, code: "commentingo", textColor: .gray, backgroundColor: .clear, size: CGSize(width: 30, height: 30))
        let speech_img_sel = UIImage(from: .fontAwesome, code: "commenting", textColor: .gray, backgroundColor: .clear, size: CGSize(width: 30, height: 30))
        
        let writing_img = UIImage(from: .fontAwesome, code: "pencilsquareo", textColor: .gray, backgroundColor: .clear, size: CGSize(width: 30, height: 30))
        let writing_img_sel = UIImage(from: .fontAwesome, code: "pencilsquareo", textColor: .gray, backgroundColor: .clear, size: CGSize(width: 30, height: 30))
        
        let read_img = UIImage(from: .fontAwesome, code: "bookmarko", textColor: .gray, backgroundColor: .clear, size: CGSize(width: 30, height: 30))
        let read_img_sel = UIImage(from: .fontAwesome, code: "bookmark", textColor: .gray, backgroundColor: .clear, size: CGSize(width: 30, height: 30))
        
        let me_img = UIImage(from: .segoeMDL2, code: "Contact", textColor: .gray, backgroundColor: .clear, size: CGSize(width: 30, height: 30))
        let me_img_sel = UIImage(from: .segoeMDL2, code: "ContactSolid", textColor: .gray, backgroundColor: .clear, size: CGSize(width: 30, height: 30))
        
        self.tabBar.unselectedItemTintColor = #colorLiteral(red: 0.325210184, green: 0.325210184, blue: 0.325210184, alpha: 1)
        
        dicNav.tabBarItem.image = dic_img.withRenderingMode(.alwaysTemplate)
        dicNav.tabBarItem.selectedImage = dic_img_sel.withRenderingMode(.alwaysTemplate)
        
        speechNav.tabBarItem.image = speech_img.withRenderingMode(.alwaysTemplate)
        speechNav.tabBarItem.selectedImage = speech_img_sel.withRenderingMode(.alwaysTemplate)
                
        writingNav.tabBarItem.image = writing_img.withRenderingMode(.alwaysTemplate)
        writingNav.tabBarItem.selectedImage = writing_img_sel.withRenderingMode(.alwaysTemplate)
        
        readNav.tabBarItem.image = read_img.withRenderingMode(.alwaysTemplate)
        readNav.tabBarItem.selectedImage = read_img_sel.withRenderingMode(.alwaysTemplate)
        
        myNav.tabBarItem.image = me_img.withRenderingMode(.alwaysTemplate)
        myNav.tabBarItem.selectedImage = me_img_sel.withRenderingMode(.alwaysTemplate)
        
        
        
        
//        dicNav.tabBarItem.icon(from: .fontAwesome, code: "book", iconColor: #colorLiteral(red: 0.3686772585, green: 0.6366325021, blue: 0.9931303859, alpha: 1), imageSize: CGSize(width: 20, height: 20), ofSize: 20)
//        speechNav.tabBarItem.icon(from: .fontAwesome, code: "comment", iconColor: #colorLiteral(red: 0.3686772585, green: 0.6366325021, blue: 0.9931303859, alpha: 1), imageSize: CGSize(width: 20, height: 20), ofSize: 20)
//        readNav.tabBarItem.icon(from: .fontAwesome, code: "tags", iconColor: #colorLiteral(red: 0.3686772585, green: 0.6366325021, blue: 0.9931303859, alpha: 1), imageSize: CGSize(width: 20, height: 20), ofSize: 20)
//        myNav.tabBarItem.icon(from: .fontAwesome, code: "user", iconColor: #colorLiteral(red: 0.3686772585, green: 0.6366325021, blue: 0.9931303859, alpha: 1), imageSize: CGSize(width: 20, height: 20), ofSize: 20)


        self.viewControllers = [dicNav, speechNav, writingNav, readNav, myNav]

        // 文字图片颜色一块修改
        self.tabBar.tintColor = UIColor.blue


//        self.selectedViewController = speechNav
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.title = item.title
    }

}
