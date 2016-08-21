//
//  ResultsVC.swift
//  FirebaseAdsPublisher
//
//  Created by Prasad Pai on 15/08/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import UIKit

class ResultsVC: UIViewController {
    
    var channelName: String?
    
    private var questionsArray: [[String: AnyObject]] = []

    private var timer: NSTimer?
    private var currentTimeLeft = -1
    
    private var clickedQuestionIndex: Int = 0
    private var option1Count = 0
    private var option2Count = 0
    private var option3Count = 0
    private var option4Count = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var option1Label: UILabel!
    @IBOutlet weak var option2Label: UILabel!
    @IBOutlet weak var option3Label: UILabel!
    @IBOutlet weak var option4Label: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!

    // MARK: Class methods
    class func instantiateStoryboard() -> ResultsVC {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let resultsVC = storyBoard.instantiateViewControllerWithIdentifier("ResultsVC") as! ResultsVC
        return resultsVC
    }
    
    // MARK: View Controller Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addObservers()
        self.listenToQuestions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.stopOptionFirebaseRefs()
    }
    
    // MARK: Private methods
    private func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(fetchedQuestionsNotification(_:)), name: kNotificationFetchedQuestions, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(fetchedAnswersNotification(_:)), name: kNotificationFetchedAnswers, object: nil)
    }
    
    private func listenToQuestions() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        if let channelName = self.channelName {
            FirebaseManager.sharedInstance.fetchAllQuestionsInChannel(channelName)
        }
    }
    
    private func openResultViewAtIndex(index: Int) {
        let questionData = self.questionsArray[index]
        if let questionId = questionData[kKeyQuestionId] as! Int?,
            title = questionData[QuestionText.Title.getDictKeyTitle()] as! String?,
            question = questionData[QuestionText.Question.getDictKeyTitle()] as! String?,
            duration = questionData[QuestionText.Duration.getDictKeyTitle()] as! Int?,
            channelName = self.channelName {
                self.questionTitleLabel.text = title
                self.questionLabel.text = question
                let endsAt = duration + questionId
                let currentTimeStamp = Int(NSDate().timeIntervalSince1970 * 1000)
                let graceTimeMilliSec = kConstGraceSecTimeAllowed * 1000
                if currentTimeStamp < endsAt + graceTimeMilliSec {
                    let timeLeft = (endsAt - currentTimeStamp) / 1000
                    self.timeLeftLabel.text = "Voting ends in \(timeLeft) seconds"
                    self.currentTimeLeft = timeLeft
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(timerHit(_:)), userInfo: nil, repeats: true)
                }
                else {
                    self.timeLeftLabel.text = "Voting is over"
                }
            
                self.option1Count = 0
                self.option2Count = 0
                self.option3Count = 0
                self.option4Count = 0
            
                let isContinous = currentTimeStamp < endsAt + graceTimeMilliSec
                if let option1LabelBaseText = questionData[QuestionText.Option1.getDictKeyTitle()] as! String? {
                    self.option1Label.text = option1LabelBaseText
                }
                if let option2LabelBaseText = questionData[QuestionText.Option2.getDictKeyTitle()] as! String? {
                    self.option2Label.text = option2LabelBaseText
                }
            
                var totalOptions = 2
                if let option3LabelBaseText = questionData[QuestionText.Option3.getDictKeyTitle()] as! String? {
                    self.option3Label.text = option3LabelBaseText
                    totalOptions += 1
                    self.option3Label.hidden = false
                }
                else {
                    self.option3Label.hidden = true
                }
                if let option4LabelBaseText = questionData[QuestionText.Option4.getDictKeyTitle()] as! String? {
                    self.option4Label.text = option4LabelBaseText
                    totalOptions += 1
                    self.option4Label.hidden = false
                }
                else {
                    self.option4Label.hidden = true
                }
                FirebaseManager.sharedInstance.listenToFirebaseAnswers(isContinous, inChannel: channelName, questionId: questionId, totalOptions: totalOptions)
                self.resultView.hidden = false
        }
    }
    
    private func stopOptionFirebaseRefs() {
        FirebaseManager.sharedInstance.stopContinousFirebaseAnswers()
    }
    
    // MARK: Action and selector methods
    @IBAction func closeBtnTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func resultViewCloseBtnTapped(sender: AnyObject) {
        self.resultView.hidden = true
        self.stopOptionFirebaseRefs()
    }
    
    func fetchedQuestionsNotification(notification: NSNotification) {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        if let userInfo = notification.userInfo as! [String: [String: AnyObject]]? {
            self.questionsArray = Array(userInfo.values).sort{
                ((($0)[kKeyQuestionId] as? Int) > (($1)[kKeyQuestionId] as? Int))
            }
        }
        else {
            self.questionsArray = []
        }
        self.tableView.reloadData()
    }
    
    func fetchedAnswersNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo as! [String: AnyObject]?,
            isContinuous = userInfo[kConstIsContinuous] as! Bool?,
            index = userInfo[kConstIndex] as! Int?,
            count = userInfo[kConstCount] as! Int? {
            switch index {
            case 1:
                let baseText = self.questionsArray[self.clickedQuestionIndex][QuestionText.Option1.getDictKeyTitle()] as! String? ?? ""
                self.option1Count = isContinuous ? self.option1Count + 1 : count
                self.option1Label.text = baseText + " (\(self.option1Count))"
            case 2:
                let baseText = self.questionsArray[self.clickedQuestionIndex][QuestionText.Option2.getDictKeyTitle()] as! String? ?? ""
                self.option2Count = isContinuous ? self.option2Count + 1 : count
                self.option2Label.text = baseText + " (\(self.option2Count))"
            case 3:
                let baseText = self.questionsArray[self.clickedQuestionIndex][QuestionText.Option2.getDictKeyTitle()] as! String? ?? ""
                self.option3Count = isContinuous ? self.option3Count + 1 : count
                self.option3Label.text = baseText + " (\(self.option3Count))"
            case 4:
                let baseText = self.questionsArray[self.clickedQuestionIndex][QuestionText.Option2.getDictKeyTitle()] as! String? ?? ""
                self.option4Count = isContinuous ? self.option4Count + 1 : count
                self.option4Label.text = baseText + " (\(self.option4Count))"
            default:
                break
            }
        }
    }
    
    func timerHit(decreaseTimer: NSTimer) {
        self.currentTimeLeft -= 1
        if self.currentTimeLeft > 0 {
            self.timeLeftLabel.text = "Voting ends in \(self.currentTimeLeft) seconds"
        }
        else {
            self.timeLeftLabel.text = "Voting is over"
            self.timer?.invalidate()
            self.timer = nil
            self.stopOptionFirebaseRefs()
        }
    }
}

// MARK: Table View methods
extension ResultsVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: TableView Data source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questionsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cellId"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        let questionObject = self.questionsArray[indexPath.row]
        if let questionTitle = questionObject[QuestionText.Title.getDictKeyTitle()] as! String? {
            cell?.textLabel?.text = questionTitle
        }
        return cell!
    }
    
    // MARK: TableView Delegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.clickedQuestionIndex = indexPath.row
        self.openResultViewAtIndex(indexPath.row)
    }
}
