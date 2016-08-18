//
//  ViewController.swift
//  CaptureDeo
//
//  Created by Sajjad Aboutalebi on 8/18/16.
//  Copyright © 2016 Sajjad Aboutalebi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLSessionDownloadDelegate {
    var destinationUrlForFile = URL(string: "a")
    override func viewDidLoad() {
        super.viewDidLoad()
        downloader()
        
        
    }
    
    func parseUrl() {
        let url = URL(string: "https://www.instagram.com/p/BJLVc2-j5yX/")
        let request = URLRequest(url: url!)
        _ = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                print(error)
            } else {
                let doc = TFHpple(htmlData: data as Data!)
                let elements = doc?.search(withXPathQuery: "//meta[@property='og:video:secure_url']") as? [TFHppleElement]
                if elements! == [] {
                    let imageElements = doc?.search(withXPathQuery: "//meta[@property='og:image']") as? [TFHppleElement]
                    for element in imageElements! {
                        print(element["content"])
                    }
                }else {
                    for element in elements! {
                        print(element["content"])
                    }
                }
            }
            
            
            }.resume()
        
    }
    
    
    
    func downloader() {
        let url = URL(string: "https://igcdn-photos-c-a.akamaihd.net/hphotos-ak-xpa1/t51.2885-15/s750x750/sh0.08/e35/14026751_2082333648659338_963951390_n.jpg?ig_cache_key=MTMxODg0ODIxMTIxMzI3MzgzOQ%3D%3D.2")
        var downloadTask = URLSessionDownloadTask()
        var backgroundSession = URLSession()
        let backgroundSessionConfig = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = URLSession(configuration: backgroundSessionConfig, delegate: self, delegateQueue: OperationQueue.main)
        downloadTask = backgroundSession.downloadTask(with: url!)
        downloadTask.resume()
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectoryPath: String = path[0]
        let fileManager = FileManager()
        destinationUrlForFile = URL(fileURLWithPath: documentDirectoryPath.appending((downloadTask.response?.suggestedFilename!)!))
        do {
            try fileManager.moveItem(at: location, to: destinationUrlForFile!)
            print("2")
        }catch {}
        if URL(fileURLWithPath: (downloadTask.response?.suggestedFilename!)!).pathExtension == "jpg"{
            saveImageToLibrary(path: (destinationUrlForFile?.path)!)
        }
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        
    }
    
    func saveVideoWithPath(path: String) {
        let isFileFound = FileManager.default.fileExists(atPath: path)
        print(isFileFound)
        deleteFileInTheEnd(path: path)
        let isFileFounda = FileManager.default.fileExists(atPath: path)
        print(isFileFounda)
        
    }
    
    func saveImageToLibrary(path: String) {
        let downloadedImage = UIImage(contentsOfFile: path)
        UIImageWriteToSavedPhotosAlbum(downloadedImage!, self, #selector(self.saveImage), nil)
        
    }
    
    func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) -> Void {
        if error == nil {
            displayAlert(title: "Saved!", msg: "Your altered image has been saved to your photos.")
            deleteFileInTheEnd(path: (destinationUrlForFile?.path)!)
        } else {
            displayAlert(title: "Opps!", msg: "Try Again")
        }
    }
    
    
    
    func deleteFileInTheEnd(path: String) {
        do {
            try FileManager.default.removeItem(atPath: path)
            print("deleted")
        } catch {}
    }
    
    func displayAlert(title: String, msg: String) {
        let ac = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(ac, animated: true, completion: nil)
    }
    
    
}
