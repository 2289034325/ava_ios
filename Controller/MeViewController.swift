//
//  UserBookViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/8/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import SnapKit

import Alamofire
import AlamofireObjectMapper

import MJRefresh

import SVProgressHUD


var setting_FM_key = "settings_FM"
var setting_Sentence_key = "settings_Sentence"

class MeViewController: UITableViewController {
    
    var setting_FM_value = false
    var setting_Sentence_value = false
    
    override func viewDidLoad() {
        regClass(tableView, cell: MeDefaultTableViewCell.self)
        regClass(tableView, cell: MeCheckboxTableViewCell.self)
        regClass(tableView, cell: MeSpliterTableViewCell.self)
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorStyle = .none
        
        if let v = V2EXSettings.sharedInstance[setting_FM_key]{
            setting_FM_value = Bool(v)!
        }
        if let v = V2EXSettings.sharedInstance[setting_Sentence_key]{
            setting_Sentence_value = Bool(v)!
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 50
        }
        else if(indexPath.row == 1){
            return 10
        }
        else if(indexPath.row == 2){
            return 50
        }
        else if(indexPath.row == 3){
            return 50
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            V2EXSettings.sharedInstance[kUserToken] = ""
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window!.rootViewController = LoginViewController()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        if(indexPath.row == 0){
            let c = getCell(tableView, cell: MeDefaultTableViewCell.self, indexPath: indexPath) as MeDefaultTableViewCell
            c.bind(text: "退出登陆")
            cell = c
        }
        else if(indexPath.row == 1){
            let c = getCell(tableView, cell: MeSpliterTableViewCell.self, indexPath: indexPath)
            c.selectionStyle = UITableViewCellSelectionStyle.none
        }
        else if(indexPath.row == 2){
            let c = getCell(tableView, cell: MeCheckboxTableViewCell.self, indexPath: indexPath) as MeCheckboxTableViewCell
            c.bind(text: "翻译",value: setting_FM_value)
            c.chk.removeActions()
            c.chk.addAction(for: UIControl.Event.valueChanged) {
                V2EXSettings.sharedInstance[setting_FM_key] = String(c.chk.isOn)
            }
            c.selectionStyle = UITableViewCellSelectionStyle.none
            cell = c
        }
        else if(indexPath.row == 3){
            let c = getCell(tableView, cell: MeCheckboxTableViewCell.self, indexPath: indexPath) as MeCheckboxTableViewCell
            c.bind(text: "例句",value: setting_Sentence_value)
            c.chk.removeActions()
            c.chk.addAction(for: UIControl.Event.valueChanged) {
                V2EXSettings.sharedInstance[setting_Sentence_key] = String(c.chk.isOn)
            }
            c.selectionStyle = UITableViewCellSelectionStyle.none
            cell = c
        }
        
        return cell
    }
}
