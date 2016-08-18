//
//  HomeVC.swift
//  FirebaseAdsSubscriber
//
//  Created by Prasad Pai on 8/16/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
    
    @IBOutlet private weak var channelsTableView: UITableView!
    
    private var channelsArray: [String] = []
    
    // MARK: Class methods
    class func instantiateStoryboard() -> HomeVC {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let homeVC = storyBoard.instantiateViewControllerWithIdentifier("HomeVC") as! HomeVC
        return homeVC
    }
    
    // MARK: View Controller Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addObservers()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.listAllChannels()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Private methods
    private func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(allChannelsNotification(_:)), name: kNotificationAllChannels, object: nil)
    }
    
    private func listAllChannels() {
        if self.channelsArray.count == 0 {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
        
        FirebaseManager.sharedInstance.fetchAllChannels()
    }
    
    // MARK: Selector methods
    func allChannelsNotification(notification: NSNotification) {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        if let channelsListArray = notification.userInfo as! [String: String]? {
            self.channelsArray = channelsListArray.keys.sort()
            self.channelsTableView.reloadData()
        }
    }
}

// MARK: TableView methods
extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: TableView Datasource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channelsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "ChannelCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        cell?.textLabel?.text = self.channelsArray[indexPath.row]
        return cell!
    }
    
    // MARK: TableView Delegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let channelVC = ChannelVC.instantiateStoryboard()
        channelVC.channelName = self.channelsArray[indexPath.row]
        self.navigationController?.pushViewController(channelVC, animated: true)
    }
}
