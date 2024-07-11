//
//  OllamaService.swift
//  NotesOllama
//
//  Created by Anders Rex on 2/18/24.
//

import Foundation
import OllamaKit
import Combine

let defaultBaseURL = "http://localhost:11434"

class OllamaService {
    private var ollamaKit: OllamaKit

    init() {
        let baseURLString = ProcessInfo.processInfo.environment["NOTESOLLAMA_OLLAMA_BASE_URL"] ?? defaultBaseURL
        guard let url = URL(string: baseURLString) else {
            fatalError("Invalid URL string: \(baseURLString)")
        }
        self.ollamaKit = OllamaKit(baseURL: url)
    }

    private var cancellables = Set<AnyCancellable>()
    
    func fetchModels() async -> [String] {
        guard let response = try? await ollamaKit.models() else { return [] }
        let models = response.models.map { $0.name }
        return models
    }
    
    func reachable() async -> Bool {
        return await ollamaKit.reachable()
    }

    func generate(model: String, prompt: String, text: String, onReceive: @escaping(String?) -> Void) {
        let requestData = OKGenerateRequestData(model: model, prompt: prompt + "\n\n" + text)

        ollamaKit.generate(data: requestData)
            .sink(receiveCompletion: { completion in
                onReceive(nil)
                
                switch completion {
                case .finished:
                    print("Generation completed successfully.")
                case .failure(let error):
                    print("An error occurred: \(error)")
                }
            }, receiveValue: { generateResponse in
                onReceive(generateResponse.response)
            })
            .store(in: &cancellables)
    }
    
    func cancelGeneration() {
        for cancellable in cancellables {
            cancellable.cancel()
        }

        cancellables.removeAll()
    }
}
