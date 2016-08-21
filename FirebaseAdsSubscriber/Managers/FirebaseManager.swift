//
//  FirebaseManager.swift
//  FirebasePubSub
//
//  Created by Prasad Pai on 8/16/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import Firebase
import FirebaseDatabase

class FirebaseManager: NSObject {
    
    static let sharedInstance = FirebaseManager()
    
    private var questionListenerFirebase: FIRDatabaseReference?
    private var onlineUserFirebase: FIRDatabaseReference?
    
    // MARK: Initialization methods
    override init() {
        super.init()
    }
    
    deinit {
        self.stopListeningToQuestions()
        self.unregisterUserAsOnline()
    }
    
    // MARK: Public methods
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
    
    func listenToQuestionsInChannel(channelName: String) {
        self.questionListenerFirebase = FIRDatabase.database().reference().child(channelName + kChannelsQuiz)
        self.questionListenerFirebase?.observeEventType(FIRDataEventType.ChildAdded) { (dataSnapshot: FIRDataSnapshot) in
            guard dataSnapshot.exists() else {
                return
            }
            
            if let userInfo = dataSnapshot.value as! [String: AnyObject]? {
                let currentTimeStamp = Int(NSDate().timeIntervalSince1970 * 1000)
                // TODO: Need to fetch the time from Firebase server.
                // But fetching can take time which will result
                // in delay of question getting displayed.
                if let questionId = userInfo[kKeyQuestionId] as! Int? where currentTimeStamp - questionId < kConstGraceSecTimeAllowed * 1000  {
                    // Need not display questions older than grace seconds.
                    NSNotificationCenter.defaultCenter().postNotificationName(kNotificationReceivedQuestion, object: nil, userInfo: userInfo)
                }
            }
        }
    }
    
    func stopListeningToQuestions() {
        if self.questionListenerFirebase != nil {
            self.questionListenerFirebase?.removeAllObservers()
            self.questionListenerFirebase = nil
        }
    }
    
    func registerUserAsOnlineInChannel(channelName: String) {
        if self.onlineUserFirebase != nil {
            self.onlineUserFirebase?.removeValue()
        }
        
        self.onlineUserFirebase = FIRDatabase.database().reference().child(kChannelsOnlineUsers + "/" + channelName).childByAutoId()
        self.onlineUserFirebase?.setValue(true)
    }
    
    func unregisterUserAsOnline() {
        self.onlineUserFirebase?.removeValue()
        self.onlineUserFirebase = nil
    }
    
    func uploadAnswerWithOptionNo(optionNo: Int, forQuestion questionId: Int, inChannel channelName: String) {
        let nodeAt = channelName + kChannelsAnswer + "/" + String(questionId) + "/" + String(optionNo)
        let answerFirebase = FIRDatabase.database().reference().child(nodeAt).childByAutoId()
        answerFirebase.setValue(FIRServerValue.timestamp())
    }
}
