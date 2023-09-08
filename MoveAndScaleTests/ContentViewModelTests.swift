//
//  ContentViewModelTests.swift
//  MoveAndScaleTests
//
//  Created by Antoine van der Lee on 08/09/2023.
//

import XCTest
@testable import MoveAndScale

final class ContentViewModelTests: XCTestCase {

    func testImageRemainsWithinLeadingEdgeOfCircle() {
        let viewModel = ContentViewModel()
        viewModel.circleRect = CGRect(x: 20, y: 249, width: 353, height: 353)
        viewModel.interactionDidChange(isInteracting: false, imageRect: CGRect(x: 30, y: 164, width: 393, height: 524))
        XCTAssertEqual(viewModel.offset, CGSize(width: 20, height: 0))
    }

    func testImageRemainsWithinBottomEdgeOfCircle() {
        let viewModel = ContentViewModel()
        viewModel.circleRect = CGRect(x: 20, y: 249, width: 353, height: 353)
        viewModel.interactionDidChange(
            isInteracting: false,
            imageRect: CGRect(x: 30, y: viewModel.circleRect.maxY + 20, width: 393, height: 524)
        )
        XCTAssertEqual(viewModel.offset.height, viewModel.circleRect.minX)
    }

    func testUpdatesYDifference() throws {
        let viewModel = ContentViewModel()
        viewModel.circleRect = CGRect(x: 20, y: 249, width: 353, height: 353)
        let imageRect = CGRect(x: 0, y: 164, width: 393, height: 524)
        viewModel.interactionDidChange(isInteracting: false, imageRect: imageRect)
        let yDifference = try XCTUnwrap(viewModel.yDifference)
        XCTAssertEqual(yDifference, 249 - 164)
    }
}
