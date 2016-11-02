//
//  DropboxFileListViewController.swift
//  projecthang
//
//  Created by toeinriver on 9/6/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

import Foundation
import UIKit
import SwiftyDropbox


@objc open class DropboxFileListViewController: UIViewController, UIApplicationDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView!
    var files: [String]!
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    
    open override func viewDidLoad() {
        width = UIScreen.main.bounds.width
        height = UIScreen.main.bounds.height
        tableView = UITableView.init(frame: CGRect(x: 0, y: 0, width: width, height: height - (self.tabBarController?.tabBar.frame.height)!))
        files = []        
        if DropboxClientsManager.authorizedClient == nil {
//            DropboxClientsManager.authorizeFromController(controller: self)
            DropboxClientsManager.authorizeFromController(UIApplication.shared, controller: self, openURL: {(url: URL) -> Void in UIApplication.shared.openURL(url)})
        }
        self.view.backgroundColor = UIColor.white
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
    }
    
    open class func setUpKey() {
        DropboxClientsManager.setupWithAppKey("ctkb9mj9h4ushlu")
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell! {
            return cell
        }
        else {
            let cell = UITableViewCell.init(style:.subtitle, reuseIdentifier: "cell")
            cell.textLabel?.text = self.files[(indexPath as NSIndexPath).row] as String
            return cell
        }
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count;
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped \(files[(indexPath as NSIndexPath).row])")
    }
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
   
    open override func viewDidAppear(_ animated: Bool) {
            let client = DropboxClientsManager.authorizedClient
            
            if (client) != nil {
                
                // Get the current user's account info
                client!.users.getCurrentAccount().response { response, error in
                    print()
                    print("*** Get current account ***")
                    if let account = response {
                        print("Hello \(account.name.givenName)!")
                    } else {
                        print(error!)
                    }
                }
                
                // List folder
                client!.files.listFolder(path: "").response { response, error in
                    print()
                    print("*** List folder ***")
                    if let result = response {
                        print("Folder contents:")
                        for entry in result.entries {
                            print(entry.name)
                            self.files.append(entry.name)
                        }
                        self.tableView.reloadData()
//                        UIApplication.sharedApplication().delegate = self.savedAppDelegate
                    } else {
                        print(error!)
                    }
                }
                
//                // Upload a file
//                let fileData = "Hello!".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
//                client!.files.upload(path: "/hello.txt", input: fileData!).response { response, error in
//                    if let metadata = response {
//                        print()
//                        print("*** Upload file ****")
//                        print("Uploaded file name: \(metadata.name)")
//                        print("Uploaded file revision: \(metadata.rev)")
//                        
//                        // Get file (or folder) metadata
//                        client!.files.getMetadata(path: "/hello.txt").response { response, error in
//                            print()
//                            print("*** Get file metadata ***")
//                            if let metadata = response {
//                                if let file = metadata as? Files.FileMetadata {
//                                    print("This is a file with path: \(file.pathLower)")
//                                    print("File size: \(file.size)")
//                                } else if let folder = metadata as? Files.FolderMetadata {
//                                    print("This is a folder with path: \(folder.pathLower)")
//                                }
//                            } else {
//                                print(error!)
//                            }
//                        }
//                        
//                        let destination : (NSURL, NSHTTPURLResponse) -> NSURL = { temporaryURL, response in
//                            let fileManager = NSFileManager.defaultManager()
//                            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
//                            // generate a unique name for this file in case we've seen it before
//                            let UUID = NSUUID().UUIDString
//                            let pathComponent = "\(UUID)-\(response.suggestedFilename!)"
//                            return directoryURL.URLByAppendingPathComponent(pathComponent)
//                        }
//                        
//                        // Download a file to disk
//                        
//                        client!.files.download(path: "/hello.txt", destination: destination).response { response, error in
//                            if let (metadata, url) = response {
//                                print()
//                                print("*** Downloaded file to disk ***")
//                                let data = NSData(contentsOfURL: url)
//                                print("Downloaded file name: \(metadata.name)")
//                                print("Downloaded file url: \(url)")
//                                print("Downloaded file data: \(data)")
//                                
//                                // Download a file to memory
//                                
//                                client!.files.download(path: "/hello.txt").response { response, error in
//                                    if let (metadata, data) = response {
//                                        print()
//                                        print("*** Downloaded file to memory ***")
//                                        print("Downloaded file name: \(metadata.name)")
//                                        print("Downloaded file data: \(data)")
//                                        print()
//                                    } else {
//                                        print(error!)
//                                    }
//                                }
//                            } else {
//                                print(error!)
//                            }
//                        }
//                    } else {
//                        print(error!)
//                    }
//                }
            }
    }
    
    @objc open class func run_application(_ app: UIApplication, openURL url: URL, options: [String : AnyObject]) -> Bool {
//        if let authResult = DropboxOAuthManager.handleRedirectURL(url) {
//            switch authResult {
//            case .Success(let token):
//                print("Success! User is logged into Dropbox with token: \(token)")
//            case .Cancel:
//                print("Authorization flow was manually canceled by user.")
//            case .Error(let error, let description):
//                print("Error \(error): \(description)")
//            }
//        }
        
        return false
    }
}
