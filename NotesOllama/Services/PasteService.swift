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
    var currentLine = ""
    
    init(canNotesReceivePaste: @escaping() -> Bool) {
        self.canNotesReceivePaste = canNotesReceivePaste
    }
    
    func addToPasteQueue(_ text: String) {
        guard var textToPaste = handleMonostyle(text) else { return }
        
        // Make sure generation starts with a whitespace
        if isFirstePaste && ![" ", "\n", "\t"].contains(where: textToPaste.hasPrefix) {
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
    
    // Many users use NotesOllama with NotesCmdr, which converts
    // ``` to a monostyle block. This function makes sure we
    // paste in a way that never has a line with just ```
    func handleMonostyle(_ text: String) -> String? {
        currentLine += text
        
        // Save up ` characters in currentLine and ...
        if ["`", "``", "```"].contains(currentLine) {
            return nil
        // ...paste them once there's more chars on the line
        } else if (currentLine.hasPrefix("```")) {
            let newText = currentLine
            currentLine = ""
            return newText
        }
        
        if text.contains("\n") {
            currentLine = ""
        }
        
        return text
    }
    
    // Paste in any trailing ``` once generation is done
    func done() {
        if currentLine == "```" {
            pasteQueue.async {
                self.pasteText(self.currentLine + "\n")
            }
        }
    }
    
    func pasteText(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        sendKeyCode(keyCodes: [COMMAND_KEY, V_KEY], flags: [.maskCommand])
    }
}
