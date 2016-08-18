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
                NSNotificationCenter.defaultCenter().postNotificationName(kNotificationReceivedQuestion, object: nil, userInfo: userInfo)
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
}
