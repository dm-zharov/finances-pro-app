//
//  ContentView.swift
//  Finances Watch App
//
//  Created by Dmitriy Zharov on 10.03.2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {    
    var body: some View {
        NavigationStack {
            OverviewView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}
