//
//  NavigationItem.swift
//  WhisperKitApp
//
//  Navigation item enum for sidebar
//

import SwiftUI

enum NavigationItem: String, CaseIterable, Identifiable {
    case examples
    case voice
    case comparison
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .examples: "Examples"
        case .voice: "Voice"
        case .comparison: "Comparison"
        case .settings: "Settings"
        }
    }

    var icon: String {
        switch self {
        case .examples: "square.grid.2x2"
        case .voice: "waveform"
        case .comparison: "arrow.left.arrow.right"
        case .settings: "gear"
        }
    }
}
