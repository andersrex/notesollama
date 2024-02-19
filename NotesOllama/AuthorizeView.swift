//
//  AuthorizeView.swift
//  NotesOllama
//
//  Created by Anders Rex on 2/19/24.
//

import Foundation
import SwiftUI

struct AuthorizeView: View {
    var body: some View {
        VStack {
            Text("Authorize NotesOllama").font(.title2).padding(.bottom, 0)
            Image("icon").frame(maxWidth: 100)
                .padding(.bottom, 10)
            Text("NotesOllama needs your permission to access Apple Notes ").padding(.bottom, 20)
                        
            VStack(alignment: .leading) {
                Text("1. Go to System Settings → Privacy & Security → Accessibility ").padding(.bottom, 5)
                Button("Open System Settings") {
                    openSystemSettings()
                }
                .padding(.bottom, 10)
                .padding(.leading, 10)
                Text("2. Enable NotesOllama")
            }.frame(maxWidth: .infinity)

        }
        .padding(.horizontal, 30)
        .padding(.vertical, 40)
    }
    
    func openSystemSettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }
}
