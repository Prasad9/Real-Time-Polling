//
//  HomeVC.swift
//  FirebaseAdsPublisher
//
//  Created by Prasad Pai on 15/08/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
    
    @IBOutlet weak var channelsTableView: UITableView!
    
    var channelsArray: [String] = []
    
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
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(allChannelsNotification(_:)), name: kNotificationAllChannels, object: nil)
        notificationCenter.addObserver(self, selector: #selector(addedChannelNotification(_:)), name: kNotificationAddedChannel, object: nil)
    }
    
    private func listAllChannels() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        FirebaseManager.sharedInstance.fetchAllChannels()
    }
    
    private func addChannelWithName(channelName: String) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        FirebaseManager.sharedInstance.addChannelWithName(channelName)
    }
    
    // MARK: Selector methods
    func allChannelsNotification(notification: NSNotification) {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        if let channelsListArray = notification.userInfo as! [String: String]? {
            self.channelsArray = channelsListArray.keys.sort()
            self.channelsTableView.reloadData()
        }
    }
    
    func addedChannelNotification(notification: NSNotification) {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        if let userInfo = notification.userInfo as! [String: AnyObject]?,
            isAdded = userInfo["isAdded"] as! Bool? {
            guard isAdded else {
                if let error = userInfo["error"] as! NSError? {
                    self.simpleAlertViewWithTitle("Error", message: error.localizedDescription, btnTitle: "OK")
                }
                return
            }
            self.listAllChannels()
        }
    }
    
    // MARK: Action and Selector methods
    @IBAction func addChannelBtnTapped(sender: AnyObject) {
        let alert = UIAlertController(title: "Add Channel", message: "Enter the channel name", preferredStyle: UIAlertControllerStyle.Alert)
        var channelNameTextField: UITextField?
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            channelNameTextField = textField
            channelNameTextField?.placeholder = "Channel Name"
            channelNameTextField?.autocapitalizationType = UITextAutocapitalizationType.Words
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
        }
        alert.addAction(cancelAction)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { [weak self] (alertAction) -> Void in
            
            if let channelName = channelNameTextField?.text where channelName.characters.count > 0 {
                self?.addChannelWithName(channelName)
            }
        }
        alert.addAction(okAction)
        
        self.presentViewController(alert, animated: true) { () -> Void in
            
        }
    }
    
    @IBAction func resultBtnTapped(sender: AnyObject) {
        let btnTag = (sender as! UIButton).tag
        let resultsVC = ResultsVC.instantiateStoryboard()
        resultsVC.channelName = self.channelsArray[btnTag]
        self.navigationController?.pushViewController(resultsVC, animated: true)
    }
}

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: TableView Datasource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channelsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "ChannelCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! ChannelCell?
        cell?.channelLabel?.text = self.channelsArray[indexPath.row]
        cell?.resultsBtn.tag = indexPath.row
        return cell!
    }
    
    // MARK: TableView Delegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let addQuestionVC = AddQuestionVC.instantiateStoryboard()
        addQuestionVC.channelName = self.channelsArray[indexPath.row]
        self.navigationController?.pushViewController(addQuestionVC, animated: true)
    }
}
