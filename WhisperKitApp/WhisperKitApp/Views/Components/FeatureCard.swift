//
//  FeatureCard.swift
//  WhisperKitApp
//
//  Reusable feature card component for Examples page
//

import SwiftUI

struct FeatureCard: View {
    let title: String
    let description: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(.blue)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FeatureCard(
        title: "Basic Transcription",
        description: "Test transcription with audio files",
        icon: "doc.text"
    ) {
        print("Tapped")
    }
    .padding()
    .frame(width: 250)
}
