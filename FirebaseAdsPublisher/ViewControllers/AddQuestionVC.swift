//
//  AddQuestionVC.swift
//  FirebaseAdsPublisher
//
//  Created by Prasad Pai on 15/08/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import UIKit

class AddQuestionVC: UIViewController{
    
    var channelName: String?
    
    @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var questionTableView: UITableView!
    
    private var noOfExtraOptionsOn = 0
    private var isAddButtonOn = false
    private var enteredData = [String](count: QuestionText.getTotalTextLabels(), repeatedValue: "")
    
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
        if let cell = self.questionTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! TextfieldCell? {
            cell.textField.becomeFirstResponder()
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
            self.enteredData[QuestionText.getTotalTextLabels() - 1] = ""
        }
        else {
            self.questionTableView.beginUpdates()
            self.questionTableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: QuestionText.getTotalTextLabels() - 2, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.questionTableView.endUpdates()
            self.enteredData[QuestionText.getTotalTextLabels() - 2] = ""
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
            let textFieldText = self.enteredData[counter]
            if textFieldText.characters.count > 0 {
                if [QuestionText.Title, .Question, .Option1, .Option2, .Option3, .Option4].contains(questionText) {
                    uploadData[questionText.getDictKeyTitle()] = textFieldText
                }
                else if [QuestionText.SpawnX, .SpawnY].contains(questionText) {
                    uploadData[questionText.getDictKeyTitle()] = Float(textFieldText)
                }
                else if questionText == .Duration {
                    if let interval = Double(textFieldText) {
                        uploadData[questionText.getDictKeyTitle()] = interval * 1000  // To store in milliseconds
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
            FirebaseManager.sharedInstance.uploadQuestionAtChannel(channelName, withData: data)
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
            cell.textLabel?.text = "Add Another Option"
        }
        else {
            let textCell = tableView.dequeueReusableCellWithIdentifier("TextfieldCell") as! TextfieldCell?
            textCell?.descLabel.text = QuestionText.getTextLabelAtIndex(indexPath.row)
            textCell?.textField.text = self.enteredData[indexPath.row]
            
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
            textCell?.textField.keyboardType = QuestionText.isInputNumberAtIndex(indexPath.row) ? UIKeyboardType.NumbersAndPunctuation : UIKeyboardType.ASCIICapable
            textCell?.textField.tag = indexPath.row
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
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.enteredData[textField.tag] = textField.text ?? ""
    }
}
