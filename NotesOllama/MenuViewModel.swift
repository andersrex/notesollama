//
//  MenuViewModel.swift
//  NotesOllama
//
//  Created by Anders Rex on 2/18/24.
//

import Foundation
import SwiftUI
import OllamaKit

class MenuViewModel: ObservableObject {
    var onGenerationEnded: (() -> Void)?
    
    private var ollamaService = OllamaService()
    private var keyEventMonitor: Any?
    private var mouseEventMonitor: Any?
    private var hasCaretMoved = false

    @Published var isLoading = false
    @Published var models: [String] = []
    @AppStorage("selectedModel") var selectedModel: String?
    
    func fetchModels() {
        Task {
            let _models = await ollamaService.fetchModels()
            DispatchQueue.main.async {
                self.models = _models
                
                // Select latest model by default
                if self.models.count > 0 && self.selectedModel == nil  {
                    self.selectedModel = self.models.last
                }
            }
        }
    }
    
    func generate(prompt: String, text: String) {
        guard let model = selectedModel, text.count > 0 else { return }
        isLoading = true
        
        // Cancel any ongoing generation
        ollamaService.cancelGeneration()
        
        // Monitor caret move so we can stop generating on move
        monitorCaretMove()
        
        let pasteProcessor = PasteProcessor(canNotesReceivePaste: canNotesReceivePaste)
        
        Task {
            // Tap right key to unselect and move to the right
            sendKeyCode(keyCodes: [RIGHT_KEY], flags: [])
        
            guard await ollamaService.reachable() else {
                print("Not reachalble")
                pasteProcessor.addToPasteQueue("\nOooops, looks like Ollama is not running...")
                self.generationEnded()
                return
            }
                                    
            ollamaService.generate(model: model, prompt: prompt, text: text) { response in
                if let response {
                    // Only paste if Notes is active app
                    if (self.canNotesReceivePaste()) {
                        pasteProcessor.addToPasteQueue(response)
                    } else {
                        self.ollamaService.cancelGeneration()
                        self.generationEnded()
                    }
                } else {
                    // Done
                    self.generationEnded()
                }
            }
        }
    }
    
    func canNotesReceivePaste() -> Bool {
        isNotesFrontmost() && !hasCaretMoved
    }
    
    func monitorCaretMove() {
        hasCaretMoved = false
        
        mouseEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            self?.hasCaretMoved = true
        }
        
         keyEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
             if [RIGHT_KEY, V_KEY].contains(event.keyCode) { return }
             self?.hasCaretMoved = true
         }
    }
    
    func generationEnded() {
        self.stopMonitoringCaretMove()
        
        DispatchQueue.main.async {
            self.isLoading = false
            self.onGenerationEnded?()
        }
    }
    
    func stopMonitoringCaretMove() {
        if let mouseMonitor = mouseEventMonitor {
            NSEvent.removeMonitor(mouseMonitor)
            mouseEventMonitor = nil
        }
        
         if let keyMonitor = keyEventMonitor {
             NSEvent.removeMonitor(keyMonitor)
             keyEventMonitor = nil
         }
    }    
}
