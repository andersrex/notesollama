//
//  AlertHandlingExtension.swift
//  NotesOllama
//
//  Created by Anders Rex on 2/20/24.
//

import Foundation
import SwiftUI

struct AlertHandling: ViewModifier {
    @ObservedObject var viewModel: MenuViewModel
    
    func body(content: Content) -> some View {
        content
            .alert("Ollama not found", isPresented: $viewModel.showOllamaNotRunning) {
                Button("OK", role: .cancel) { viewModel.generationEnded() }
            } message: {
                Text("Please install Ollama to use NotesOllama")
            }
            .alert("Model not found", isPresented: $viewModel.showModelsNotFound) {
                Button("OK", role: .cancel) { viewModel.generationEnded() }
            } message: {
                Text("Please add a model to Ollama using the \"ollama\" command line tool")
            }
    }
}

extension View {
    func alertHandling(viewModel: MenuViewModel) -> some View {
        self.modifier(AlertHandling(viewModel: viewModel))
    }
}
