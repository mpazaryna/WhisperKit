//
//  SidebarView.swift
//  WhisperKitApp
//
//  Sidebar navigation for VoiceKitLab
//

import SwiftUI

struct SidebarView: View {
    @Binding var selection: NavigationItem?

    var body: some View {
        List(NavigationItem.allCases, selection: $selection) { item in
            NavigationLink(value: item) {
                Label(item.title, systemImage: item.icon)
            }
        }
        .navigationTitle("VoiceKitLab")
        #if os(macOS)
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        #endif
    }
}

#Preview {
    NavigationSplitView {
        SidebarView(selection: .constant(.examples))
    } detail: {
        Text("Detail")
    }
}
