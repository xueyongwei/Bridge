//
//  ViewController.swift
//  CaptureDeo
//
//  Created by Sajjad Aboutalebi on 8/18/16.
//  Copyright © 2016 Sajjad Aboutalebi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLSessionDownloadDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var sizeLabel: UILabel!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var downloadingLabel: UILabel!
    
    @IBAction func downloadBtn(_ sender: AnyObject) {
        if textField.text == "" {
            displayAlert(title: "Opps!", msg: "Please enter Link.")
        }else {
            parseUrl(url: textField.text!)
            self.view.endEditing(true)
            downloadingLabel.isHidden = false
            indicator.isHidden = false
            indicator.startAnimating()
        }
        
    }
    var destinationUrlForFile = URL(string: "a")
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        progressBar.isHidden = true
        sizeLabel.isHidden = true
        downloadingLabel.isHidden = true
        indicator.isHidden = true
        
        
    }
    
    func parseUrl(url: String) {
        let url = URL(string: url)
        _ = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                self.displayAlert(title: "Opps!", msg: "Invalid link")
                
            } else {
                let doc = TFHpple(htmlData: data as Data!)
                let elements = doc?.search(withXPathQuery: "//meta[@property='og:video:secure_url']") as? [TFHppleElement]
                if elements! == [] {
                    let imageElements = doc?.search(withXPathQuery: "//meta[@property='og:image']") as? [TFHppleElement]
                    if imageElements! == [] {
                        self.displayAlert(title: "Opps!", msg: "Nothing found!")
                    }else {
                        for element in imageElements! {
                            self.downloader(url: element["content"] as! String)
                        }
                    }
                    
                }else {
                    for element in elements! {
                        self.downloader(url: element["content"] as! String)
                    }
                }

            }

        }).resume()
        
    }
 
 
    func downloader(url: String) {
        let url = URL(string: url)
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
        }catch {}
        if URL(fileURLWithPath: (downloadTask.response?.suggestedFilename!)!).pathExtension == "jpg" {
            saveImageToLibrary(path: (destinationUrlForFile?.path)!)
        } else if URL(fileURLWithPath: (downloadTask.response?.suggestedFilename!)!).pathExtension == "mp4" {
            saveVideoWithPath(path: destinationUrlForFile!.path)
            
        }
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        progressBar.isHidden = false
        sizeLabel.isHidden = false
        sizeLabel.text = "\(round(Double(totalBytesWritten)/1048576*100)/100) MB of \(round(Double(totalBytesExpectedToWrite)/1048576*100)/100) MB"
        progressBar.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
        
        
    }
    
    func saveVideoWithPath(path: String) {
        UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(self.saveVideo), nil)
        
        
    }
    func saveVideo(video: String, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if error != nil {
            print(error)
        }else {
            displayAlert(title: "Saved!", msg: "Your altered video has been saved to your photos.")
            deleteFileInTheEnd(path: destinationUrlForFile!.path)
        }
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
        } catch {}
    }
    
    func displayAlert(title: String, msg: String) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(ac, animated: true, completion: nil)
            self.hideStuff()
            }
    }
    
    func hideStuff() {
        downloadingLabel.isHidden = true
        indicator.stopAnimating()
        indicator.isHidden = true
        progressBar.isHidden = true
        sizeLabel.isHidden = true
    }
    
    
}
