//
//  WelcomeView.swift
//  NotesOllama
//
//  Created by Anders Rex on 2/19/24.
//

import Foundation
import SwiftUI

struct WelcomeView: View {
    @AppStorage("hideWelcomeMessage") private var hideWelcomeMessage = false

    var onGotItClicked: () -> Void

    var body: some View {
        VStack {
            Text("Welcome to NotesOllama").font(.title2).padding(.bottom, 0)
            Image("icon").frame(maxWidth: 100)
                .padding(.bottom, 10)
            Text("Next, try selecting some text in Notes and clicking").font(.title3).padding(.bottom, 0)
            Text("the wand menu in the bottom right corner.").font(.title3).padding(.bottom, 20)
        
            Button("Got it!") {
                onGotItClicked()
            }
            Toggle("Do not show this message again", isOn: $hideWelcomeMessage)
                .padding(.top, 10)

        }
        .padding(30)
    }
}
