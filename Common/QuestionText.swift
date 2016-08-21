//
//  QuestionText.swift
//  FirebasePubSub
//
//  Created by Prasad Pai on 8/17/16.
//  Copyright © 2016 Prasad Pai. All rights reserved.
//

import Foundation

enum QuestionText: Int {
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
    
    func getDictKeyTitle() -> String {
        switch self {
        case .Title:
            return "Title"
        case .SpawnX:
            return "SpawnX"
        case .SpawnY:
            return "SpawnY"
        case .Question:
            return "Question"
        case .Duration:
            return "Duration"
        case .Option1:
            return "Option1"
        case .Option2:
            return "Option2"
        case .Option3:
            return "Option3"
        case .Option4:
            return "Option4"
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
