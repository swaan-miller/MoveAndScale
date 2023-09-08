//
//  ContentViewModel.swift
//  MoveAndScale
//
//  Created by Antoine van der Lee on 08/09/2023.
//

import Foundation
import SwiftUI

final class ContentViewModel: ObservableObject {
    @Published var scale: CGFloat = 1.0
    @Published var lastScale: CGFloat = 0
    @Published var offset: CGSize = .zero
    @Published var lastStoredOffset: CGSize = .zero

    var circleRect: CGRect = .zero
    private(set) var yDifference: CGFloat?

    func interactionDidChange(isInteracting: Bool, imageRect: CGRect) {
        if yDifference == nil {
            /// Calculate the constant representing the difference in yOffset
            /// between the circle and the original image rect.
            /// We use this to ensure the image never goes over the minY of the circle.
            yDifference = circleRect.minY - imageRect.minY
        }
        if !isInteracting {

            /// Interaction ended.
            /// Make sure we position the image inside the circle's coordinates
            withAnimation(.easeInOut(duration: 0.4)) {
                /// Make sure the image stays within the circle leading edge.
                if imageRect.minX > circleRect.minX {
                    offset.width = circleRect.minX
                }
                /// Make sure the image stays within the circle top edge.
                if imageRect.minY > circleRect.minY {
                    offset.height = yDifference! //circleRect.minY - (circleRect.height / 2)
                }
                /// Make sure the image stays within the circle trailing edge.
//                if imageRect.maxX < circleRect.width {
//                    offset.width = imageRect.minX - offset.width
//                }
//                /// Make sure the image stays within the circle bottom edge.
//                if imageRect.maxY < circleRect.height {
//                    offset.height = imageRect.minY - offset.height
//                }
            }

            lastStoredOffset = offset
        }
    }

    func resetOriginalImageState() {
        scale = 1.0
        lastScale = 0
        offset = .zero
        lastStoredOffset = .zero
    }
}
