//
//  utils.swift
//  NotesOllama
//
//  Created by Anders Rex on 2/18/24.
//

import Foundation
import SwiftUI
import AXSwift

func isNotesFrontmost() -> Bool {
    guard let application = NSWorkspace.shared.frontmostApplication else {
        return false
    }
    
    return application.bundleIdentifier == NOTES_BUNDLE_IDENTIFIER
}

func getNotesApp() -> Application? {
    Application.allForBundleID(NOTES_BUNDLE_IDENTIFIER).first
}

let COMMAND_KEY: UInt16 = 55
let RIGHT_KEY: UInt16 = 124
let V_KEY: UInt16 = 9

func sendKeyCode(keyCodes: [UInt16], flags: CGEventFlags) {
    guard let source = CGEventSource(stateID: .hidSystemState) else { return }

    usleep(20_000)

    // Press down all keys
    for code in keyCodes {
        if let down = CGEvent(keyboardEventSource: source, virtualKey: code, keyDown: true) {
            down.flags = flags
            down.post(tap: .cghidEventTap)
        }
    }

    usleep(10_000)

    // Release all keys
    for code in keyCodes {
        if let up = CGEvent(keyboardEventSource: source, virtualKey: code, keyDown: false) {
            up.flags = flags
            up.post(tap: .cghidEventTap)
        }
    }
}
