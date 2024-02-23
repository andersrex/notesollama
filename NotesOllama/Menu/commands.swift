//
//  commands.swift
//  Ported over from Obsidian Ollama and modified
//  https://github.com/hinterdupfinger/obsidian-ollama/blob/main/src/data/defaultSettings.ts
//

import Foundation

struct CommandsContainer: Decodable {
    let commands: [Command]
}

struct Command: Decodable {
    var name: String
    var prompt: String
}

func loadCommandsFromFile() -> [Command] {
    guard let url = Bundle.main.url(forResource: "commands", withExtension: "json"),
          let data = try? Data(contentsOf: url) else {
        return []
    }

    do {
        let decoder = JSONDecoder()
        let container = try decoder.decode(CommandsContainer.self, from: data)
        return container.commands
    } catch {
        print("Error decoding JSON: \(error)")
        return []
    }
}




