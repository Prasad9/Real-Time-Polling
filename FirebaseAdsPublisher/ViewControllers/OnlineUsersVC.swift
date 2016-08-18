//
//  OnlineUsersVC.swift
//  FirebaseAdsPublisher
//
//  Created by Prasad Pai on 15/08/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import UIKit

class OnlineUsersVC: UIViewController {
    
    private var dataArray: [String] = []
    
    @IBOutlet weak var tableView: UITableView!

    // MARK: Class methods
    class func instantiateStoryboard() -> OnlineUsersVC {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let onlineUsersVC = storyBoard.instantiateViewControllerWithIdentifier("OnlineUsersVC") as! OnlineUsersVC
        return onlineUsersVC
    }
    
    // MARK: View Controller Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addObservers()
        self.listenToOnlineUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        FirebaseManager.sharedInstance.stopListeningToOnlineUsersCount()
    }
    
    // MARK: Action and selector methods
    @IBAction func closeBtnTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func onlineUsersNotification(notification: NSNotification) {
        self.dataArray = []
        if let userInfo = notification.userInfo as! [String: AnyObject]? {
            let channelsArray = Array(Set(userInfo.keys)).sort()
            for channel in channelsArray {
                let usersOnline = userInfo[channel] as! [String: Bool]
                let count = usersOnline.count
                let data = channel + " (\(count))"
                self.dataArray.append(data)
            }
        }
        self.tableView.reloadData()
    }
    
    // MARK: Private methods
    private func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onlineUsersNotification(_:)), name: kNotificationOnlineUsers, object: nil)
    }
    
    private func listenToOnlineUsers() {
        FirebaseManager.sharedInstance.listenToOnlineUsersCount()
    }
}

// MARK: Table View methods
extension OnlineUsersVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: TableView Data source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cellId"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        cell?.textLabel?.text = self.dataArray[indexPath.row]
        
        return cell!
    }
    
    // MARK: TableView Delegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
