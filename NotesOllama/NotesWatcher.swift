//
//  NotesWatcher.swift
//  NotesOllama
//
//  Created by Anders Rex on 2/18/24.
//

import Foundation
import AXSwift
import SwiftUI

let NOTES_BUNDLE_IDENTIFIER = "com.apple.Notes"

class NotesWatcher {
    private var notesCheckTimer: Timer?
    private var observer: Observer?
    private var upperRightCorner: CGPoint?
    private var onSelectionChange: ((String?, CGPoint?) -> Void)?
    @State private var keyEventMonitor: Any?

    func start(onSelectionChange: @escaping(String?, CGPoint?) -> Void) {
        print("Start monitoring for Notes app...")
        
        self.onSelectionChange = onSelectionChange
        
        notesCheckTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            let app = getNotesApp()
            
            if let app { // Notes is open
                try? self.createObserver(app)
            } else { // Notes is closed
                self.observer?.stop()
                self.observer = nil
            }
        }
    }
    
    func createObserver(_ app: Application) throws {
        guard observer == nil else { return }

        // TODO: Debounce
        observer = app.createObserver { (observer: Observer, element: UIElement, event: AXNotification, info: [String: AnyObject]?) in
            if event == .selectedTextChanged, let selectedText = try? element.attribute(.selectedText) as String? {
                let position = self.getPosition(app: app)
                self.onSelectionChange?(selectedText, position)
            } else {
                self.onSelectionChange?(nil, nil)
            }
        }
        
        let notifications: [AXNotification] = [
            .selectedTextChanged,
            .applicationDeactivated,
            .applicationHidden,
            .mainWindowChanged,
            .windowMoved,
            .windowMiniaturized,
        ]
        
        for notification in notifications {
            try observer?.addNotification(notification, forElement: app)
        }
    }
    
    private func getPosition(app: Application) -> CGPoint? {
        do {
            if let window = try app.attribute(.mainWindow) as UIElement? {
                let size = try window.attribute(.size) as CGSize?
                let position = try window.attribute(.position) as CGPoint?
                
                if let size = size, let position = position {
                    return CGPoint(x: position.x + size.width, y: position.y + size.height)
                }
            }
        } catch {
            print("Failed to get Notes window position: \(error)")
        }
        return nil
    }
}
