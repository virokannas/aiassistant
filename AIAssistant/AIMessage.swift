//
//  AIMessage.swift
//  AIAssistant
//
//  Created by Simo Virokannas on 5/11/21.
//

import Foundation

class AIMessage {
    var text: String = ""
    var me: Bool = false
    var empty: Bool = false
    
    init(_ txt: String, me: Bool, _ mpty : Bool = false) {
        self.me = me
        self.text = txt
        self.empty = mpty
    }
}
