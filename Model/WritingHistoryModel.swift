//
//  UserModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import ObjectMapper
import Foundation

class WritingHistoryModel: Mappable,Codable {
    var id:String = ""
    var article_id:String?
    var paragraph_id:String?
    var split_id:String?
    var score:Float?
    var content:String?
    var submit_time:Date?
    var diffs = [DiffModel]()
    
    enum CodingKeys: String, CodingKey {
        case id
        case article_id
        case paragraph_id
        case split_id
        case score
        case content
        case submit_time
    }
        
    let df : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
    
    init(){
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        article_id <- map["article_id"]
        paragraph_id <- map["paragraph_id"]
        split_id <- map["split_id"]
        score <- map["score"]
        content <- map["content"]
        submit_time <- (map["submit_time"], DateFormatterTransform(dateFormatter: df))
        submit_time <- (map["submit_time"],DateFormatterTransform(dateFormatter: df))
        diffs <- map["diffs"]
                
        if(diffs == nil){
            diffs = []
        }
    }
    
    func getDiffText(font: UIFont)->NSMutableAttributedString?{
        
        let delAttribute = [ NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.002568773798, green: 0.9046637056, blue: 0.003985686436, alpha: 1),
                             NSAttributedStringKey.font: font] as [NSAttributedStringKey : Any]
        let insAttribute = [ NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.9141814721, green: 0.1367531477, blue: 0.007898330018, alpha: 1),
                             NSAttributedStringKey.strikethroughStyle: NSUnderlineStyle.styleSingle.rawValue,
                             NSAttributedStringKey.font: font] as [NSAttributedStringKey : Any]
        let warningAttribute = [ NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.8683772208, green: 0.8559111588, blue: 0.005484322231, alpha: 1),
                            NSAttributedStringKey.strikethroughStyle: NSUnderlineStyle.styleSingle.rawValue,
                            NSAttributedStringKey.font: font] as [NSAttributedStringKey : Any]
        let nomAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.black,
                             NSAttributedStringKey.font: font]
        
        var myAttrString:NSMutableAttributedString? = nil
        self.diffs.forEach { (df) in
            let aString:NSMutableAttributedString
            if(df.operation == "DELETE"){
                aString = NSMutableAttributedString(string: df.text!, attributes: delAttribute)
            }
            else if(df.operation == "INSERT"){
                aString = NSMutableAttributedString(string: df.text!, attributes: insAttribute)
            }
            else if(df.operation == "WARNING_ORIGIN"){
                aString = NSMutableAttributedString(string: df.text!, attributes: delAttribute)
            }
            else if(df.operation == "WARNING"){
                aString = NSMutableAttributedString(string: df.text!, attributes: warningAttribute)
            }
            else{
                aString = NSMutableAttributedString(string: df.text!, attributes: nomAttribute)
            }
            
            if(myAttrString == nil){
                myAttrString = aString
            }
            else{
                myAttrString?.append(aString)
            }
        }
        
        return myAttrString
    }
}
