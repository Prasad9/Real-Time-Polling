////
////  OnlineUsersVC.swift
////  FirebaseAdsPublisher
////
////  Created by Prasad Pai on 15/08/16.
////  Copyright © 2016 YMedia Labs. All rights reserved.
////
//
//import UIKit
//
//class OnlineUsersVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
//    
//    private var firebaseRef: Firebase?
//    private var firebaseHandle: UInt?
//    private var dataArray: [String]?
//    
//    @IBOutlet weak var tableView: UITableView!
//
//    // MARK: Class methods
//    class func instantiateStoryboard() -> OnlineUsersVC {
//        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//        let onlineUsersVC = storyBoard.instantiateViewControllerWithIdentifier("OnlineUsersVC") as! OnlineUsersVC
//        return onlineUsersVC
//    }
//    
//    // MARK: View Controller Life Cycle methods
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.listenToOnlineUsers()
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    deinit {
//        if let firebaseHandle = self.firebaseHandle {
//            self.firebaseRef?.removeObserverWithHandle(firebaseHandle)
//        }
//    }
//    
//    // MARK: Action and selector methods
//    @IBAction func closeBtnTapped(sender: AnyObject) {
//        self.navigationController?.popViewControllerAnimated(true)
//    }
//    
//    // MARK: Private methods
//    private func listenToOnlineUsers() {
//        let url = kBaseHandle + kChannelsOnlineUsers
//        self.firebaseRef = Firebase(url: url)
//        if let query = self.firebaseRef?.queryOrderedByKey() {
//            self.firebaseHandle = query.observeEventType(FEventType.Value, withBlock: { [weak self] (snapshot: FDataSnapshot!) -> Void in
//                guard snapshot.exists() else {
//                    self?.dataArray = nil
//                    dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
//                        self?.tableView.reloadData()
//                    })
//                    return
//                }
//                
//                self?.dataArray = []
//                let onlineUsersListArray = snapshot.value as! [String: AnyObject]
//                let channelsArray = Array(onlineUsersListArray.keys).sort()
//                for key in channelsArray {
//                    let usersArray = onlineUsersListArray[key] as! [String: Int]
//                    let onlineCount = usersArray.count
//                    let text = key + " (" + String(onlineCount) + ")"
//                    self?.dataArray?.append(text)
//                }
//                
//                dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
//                    self?.tableView.reloadData()
//                })
//            })
//        }
//    }
//    
//    // MARK: TableView Data source methods
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let count = self.dataArray?.count {
//            return count
//        }
//        return 0
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cellId = "cellId"
//        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
//        if cell == nil {
//            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
//        }
//        if let dataText = self.dataArray?[indexPath.row] {
//            cell?.textLabel?.text = dataText
//        }
//        
//        return cell!
//    }
//    
//    // MARK: TableView Delegate methods
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//    }
//    
//}
