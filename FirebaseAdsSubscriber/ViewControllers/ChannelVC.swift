//
//  ChannelVC.swift
//  FirebaseAdsSubscriber
//
//  Created by Prasad Pai on 8/16/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import UIKit

class ChannelVC: UIViewController, OverlayProtocol {
    
    var channelName: String?
    
    private var snapshotData: [Int: AnyObject] = [:]
    
    @IBOutlet weak var channelNameLabel: UILabel!
    
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var optionBtn1: UIButton!
    @IBOutlet weak var optionBtn2: UIButton!
    @IBOutlet weak var optionBtn3: UIButton!
    @IBOutlet weak var optionBtn4: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    
    private var selectedOption = 0
    private var selectedOverlayIndex: Int?
    
    // MARK: Class methods
    class func instantiateStoryboard() -> ChannelVC {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let channelVC = storyBoard.instantiateViewControllerWithIdentifier("ChannelVC") as! ChannelVC
        return channelVC
    }
    
    // MARK: View Controller Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.channelName
        
        self.addObservers()
        self.makeUISetup()
        self.registerUserAsOnline()
        self.listenToPresentQuestions()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        FirebaseManager.sharedInstance.stopListeningToQuestions()
        self.unregisterUserAsOnline()
    }
    
    // MARK: Private methods
    private func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(receivedQuestionNotification(_:)), name: kNotificationReceivedQuestion, object: nil)
    }
    
    private func makeUISetup() {
        self.channelNameLabel.text = channelName
    }
    
    private func listenToPresentQuestions() {
        if let channelName = self.channelName {
            FirebaseManager.sharedInstance.listenToQuestionsInChannel(channelName)
        }
    }
    
    private func createOverlayViewWith(overlayData: [String: AnyObject]) {
        if let durationTime = overlayData[QuestionText.Duration.getDictKeyTitle()] as! Double? {
            let count = self.snapshotData.count
            self.snapshotData[count] = overlayData
            let overlayView = OverlayView()
            overlayView.overlayDelegate = self
            overlayView.frame = CGRect(x: 0.0, y: 0.0, width: kOverlayBtnWidth, height: kOverlayBtnWidth)
            if let spawnX = overlayData[QuestionText.SpawnX.getDictKeyTitle()] as! Double?,
                spawnY = overlayData[QuestionText.SpawnX.getDictKeyTitle()] as! Double? {
                let screenWidth = UIScreen.mainScreen().bounds.width
                let screenHeight = UIScreen.mainScreen().bounds.height - 64.0
                let centerX = CGFloat((spawnX >= 0.0 && spawnX <= 100.0) ? spawnX : 50.0) / 100.0 * screenWidth
                let centerY = CGFloat((spawnY >= 0.0 && spawnY <= 100.0) ? spawnY : 50.0) / 100.0 * screenHeight
                overlayView.center = CGPoint(x: centerX, y: centerY)
            }
            self.view.addSubview(overlayView)
            overlayView.createOverlayViewWithIndex(count, dismissOverlayAfter: durationTime / 1000)
        }
    }
    
    private func registerUserAsOnline() {
        if let channelName = self.channelName {
            FirebaseManager.sharedInstance.registerUserAsOnlineInChannel(channelName)
        }
    }
    
    private func unregisterUserAsOnline() {
        FirebaseManager.sharedInstance.unregisterUserAsOnline()
    }

    // MARK: Action and Selector methods
    @IBAction func closeBtnTapped() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func questionCloseBtnTapped(sender: AnyObject) {
        self.questionView.hidden = true
    }
    
    @IBAction func optionBtnTapped(sender: AnyObject) {
        let btnTag = (sender as! UIButton).tag
        if btnTag == self.selectedOption {
            self.selectedOption = 0
            self.submitBtn.enabled = false
            let previousBtn = self.getOptionBtnWithTag(btnTag)
            previousBtn.layer.borderColor = UIColor.clearColor().CGColor
        }
        else {
            self.submitBtn.enabled = true
            if self.selectedOption > 0 {
                let previousBtn = self.getOptionBtnWithTag(self.selectedOption)
                previousBtn.layer.borderColor = UIColor.clearColor().CGColor
            }
            
            self.selectedOption = btnTag
            let presentBtn = self.getOptionBtnWithTag(self.selectedOption)
            presentBtn.layer.borderColor = UIColor.blackColor().CGColor
            presentBtn.layer.borderWidth = 2.0
        }
    }
    
    @IBAction func submitBtnTapped(sender: AnyObject) {
        if let channelName = self.channelName,
            selectedOverlayIndex = self.selectedOverlayIndex,
            overlayData = self.snapshotData[selectedOverlayIndex] as! [String: AnyObject]?,
            questionId = overlayData[kKeyQuestionId] as! Int? {
            FirebaseManager.sharedInstance.uploadAnswerWithOptionNo(self.selectedOption, forQuestion: questionId, inChannel: channelName)
                self.questionView.hidden = true
        }
    }
    
    func receivedQuestionNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo as! [String: AnyObject]? {
            self.createOverlayViewWith(userInfo)
        }
    }
    
    // MARK: Overlay Protocol methods
    func overlayViewBtnTapped(index: Int) {
        if let overlayData = self.snapshotData[index] as! [String: AnyObject]? {
            self.questionTitleLabel.text = overlayData[QuestionText.Title.getDictKeyTitle()] as? String
            self.questionLabel.text = overlayData[QuestionText.Question.getDictKeyTitle()] as? String
            self.optionBtn1.setTitle(overlayData[QuestionText.Option1.getDictKeyTitle()] as? String, forState: UIControlState.Normal)
            self.optionBtn2.setTitle(overlayData[QuestionText.Option2.getDictKeyTitle()] as? String, forState: UIControlState.Normal)
            if let option3 = overlayData[QuestionText.Option3.getDictKeyTitle()] as! String? {
                self.optionBtn3.setTitle(option3, forState: UIControlState.Normal)
                self.optionBtn3.hidden = false
            }
            else {
                self.optionBtn3.hidden = true
            }
            if let option4 = overlayData[QuestionText.Option4.getDictKeyTitle()] as! String? {
                self.optionBtn4.setTitle(option4, forState: UIControlState.Normal)
                self.optionBtn4.hidden = false
            }
            else {
                self.optionBtn4.hidden = true
            }
            
            self.optionBtn1.layer.borderColor = UIColor.clearColor().CGColor
            self.optionBtn2.layer.borderColor = UIColor.clearColor().CGColor
            self.optionBtn3.layer.borderColor = UIColor.clearColor().CGColor
            self.optionBtn4.layer.borderColor = UIColor.clearColor().CGColor
            
            self.submitBtn.enabled = false
            self.selectedOption = 0
            self.selectedOverlayIndex = index
            self.questionView.hidden = false
        }
    }
    
    // MARK: Utility methods
    private func getOptionBtnWithTag(tag: Int) -> UIButton {
        let btn = self.view.viewWithTag(tag) as! UIButton
        return btn
    }
}
