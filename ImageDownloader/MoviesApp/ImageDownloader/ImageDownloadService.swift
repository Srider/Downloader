//
//  CountriesService.swift
//  Countries
//
//  Created by Honeywell on 10/11/17.
//  Copyright © 2017 Honeywell. All rights reserved.
//

import UIKit




class ImageDownloadService:Operation {
    
    @objc var dictData:NSMutableDictionary!
    var mServiceURL: String!
    var mRequest:NSMutableURLRequest!
    var json:AnyObject!
    var objDownloadTask: URLSessionDownloadTask?
    var objDownloadDetail:DownloadDetail!
    
    init(_ objDownloadDetail:DownloadDetail!) {
        self.objDownloadDetail = objDownloadDetail
        self.mServiceURL = self.objDownloadDetail.strDownloadURL
        self.dictData = NSMutableDictionary.init()
    }
    
    //MARK: prepareRequest()->(NSMutableURLRequest)
    func prepareRequest()->(NSMutableURLRequest) {
        let tempRequest:NSMutableURLRequest! = NSMutableURLRequest.init()
        tempRequest.timeoutInterval = Constants.Timeout.kNetworkTimeout
        tempRequest.cachePolicy = .useProtocolCachePolicy
        tempRequest.httpMethod = Constants.RequestParam.kURLRequestType
        tempRequest.setValue(Constants.RequestParam.kURLRequestContentValue, forHTTPHeaderField: Constants.RequestParam.kURLRequestContentType)
        
        return tempRequest
    }
    
    //MARK: main()
    override func main() {
        
        /* Call Preparerequest on BaseService */
        self.mRequest = self.prepareRequest()
        
        /* If Service is cancelled by any chance return */
        if self.isCancelled {
            return
        }
        
        /* Get request from URL String */
        self.mRequest.url = URL(string: self.mServiceURL)
        
        /* Fire Request using URLSession's dataTask API call */
        self.objDownloadTask = URLSession.shared.downloadTask(with: self.mRequest.url!, completionHandler: { (url, response, error) in
            print("*********************Completion Handler*********************")
            print("URL - \(String(describing: url?.absoluteString))")
            if error == nil {
                self.objDownloadDetail.eDownloadStatus = DownloadStatus.downloaded
                self.objDownloadDetail.strDownloadLocation = url
                self.objDownloadDetail.dImageData = try? Data(contentsOf: self.objDownloadDetail.strDownloadLocation!)
            
                self.dictData.setObject(self.objDownloadDetail as DownloadDetail, forKey: "download_detail" as NSCopying)
                
                
                /* Send Success Notification */
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name:Notification.Name(rawValue:Constants.Notifications.kNetworkOperationSuccess), object: self.dictData, userInfo: nil)
                }
            } else {
                print("Error - \(String(describing: error))")
                
                self.objDownloadDetail.eDownloadStatus = DownloadStatus.failed
                self.dictData.setObject(self.objDownloadDetail as DownloadDetail, forKey: "download_detail" as NSCopying)
                
                /* Send Failure Notification */
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name:Notification.Name(rawValue:Constants.Notifications.kNetworkOperationFailure), object: self.dictData, userInfo: nil)
                }
            }
        })
        
        /*Resume Task */
        self.objDownloadTask?.resume()
        
    }
}


