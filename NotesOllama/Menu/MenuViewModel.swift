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
    @Published var showModelsNotFound = false
    @Published var showOllamaNotRunning = false
    @Published var models: [String] = []
    @AppStorage("selectedModel") var selectedModel: String?
    
    func generate(prompt: String, text: String) {
        guard text.count > 0 else { return }
        isLoading = true
        
        // Cancel any ongoing generation
        ollamaService.cancelGeneration()
        
        // Monitor caret move so we can stop generating on move
        monitorCaretMove()
        
        let pasteService = PasteService(canNotesReceivePaste: canNotesReceivePaste)
        
        Task {
            guard let model = await getSelectedModel() else {
                DispatchQueue.main.async { self.showModelsNotFound = true }
                return
            }
            
            // Tap right key to unselect and move to the right
            sendKeyCode(keyCodes: [RIGHT_KEY], flags: [])
        
            guard await ollamaService.reachable() else {
                DispatchQueue.main.async { self.showOllamaNotRunning = true }
                return
            }
                                    
            ollamaService.generate(model: model, prompt: prompt, text: text) { response in
                if let response {
                    // Only paste if Notes is active app
                    if (self.canNotesReceivePaste()) {
                        pasteService.addToPasteQueue(response)
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
    
    func refreshModels() {
        Task {
            await fetchModels()
        }
    }
    
    func getSelectedModel() async -> String? {
        if selectedModel == nil {
            await fetchModels()
        }
            
        return selectedModel
    }
    
    func fetchModels() async {
        let _models = await ollamaService.fetchModels()
        DispatchQueue.main.async {
            self.models = _models
            
            // Select latest model by default
            if self.models.count > 0 && self.selectedModel == nil {
                self.selectedModel = self.models.last
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
