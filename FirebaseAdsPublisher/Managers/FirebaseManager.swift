//
//  FirebaseManager.swift
//  FirebasePubSub
//
//  Created by Prasad Pai on 16/08/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import Firebase
import FirebaseDatabase

class FirebaseManager: NSObject {
    
    static let sharedInstance = FirebaseManager()
    
    private var onlineUsersFirebase: FIRDatabaseReference?
    private var option1Firebase: FIRDatabaseReference?
    private var option2Firebase: FIRDatabaseReference?
    private var option3Firebase: FIRDatabaseReference?
    private var option4Firebase: FIRDatabaseReference?
    
    // MARK: Initialization methods
    override init() {
        super.init()
    }
    
    deinit {
        self.stopListeningToOnlineUsersCount()
        self.stopContinousFirebaseAnswers()
    }

    // MARK: Public methods
    // MARK: Channel methods
    func fetchAllChannels() {
        let allChannelsFirebase = FIRDatabase.database().reference().child(kChannelsList)
        allChannelsFirebase.observeSingleEventOfType(FIRDataEventType.Value) { (dataSnapshot: FIRDataSnapshot) in
            guard dataSnapshot.exists() else {
                NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAllChannels, object: nil)
                return
            }
            
            let channelsListArray = dataSnapshot.value as! [String: String]
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAllChannels, object: nil, userInfo: channelsListArray)
        }
    }
    
    func addChannelWithName(channelName: String) {
        let allChannelsFirebase = FIRDatabase.database().reference().child(kChannelsList + "/" + channelName)
        allChannelsFirebase.setValue(channelName) { (error: NSError?, databaseReference: FIRDatabaseReference) in
            let isAdded = error == nil
            var userInfo: [String: AnyObject] = ["isAdded": isAdded]
            if !isAdded,
                let error = error {
                userInfo["error"] = error
            }
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAddedChannel, object: nil, userInfo: userInfo)
        }
    }
    
    // MARK: Question methods
    func uploadQuestionAtChannel(channelName: String, withData data: [String: AnyObject]) {
        var uploadData = data
        uploadData[kKeyQuestionId] = FIRServerValue.timestamp()
        
        let uploadQuestionFirebase = FIRDatabase.database().reference().child(channelName + kChannelsQuiz).childByAutoId()
        uploadQuestionFirebase.setValue(uploadData) { (error: NSError?, databaseReference: FIRDatabaseReference) in
            let isUploaded = error == nil
            var userInfo: [String: AnyObject] = ["isUploaded": isUploaded]
            if !isUploaded,
                let error = error {
                userInfo["error"] = error
            }
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationUploadedQuestion, object: nil, userInfo: userInfo)
        }
    }
    
    func fetchAllQuestionsInChannel(channelName: String) {
        let questionsFirebase = FIRDatabase.database().reference().child(channelName + kChannelsQuiz)
        questionsFirebase.queryOrderedByKey().observeSingleEventOfType(FIRDataEventType.Value) { (dataSnapshot: FIRDataSnapshot) in
            guard dataSnapshot.exists() else {
                NSNotificationCenter.defaultCenter().postNotificationName(kNotificationFetchedQuestions, object: nil)
                return
            }
            
            let questionData = dataSnapshot.value as! [String: AnyObject]
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationFetchedQuestions, object: nil, userInfo: questionData)
        }
    }
    
    // MARK: Online User methods
    func listenToOnlineUsersCount() {
        self.stopListeningToOnlineUsersCount()
        
        self.onlineUsersFirebase = FIRDatabase.database().reference().child(kChannelsOnlineUsers)
        self.onlineUsersFirebase?.observeEventType(FIRDataEventType.Value, withBlock: { (dataSnapshot: FIRDataSnapshot) in
            guard dataSnapshot.exists() else {
                NSNotificationCenter.defaultCenter().postNotificationName(kNotificationOnlineUsers, object: nil)
                return
            }
            
            let userInfo = dataSnapshot.value as! [String: AnyObject]
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationOnlineUsers, object: nil, userInfo: userInfo)
        })
    }
    
    func stopListeningToOnlineUsersCount() {
        self.onlineUsersFirebase?.removeAllObservers()
        self.onlineUsersFirebase = nil
    }
    
    // MARK: Answer methods
    func listenToFirebaseAnswers(isContinuous: Bool, inChannel channelName: String, questionId: Int, totalOptions: Int) {
        if isContinuous {
            self.loadContinuousUserAnswersInChannel(channelName, questionId: questionId, totalOptions: totalOptions)
        }
        else {
            self.loadStoredUserAnswersInChannel(channelName, questionId: questionId, totalOptions: totalOptions)
        }
    }
    
    func stopContinousFirebaseAnswers() {
        self.option1Firebase?.removeAllObservers()
        self.option1Firebase = nil
        self.option2Firebase?.removeAllObservers()
        self.option2Firebase = nil
        self.option3Firebase?.removeAllObservers()
        self.option3Firebase = nil
        self.option4Firebase?.removeAllObservers()
        self.option4Firebase = nil
    }
    
    // MARK: Private methods
    // MARK: Answer methods
    private func loadStoredUserAnswersInChannel(channelName: String, questionId: Int, totalOptions: Int) {
        for optionNo in 1...totalOptions {
            let answerUrl = channelName + kChannelsAnswer + "/" + String(questionId) + "/" + String(optionNo)
            let answerFirebase = FIRDatabase.database().reference().child(answerUrl)
            answerFirebase.observeEventType(FIRDataEventType.Value) { (dataSnapshot: FIRDataSnapshot) in
                let key = dataSnapshot.key
                if let index = Int(key) {
                    guard dataSnapshot.exists() else {
                        let userInfo: [String: AnyObject] = [kConstIsContinuous: false, kConstIndex: index, kConstCount: 0]
                        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationFetchedAnswers, object: nil, userInfo: userInfo)
                        return
                    }
                    
                    if let valueDict = dataSnapshot.value as! [String: AnyObject]? {
                        let userInfo: [String: AnyObject] = [kConstIsContinuous: false, kConstIndex: index, kConstCount: valueDict.count]
                        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationFetchedAnswers, object: nil, userInfo: userInfo)
                    }
                }
            }
        }
    }
    
    private func loadContinuousUserAnswersInChannel(channelName: String, questionId: Int, totalOptions: Int) {
        self.stopContinousFirebaseAnswers()
        
        for optionNo in 1...totalOptions {
            let answerUrl = channelName + kChannelsAnswer + "/" + String(questionId) + "/" + String(optionNo)
            let answerFirebase = FIRDatabase.database().reference().child(answerUrl)
            switch optionNo {
            case 1:
                self.option1Firebase = answerFirebase
            case 2:
                self.option2Firebase = answerFirebase
            case 3:
                self.option3Firebase = answerFirebase
            case 4:
                self.option4Firebase = answerFirebase
            default:
                break
            }
            answerFirebase.observeEventType(FIRDataEventType.ChildAdded) { (dataSnapshot: FIRDataSnapshot) in
                if let key = dataSnapshot.ref.parent?.key,
                     index = Int(key) {
                    guard dataSnapshot.exists() else {
                        return
                    }
                    
                    let userInfo: [String: AnyObject] = [kConstIsContinuous: true, kConstIndex: index, kConstCount: 1]
                    NSNotificationCenter.defaultCenter().postNotificationName(kNotificationFetchedAnswers, object: nil, userInfo: userInfo)
                }
            }
        }
    }
    
}