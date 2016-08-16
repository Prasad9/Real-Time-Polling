////
////  ResultsVC.swift
////  FirebaseAdsPublisher
////
////  Created by Prasad Pai on 15/08/16.
////  Copyright © 2016 YMedia Labs. All rights reserved.
////
//
//import UIKit
//import Firebase
//
//class ResultsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
//    
//    var channelName: String?
//    
//    private var questionsArray: [[String: AnyObject]]? = []
//    
//    private var firebaseRef: Firebase?
//    private var firebaseHandle: UInt?
//    
//    private var option1FirebaseRef: Firebase?
//    private var option1FirebaseHandle: UInt?
//    private var option2FirebaseRef: Firebase?
//    private var option2FirebaseHandle: UInt?
//    private var option3FirebaseRef: Firebase?
//    private var option3FirebaseHandle: UInt?
//    private var option4FirebaseRef: Firebase?
//    private var option4FirebaseHandle: UInt?
//    private var timer: NSTimer?
//    private var currentTimeLeft = -1
//    
//    @IBOutlet weak var tableView: UITableView!
//    
//    @IBOutlet weak var resultView: UIView!
//    @IBOutlet weak var questionTitleLabel: UILabel!
//    @IBOutlet weak var questionLabel: UILabel!
//    @IBOutlet weak var option1Label: UILabel!
//    @IBOutlet weak var option2Label: UILabel!
//    @IBOutlet weak var option3Label: UILabel!
//    @IBOutlet weak var option4Label: UILabel!
//    @IBOutlet weak var timeLeftLabel: UILabel!
//
//    // MARK: Class methods
//    class func instantiateStoryboard() -> ResultsVC {
//        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//        let resultsVC = storyBoard.instantiateViewControllerWithIdentifier("ResultsVC") as! ResultsVC
//        return resultsVC
//    }
//    
//    // MARK: View Controller Life Cycle methods
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.listenToPastValidQuestions()
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
//        self.stopOptionFirebaseRefs()
//    }
//    
//    // MARK: Private methods
//    private func listenToPastValidQuestions() {
//        if let channelName = self.channelName {
//            let url = kBaseHandle + channelName + kChannelsQuiz
//            self.firebaseRef = Firebase(url: url)
//            self.firebaseRef?.observeSingleEventOfType(FEventType.Value, withBlock: { [weak self] (snapshot: FDataSnapshot!) -> Void in
//                guard snapshot.exists() else {
//                    self?.listenToUpcomingQuestions()
//                    return
//                }
//                
//                let questions = snapshot.value as! [String: AnyObject]
//                let keys = Array(questions.keys).sort()
//                
//                for key in keys {
//                    let questionData = questions[key] as! [String: AnyObject]
//                    self?.questionsArray?.insert(questionData, atIndex: 0)
//                }
//                dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
//                    self?.tableView.reloadData()
//                    self?.listenToUpcomingQuestions()
//                })
//                }, withCancelBlock: { (error: NSError!) -> Void in
//                    
//            })
//        }
//    }
//    
//    private func listenToUpcomingQuestions() {
//        let presentTimeStamp = String(Int(floor(NSDate().timeIntervalSince1970)))
//        if let questionsQuery = self.firebaseRef?.queryOrderedByKey().queryStartingAtValue(presentTimeStamp) {
//            self.firebaseHandle = questionsQuery.observeEventType(FEventType.ChildAdded, withBlock: { [weak self] (snapshot: FDataSnapshot!) -> Void in
//                guard snapshot.exists() else {
//                    return
//                }
//                
//                let questionData = snapshot.value as! [String: AnyObject]
//                self?.questionsArray?.insert(questionData, atIndex: 0)
//                dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
//                    self?.tableView.reloadData()
//                })
//                
//                }, withCancelBlock: { (error: NSError!) -> Void in
//                    
//            })
//        }
//    }
//    
//    private func openResultViewAtIndex(index: Int) {
//        if let questionData = self.questionsArray?[index],
//            questionId = questionData[kKeyQuestionId] as! Int?,
//            channelName = self.channelName {
//                
//                self.questionTitleLabel.text = questionData[kKeyTitle] as? String
//                self.questionLabel.text = questionData[kKeyQuestion] as? String
//                let endsAt = questionData[kKeyEndsAt] as! Int
//                let currentTimeStamp = Int(floor(NSDate().timeIntervalSince1970))
//                if currentTimeStamp < endsAt {
//                    let timeLeft = endsAt - currentTimeStamp
//                    self.timeLeftLabel.text = "Voting ends in \(timeLeft) seconds"
//                    self.currentTimeLeft = timeLeft
//                    self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerHit:", userInfo: nil, repeats: true)
//                }
//                else {
//                    self.timeLeftLabel.text = "Voting is over"
//                }
//                
//                
//                let baseUrl = kBaseHandle + channelName + kChannelsAnswer + "/" + String(questionId) + "/"
//                
//                if let option1LabelBaseText = questionData[kKeyOption1] as! String? {
//                    self.option1Label.text = option1LabelBaseText
//                    let option1Url = baseUrl + String(1)
//                    self.option1FirebaseRef = Firebase(url: option1Url)
//                    var option1Count = 0
//                    self.option1FirebaseHandle = self.option1FirebaseRef?.observeEventType(FEventType.ChildAdded, withBlock: { [weak self] (snapshot: FDataSnapshot!) -> Void in
//                        guard snapshot.exists() else {
//                            return
//                        }
//                        option1Count++
//                        self?.option1Label.text = option1LabelBaseText + "(" + String(option1Count) + ")"
//                    })
//                }
//                
//                if let option2LabelBaseText = questionData[kKeyOption2] as! String? {
//                    self.option2Label.text = option2LabelBaseText
//                    let option2Url = baseUrl + String(2)
//                    self.option2FirebaseRef = Firebase(url: option2Url)
//                    var option2Count = 0
//                    self.option2FirebaseHandle = self.option2FirebaseRef?.observeEventType(FEventType.ChildAdded, withBlock: { [weak self] (snapshot: FDataSnapshot!) -> Void in
//                        guard snapshot.exists() else {
//                            return
//                        }
//                        option2Count++
//                        self?.option2Label.text = option2LabelBaseText + "(" + String(option2Count) + ")"
//                    })
//                }
//                
//                if let option3LabelBaseText = questionData[kKeyOption3] as! String? {
//                    self.option3Label.text = option3LabelBaseText
//                    let option3Url = baseUrl + String(3)
//                    self.option3FirebaseRef = Firebase(url: option3Url)
//                    var option3Count = 0
//                    self.option3FirebaseHandle = self.option3FirebaseRef?.observeEventType(FEventType.ChildAdded, withBlock: { [weak self] (snapshot: FDataSnapshot!) -> Void in
//                        guard snapshot.exists() else {
//                            return
//                        }
//                        option3Count++
//                        self?.option3Label.text = option3LabelBaseText + "(" + String(option3Count) + ")"
//                    })
//                    self.option3Label.hidden = false
//                }
//                else {
//                    self.option3Label.hidden = true
//                }
//                
//                if let option4LabelBaseText = questionData[kKeyOption4] as! String? {
//                    self.option4Label.text = option4LabelBaseText
//                    let option4Url = baseUrl + String(4)
//                    self.option4FirebaseRef = Firebase(url: option4Url)
//                    var option4Count = 0
//                    self.option4FirebaseHandle = self.option4FirebaseRef?.observeEventType(FEventType.ChildAdded, withBlock: { [weak self] (snapshot: FDataSnapshot!) -> Void in
//                        guard snapshot.exists() else {
//                            return
//                        }
//                        option4Count++
//                        self?.option4Label.text = option4LabelBaseText + "(" + String(option4Count) + ")"
//                    })
//                    self.option4Label.hidden = false
//                }
//                else {
//                    self.option4Label.hidden = true
//                }
//                
//                self.resultView.hidden = false
//        }
//    }
//    
//    private func stopOptionFirebaseRefs() {
//        if let firebaseHandle = self.option1FirebaseHandle {
//            self.option1FirebaseRef?.removeObserverWithHandle(firebaseHandle)
//            self.option1FirebaseHandle = nil
//        }
//        if let firebaseHandle = self.option2FirebaseHandle {
//            self.option2FirebaseRef?.removeObserverWithHandle(firebaseHandle)
//            self.option2FirebaseHandle = nil
//        }
//        if let firebaseHandle = self.option3FirebaseHandle {
//            self.option3FirebaseRef?.removeObserverWithHandle(firebaseHandle)
//            self.option3FirebaseHandle = nil
//        }
//        if let firebaseHandle = self.option4FirebaseHandle {
//            self.option4FirebaseRef?.removeObserverWithHandle(firebaseHandle)
//            self.option4FirebaseHandle = nil
//        }
//        
//        if let timer = self.timer {
//            timer.invalidate()
//            self.timer = nil
//        }
//    }
//    
//    // MARK: Action and selector methods
//    @IBAction func closeBtnTapped(sender: AnyObject) {
//        self.navigationController?.popViewControllerAnimated(true)
//    }
//    
//    @IBAction func resultViewCloseBtnTapped(sender: AnyObject) {
//        self.resultView.hidden = true
//        self.stopOptionFirebaseRefs()
//    }
//    
//    func timerHit(decreaseTimer: NSTimer) {
//        self.currentTimeLeft--
//        if self.currentTimeLeft > 0 {
//            self.timeLeftLabel.text = "Voting ends in \(self.currentTimeLeft) seconds"
//        }
//        else {
//            self.timeLeftLabel.text = "Voting is over"
//            self.timer?.invalidate()
//            self.timer = nil
//        }
//    }
//    
//    // MARK: TableView Data source methods
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let count = self.questionsArray?.count {
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
//        if let questionObject = self.questionsArray?[indexPath.row],
//            questionTitle = questionObject[kKeyTitle] as! String? {
//            cell?.textLabel?.text = questionTitle
//        }
//        
//        return cell!
//    }
//    
//    // MARK: TableView Delegate methods
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        self.openResultViewAtIndex(indexPath.row)
//    }
//}
