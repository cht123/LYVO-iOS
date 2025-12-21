//
//  CommitArchiveIcon.swift
//  commit
//
//  Created by Michael Taylor on 11/20/25.
//


import SwiftUI

struct CommitArchiveIcon: View {
    
    let dotSize: CGFloat = 4
    let spacing: CGFloat = 3
    
    var body: some View {
        VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                dot(filled: false)
                dot(filled: false)
                dot(filled: false)
            }
            HStack(spacing: spacing) {
                dot(filled: false)
                dot(filled: true)     // center
                dot(filled: false)
            }
            HStack(spacing: spacing) {
                dot(filled: false)
                dot(filled: false)
                dot(filled: false)
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.001)) // expands tap target
    }
    
    private func dot(filled: Bool) -> some View {
        Circle()
            .fill(filled ? Color.white : Color.white.opacity(0.40))
            .frame(width: dotSize, height: dotSize)
    }
}