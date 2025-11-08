//
//  TestCompletionView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 7/11/25.
//

import SwiftUI
import Charts

struct TestCompletionView: View {
    let correct: Int
    let total: Int
    let backToLast: () -> Void
    let continueAction: () -> Void
    
    private var accuracy: Double {
        total > 0 ? Double(correct) / Double(total) * 100 : 0
    }
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.green)
                    .symbolEffect(.pulse, options: .repeating)
                
                Text("Test Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Chart {
                SectorMark(
                    angle: .value("Correct", correct),
                    innerRadius: .ratio(0.62),
                    angularInset: 2
                )
                .foregroundStyle(.green.gradient)
                .cornerRadius(8)
                
                SectorMark(
                    angle: .value("Incorrect", total - correct),
                    innerRadius: .ratio(0.62),
                    angularInset: 2
                )
                .foregroundStyle(.red.gradient)
                .cornerRadius(8)
            }
            .chartLegend(.hidden)
            .frame(height: 180)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .shadow(radius: 4)
            )
            
            VStack(spacing: 12) {
                HStack {
                    Text("Correct")
                        .font(.headline)
                        .foregroundColor(.green)
                    Spacer()
                    Text("\(correct)/\(total)")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Accuracy")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(String(format: "%.1f%%", accuracy))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(accuracy >= 80 ? .green : accuracy >= 50 ? .orange : .red)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                Button("Try Again") {
                    continueAction()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.blue)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .animation(.easeInOut, value: correct)
    }
}

#Preview {
    TestCompletionView(
        correct: 7,
        total: 10,
        backToLast: { print("Back...") },
        continueAction: { print("Retry...") }
    )
}
