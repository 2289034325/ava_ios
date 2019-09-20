//
//  Downloader.swift
//  Speech
//
//  Created by 菜白 on 2018/8/5.
//  Copyright © 2018年 Freedom. All rights reserved.
//

import UIKit
import SVProgressHUD

class Downloader: NSObject {
    static func loadFileAsync(url: URL, fileName:String, overWrite:Bool, completion: @escaping (String?, Error?) -> Void)
    {
        SVProgressHUD.show(withStatus: "正在下载···")
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let destinationUrl = documentsUrl.appendingPathComponent(fileName)
        
        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            if(!overWrite)
            {
                SVProgressHUD.dismiss()
                completion(destinationUrl.path, nil)
                return
            }
        }

        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request, completionHandler:
        {
            data, response, error in
            
            SVProgressHUD.dismiss()
            
            if error == nil
            {
                if let response = response as? HTTPURLResponse
                {
                    if response.statusCode == 200
                    {
                        if let data = data
                        {
                            if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                            {
                                completion(destinationUrl.path, error)
                            }
                            else
                            {
                                completion(destinationUrl.path, error)
                            }
                        }
                        else
                        {
                            completion(destinationUrl.path, error)
                        }
                    }
                }
            }
            else
            {
                completion(destinationUrl.path, error)
            }
        })
        task.resume()
    }
}
