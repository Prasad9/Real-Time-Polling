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
    
    // MARK: Initialization methods
    override init() {
        super.init()
    }
    
    deinit {

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
    
    func uploadQuestionAtNode(keyName: String, withData data: [String: AnyObject]) {
        let uploadQuestionFirebase = FIRDatabase.database().reference().child(keyName)
        uploadQuestionFirebase.setValue(data) { (error: NSError?, databaseReference: FIRDatabaseReference) in
            let isUploaded = error == nil
            var userInfo: [String: AnyObject] = ["isUploaded": isUploaded]
            if !isUploaded,
                let error = error {
                userInfo["error"] = error
            }
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationUploadedQuestion, object: nil, userInfo: userInfo)
        }
    }
}