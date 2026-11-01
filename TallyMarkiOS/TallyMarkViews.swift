//
//  TallyMarkViews.swift
//  TallyMarkiOS
//
//  Created by Miltos on 2/2/25.
//

import SwiftUI

// A single tally mark: vertical line or a diagonal slash.
struct TallyMarkView: View {
    var isSlash: Bool = false
    var markHeight: CGFloat
    var markWidth: CGFloat = 3
    var slashWidth: CGFloat = 0

    var body: some View {
        if isSlash {
            Canvas { context, size in
                var path = Path()
                path.move(to: CGPoint(x: 0, y: size.height))
                path.addLine(to: CGPoint(x: size.width, y: 0))
                context.stroke(path, with: .foreground, lineWidth: markWidth)
            }
            .frame(width: slashWidth, height: markHeight)
        } else {
            Rectangle()
                .frame(width: markWidth, height: markHeight)
        }
    }
}

// A group of tally marks (up to 5).
struct TallyGroupView: View {
    let count: Int  // Count in this group (1...5)
    var markHeight: CGFloat = 30

    private var spacing: CGFloat { markHeight / 5 }
    private var markWidth: CGFloat { max(2, markHeight / 10) }

    /// Width of four marks; the slash overhangs it slightly on each side.
    static func groupWidth(markHeight: CGFloat) -> CGFloat {
        4 * max(2, markHeight / 10) + 3 * (markHeight / 5)
    }

    var body: some View {
        let marks = HStack(spacing: spacing) {
            ForEach(0..<min(count, 4), id: \.self) { _ in
                TallyMarkView(markHeight: markHeight, markWidth: markWidth)
            }
        }
        if count == 5 {
            // A complete group: 4 vertical marks with a slash overlaid.
            ZStack {
                marks
                TallyMarkView(
                    isSlash: true,
                    markHeight: markHeight,
                    markWidth: markWidth,
                    slashWidth: Self.groupWidth(markHeight: markHeight) + spacing
                )
            }
        } else {
            marks
        }
    }
}

// A view that displays tally marks for a total count.
struct TallyMarksView: View {
    let count: Int

    // Scale marks with Dynamic Type so they stay proportional to the surrounding text.
    @ScaledMetric(relativeTo: .title) private var markHeight: CGFloat = 30

    var body: some View {
        let groups = count / 5
        let remainder = count % 5
        let totalGroups = groups + (remainder > 0 ? 1 : 0)

        Group {
            if count == 0 {
                Text("No tallies yet today")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                LazyVGrid(
                    columns: [GridItem(
                        .adaptive(minimum: TallyGroupView.groupWidth(markHeight: markHeight) + markHeight / 2),
                        spacing: markHeight / 2
                    )],
                    alignment: .leading,
                    spacing: markHeight / 3
                ) {
                    ForEach(0..<totalGroups, id: \.self) { index in
                        TallyGroupView(count: index < groups ? 5 : remainder, markHeight: markHeight)
                    }
                }
                .animation(.easeInOut, value: count)
                // The marks are purely visual; read the number instead of each line.
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("\(count) tally marks"))
            }
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
