//
//  Untitled.swift
//  TallyMarkiOS
//
//  Created by Miltos on 2/2/25.
//

import SwiftUI

// A single tally mark: vertical line or a diagonal slash.
struct TallyMarkView: View {
    var isSlash: Bool = false
    
    var body: some View {
        if isSlash {
            Rectangle()
                .frame(width: 2, height: 30)
                // Rotate around the bottom-leading corner so that the slash
                // originates from the bottom left of its rectangle.
                .rotationEffect(.degrees(45), anchor: .bottomLeading)
                // Adjust the offset to fine-tune the position.
                .offset(x: -20, y: -5)
        } else {
            Rectangle()
                .frame(width: 2, height: 30)
        }
    }
}

// A group of tally marks (up to 5).
struct TallyGroupView: View {
    let count: Int  // Count in this group (1...5)
    
    var body: some View {
        if count == 5 {
            // A complete group: 4 vertical marks and one slash.
            HStack(spacing: 2) {
                ForEach(0..<4, id: \.self) { _ in
                    TallyMarkView(isSlash: false)
                }
                TallyMarkView(isSlash: true)
            }
        } else {
            // An incomplete group: just draw the vertical tallies.
            HStack(spacing: 2) {
                ForEach(0..<count, id: \.self) { _ in
                    TallyMarkView(isSlash: false)
                }
            }
        }
    }
}

// A view that displays tally marks for a total count.
struct TallyMarksView: View {
    let count: Int
    
    var body: some View {
        // Calculate the number of complete groups of 5 and the remainder.
        let groups = count / 5
        let remainder = count % 5
        
        return HStack(spacing: 8) {
            ForEach(0..<groups, id: \.self) { _ in
                TallyGroupView(count: 5)
            }
            if remainder > 0 {
                TallyGroupView(count: remainder)
            }
        }
        .animation(.easeInOut, value: count) // Animate changes to the count.
    }
}
