//
//  MatchCompletionView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 7/11/25.
//

import SwiftUI

struct MatchCompletionView: View {
    let correct: Int
    let total: Int
    let continueAction: () -> Void
    
    private var accuracy: Double {
        total > 0 ? Double(correct) / Double(total) * 100 : 0
    }
    
    private var trophyColor: Color {
        accuracy >= 90 ? .yellow : accuracy >= 70 ? .orange : .gray
    }
    
    var body: some View {
        VStack(spacing: 32) {
            // Trophy
            Image(systemName: "trophy.fill")
                .font(.system(size: 90))
                .foregroundColor(trophyColor)
                .shadow(color: trophyColor.opacity(0.4), radius: 12, x: 0, y: 6)
                .symbolEffect(.pulse, options: .repeating)
                .scaleEffect(1.05)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: UUID())
            
            // Title
            Text("Match Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Stats Card
            VStack(spacing: 20) {
                StatRow(label: "Matched", value: "\(correct)/\(total)")
                StatRow(label: "Accuracy", value: String(format: "%.0f%%", accuracy), color: accuracy >= 80 ? .green : .orange)
            }
            .font(.title3)
            .fontWeight(.medium)
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
            )
            .padding(.horizontal, 24)
            
            // Play Again Button
            Button("Play Again") {
                continueAction()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.blue)
            .fontWeight(.semibold)
            .scaleEffect(1.02)
            .animation(.easeInOut(duration: 0.2), value: UUID())
            
            Spacer()
        }
        .padding(.top, 40)
        .padding(.horizontal)
        .background(Color(.systemBackground))
    }
}

// MARK: - Stat Row
private struct StatRow: View {
    let label: String
    let value: String
    var color: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

#Preview {
    MatchCompletionView(
        correct: 7,
        total: 8,
        continueAction: { print("Play again") }
    )
}
