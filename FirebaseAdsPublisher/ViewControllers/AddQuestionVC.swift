//
//  AddQuestionVC.swift
//  FirebaseAdsPublisher
//
//  Created by Prasad Pai on 15/08/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import UIKit

private enum QuestionText: Int {
    case Title = 0
    case SpawnX = 1
    case SpawnY = 2
    case Question = 3
    case Duration = 4
    case Option1 = 5
    case Option2 = 6
    case Option3 = 7
    case Option4 = 8
    
    private func getLabelText() -> String {
        switch self {
        case .Title:
            return "Title"
        case .SpawnX:
            return "Spawn X (%age)"
        case .SpawnY:
            return "Spawn Y (%age)"
        case .Question:
            return "Question"
        case .Duration:
            return "Duration (in secs)"
        case .Option1:
            return "Option 1"
        case .Option2:
            return "Option 2"
        case .Option3:
            return "Option 3"
        case .Option4:
            return "Option 4"
        }
    }
    
    private func isInputNumber() -> Bool {
        switch self {
        case .Title, .Question, .Option1, .Option2, .Option3, .Option4:
            return false
        case .SpawnX, .SpawnY, .Duration:
            return true
        }
    }
    
    static func getTotalTextLabels() -> Int {
        return QuestionText.Option4.rawValue + 1
    }
    
    static func getTextLabelAtIndex(index: Int) -> String {
        if let questionText = QuestionText(rawValue: index) {
            return questionText.getLabelText()
        }
        return ""
    }
    
    static func isInputNumberAtIndex(index: Int) -> Bool {
        if let questionText = QuestionText(rawValue: index) {
            return questionText.isInputNumber()
        }
        return false
    }
}

class AddQuestionVC: UIViewController{
    
    var channelName: String?
    
    @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var questionTableView: UITableView!
    
    private var noOfExtraOptionsOn = 0
    private var isAddButtonOn = false
    
    // MARK: Class methods
    class func instantiateStoryboard() -> AddQuestionVC {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let addQuestionVC = storyBoard.instantiateViewControllerWithIdentifier("AddQuestionVC") as! AddQuestionVC
        return addQuestionVC
    }

    // MARK: View Controller Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addObservers()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let textField = self.view.viewWithTag(1) as! UITextField? {
            textField.becomeFirstResponder()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: Action and Selector methods
    @IBAction func removeBtnTapped(sender: AnyObject) {
        self.noOfExtraOptionsOn -= 1
        if self.noOfExtraOptionsOn == 1 {
            let lastIndexPath = NSIndexPath(forRow: QuestionText.getTotalTextLabels() - 1, inSection: 0)
            if let cell = self.questionTableView.cellForRowAtIndexPath(NSIndexPath(forRow: QuestionText.getTotalTextLabels() - 2, inSection: 0)) as! TextfieldCell? {
                cell.setRemoveBtnHidden(false)
            }
            
            self.questionTableView.beginUpdates()
            self.questionTableView.reloadRowsAtIndexPaths([lastIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.questionTableView.endUpdates()
        }
        else {
            self.questionTableView.beginUpdates()
            self.questionTableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: QuestionText.getTotalTextLabels() - 2, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.questionTableView.endUpdates()
        }
    }
    
    @IBAction func cancelBtnTapped(sender: AnyObject) {
        self.view.endEditing(true)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func saveBtnTapped(sender: AnyObject) {
        self.view.endEditing(true)
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.parseDataOut()
    }
    
    func keyboardDidShow(notification: NSNotification) {
        // Get the size of the keyboard.
        if let keyboardInfo = notification.userInfo,
            keyboardValue = keyboardInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue? {
            let keyboardFrame = keyboardValue.CGRectValue()
            self.tableViewBottomConstraint.constant = keyboardFrame.height
            
            UIView.animateWithDuration(0.4) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.tableViewBottomConstraint.constant = 0.0
        UIView.animateWithDuration(0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    func uploadedQuestionNotification(notification: NSNotification) {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        if let userInfo = notification.userInfo as! [String: AnyObject]?,
            isUploaded = userInfo["isUploaded"] as! Bool? {
            guard isUploaded else {
                if let error = userInfo["error"] as! NSError? {
                    self.simpleAlertViewWithTitle("Error", message: error.localizedDescription, btnTitle: "OK")
                }
                return
            }
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: Private methods
    private func addObservers() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(uploadedQuestionNotification(_:)), name: kNotificationUploadedQuestion, object: nil)
    }
    
    private func parseDataOut() {
        var uploadData: [String: AnyObject] = [:]
        let currentTextLabels = self.getNoOfTextFieldCells() - 1
        for counter in 0...currentTextLabels {
            let questionText = QuestionText(rawValue: counter)!
            if let textField = self.view.viewWithTag(counter + 1) as! UITextField?,
               textFieldText = textField.text where textFieldText.characters.count > 0 {
                if [QuestionText.Title, .Question, .Option1, .Option2, .Option3, .Option4].contains(questionText) {
                    uploadData[questionText.getLabelText()] = textFieldText
                }
                else if [QuestionText.SpawnX, .SpawnY].contains(questionText) {
                    uploadData[questionText.getLabelText()] = Float(textFieldText)
                }
                else if questionText == .Duration {
                    if let interval = Double(textFieldText) {
                        // Assuming time is set correctly.
                        uploadData[questionText.getLabelText()] = floor(NSDate().timeIntervalSince1970 + interval)
                    }
                }
            }
            else {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                let reqdLabelText = QuestionText.getTextLabelAtIndex(counter)
                let message = "Enter text in \"\(reqdLabelText)\" column"
                self.simpleAlertViewWithTitle("Text Missing", message: message, btnTitle: "OK")
                return
            }
        }
        
        self.uploadDataToServer(uploadData)
    }
    
    private func uploadDataToServer(data: [String: AnyObject]) {
        if let channelName = self.channelName {
            let timestamp = Int(floor(NSDate().timeIntervalSince1970))
            let uploadKeyName = channelName + kChannelsQuiz + "/" + String(timestamp)
            var questionData = data
            questionData[kKeyQuestionId] = timestamp
            
            FirebaseManager.sharedInstance.uploadQuestionAtNode(uploadKeyName, withData: questionData)
        }
    }
    
    // MARK: Utility methods
    private func getNoOfTextFieldCells() -> Int {
        let currentTextLabels = QuestionText.getTotalTextLabels() - (2 - self.noOfExtraOptionsOn)
        return currentTextLabels
    }
    
    private func isAddOptionBtnAtIndex(index: Int) -> Bool {
        let currentTextLabels = self.getNoOfTextFieldCells()
        return currentTextLabels == index && self.noOfExtraOptionsOn < 2
    }
}

// MARK: Table View methods
extension AddQuestionVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: Table View Data Source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let textLabelsCount = QuestionText.getTotalTextLabels()
        self.isAddButtonOn = self.noOfExtraOptionsOn < 2
        let count = textLabelsCount - (2 - self.noOfExtraOptionsOn) + (self.isAddButtonOn ? 1 : 0)
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if self.isAddOptionBtnAtIndex(indexPath.row) {
            let cellId = "normalCellId"
            cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
                cell?.textLabel?.textAlignment = NSTextAlignment.Center
            }
            cell.textLabel?.text = "Add Another Cell"
        }
        else {
            let textCell = tableView.dequeueReusableCellWithIdentifier("TextfieldCell") as! TextfieldCell?
            textCell?.descLabel.text = QuestionText.getTextLabelAtIndex(indexPath.row)
            
            var isRemoveBtnHidden = true
            if self.noOfExtraOptionsOn > 0 {
                if self.noOfExtraOptionsOn == 2 && indexPath.row == QuestionText.getTotalTextLabels() - 1 {
                    isRemoveBtnHidden = false
                }
                else if self.noOfExtraOptionsOn == 1 && indexPath.row == QuestionText.getTotalTextLabels() - 2 {
                    isRemoveBtnHidden = false
                }
            }
            textCell?.setRemoveBtnHidden(isRemoveBtnHidden)
            textCell?.textField.tag = indexPath.row + 1
            textCell?.textField.keyboardType = QuestionText.isInputNumberAtIndex(indexPath.row) ? UIKeyboardType.NumbersAndPunctuation : UIKeyboardType.ASCIICapable
            cell = textCell
        }
        
        return cell
    }
    
    // MARK: Table View Delegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if self.isAddOptionBtnAtIndex(indexPath.row) {
            self.noOfExtraOptionsOn += 1
            tableView.beginUpdates()
            if self.noOfExtraOptionsOn == 1 {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            else {
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)) as! TextfieldCell? {
                    cell.setRemoveBtnHidden(true)
                }
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            tableView.endUpdates()
            
        }
        else {
            if let textField = self.view.viewWithTag(indexPath.row + 1) as! UITextField? {
                textField.becomeFirstResponder()
            }
        }
    }
}

// MARK: TextField Delegate methods
extension AddQuestionVC: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let tag = textField.tag
        let currentTextLabels = QuestionText.getTotalTextLabels() - (2 - self.noOfExtraOptionsOn)
        if tag < currentTextLabels {
            if let textField = self.view.viewWithTag(tag + 1) as! UITextField? {
                textField.becomeFirstResponder()
            }
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
}
