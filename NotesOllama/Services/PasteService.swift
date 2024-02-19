//
//  PasteService.swift
//  NotesOllama
//
//  Created by Anders Rex on 2/19/24.
//

import Foundation
import SwiftUI

// We're pasting using keyboard events so we can't do it too quickly
let PASTE_INTERVAL = 0.1 // seconds

class PasteService {
    var canNotesReceivePaste: () -> Bool
    var lastPasteTime = DispatchTime.now()
    let pasteQueue = DispatchQueue(label: "NotesOllamaPasteQueue")
    var isFirstePaste = true
    
    init(canNotesReceivePaste: @escaping() -> Bool) {
        self.canNotesReceivePaste = canNotesReceivePaste
    }

    func addToPasteQueue(_ text: String) {
        var textToPaste = text
        
        // Make sure generation starts with a whitespace
        let prefixes = [" ", "\n", "\t"]
        if isFirstePaste && !prefixes.contains(where: textToPaste.hasPrefix) {
            textToPaste = " " + textToPaste
        }

        isFirstePaste = false

        pasteQueue.async {
            let now = DispatchTime.now()
            let minimumInterval = PASTE_INTERVAL
            let elapsed = Double(now.uptimeNanoseconds - self.lastPasteTime.uptimeNanoseconds) / 1_000_000_000
            let delay = max(0, minimumInterval - elapsed)

            // If necessary, delay the paste operation
            if delay > 0 {
                Thread.sleep(forTimeInterval: delay)
            }

            if (self.canNotesReceivePaste()) {
                self.pasteText(textToPaste)
            }
            
            // Update the last paste time
            self.lastPasteTime = DispatchTime.now()
        }
    }
    
    func pasteText(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        sendKeyCode(keyCodes: [COMMAND_KEY, V_KEY], flags: [.maskCommand])
    }
}
