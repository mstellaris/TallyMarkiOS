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
    var markHeight: CGFloat = 30
    var markWidth: CGFloat = 2
    
    var body: some View {
        if isSlash {
            Canvas { context, size in
                var path = Path()
                path.move(to: CGPoint(x: 0, y: size.height))
                path.addLine(to: CGPoint(x: size.width, y: 0))
                context.stroke(path, with: .foreground, lineWidth: markWidth)
            }
            .frame(width: markHeight * 0.6, height: markHeight)
        } else {
            Rectangle()
                .frame(width: markWidth, height: markHeight)
        }
    }
}

// A group of tally marks (up to 5).
struct TallyGroupView: View {
    let count: Int  // Count in this group (1...5)
    
    var body: some View {
        if count == 5 {
            // A complete group: 4 vertical marks with a slash overlaid.
            ZStack {
                HStack(spacing: 2) {
                    ForEach(0..<4, id: \.self) { _ in
                        TallyMarkView(isSlash: false)
                    }
                }
                TallyMarkView(isSlash: true)
            }
        } else {
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
    
    private let columns = [GridItem(.adaptive(minimum: 30, maximum: 50))]
    
    var body: some View {
        let groups = count / 5
        let remainder = count % 5
        let totalGroups = groups + (remainder > 0 ? 1 : 0)
        
        if count == 0 {
            Text("0")
                .font(.title2)
                .foregroundStyle(.secondary)
        } else {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                ForEach(0..<totalGroups, id: \.self) { index in
                    if index < groups {
                        TallyGroupView(count: 5)
                    } else {
                        TallyGroupView(count: remainder)
                    }
                }
            }
            .animation(.easeInOut, value: count)
        }
    }
}

#Preview("Tally Marks - 7") {
    TallyMarksView(count: 7)
        .padding()
}

#Preview("Tally Marks - 13") {
    TallyMarksView(count: 13)
        .padding()
}

#Preview("Tally Group - 5") {
    TallyGroupView(count: 5)
        .padding()
}
