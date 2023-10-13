***REMOVED***
***REMOVED***  FeatureFormSnapshotTest.swift
***REMOVED***  
***REMOVED***
***REMOVED***  Created by Mark on 10/12/23.
***REMOVED***

import XCTest
***REMOVED***
import SnapshotTesting

final class FeatureFormSnapshotTest: XCTestCase {

***REMOVED***override func setUpWithError() throws {
***REMOVED******REMOVED******REMOVED*** Put setup code here. This method is called before the invocation of each test method in the class.
***REMOVED***

***REMOVED***override func tearDownWithError() throws {
***REMOVED******REMOVED******REMOVED*** Put teardown code here. This method is called after the invocation of each test method in the class.
***REMOVED***

***REMOVED***func testExample() throws {
***REMOVED******REMOVED******REMOVED*** This is an example of a functional test case.
***REMOVED******REMOVED******REMOVED*** Use XCTAssert and related functions to verify your tests produce the correct results.
***REMOVED******REMOVED******REMOVED*** Any test you write for XCTest can be annotated as throws and async.
***REMOVED******REMOVED******REMOVED*** Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
***REMOVED******REMOVED******REMOVED*** Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
***REMOVED******REMOVED***
***REMOVED******REMOVED***let bm = BMap.init(style: 5)
***REMOVED******REMOVED***print("*** \(bm)")
***REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let values: [Int] = [1, 2, 3]
***REMOVED******REMOVED***values.map(BMap.init)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let view = MyView()
***REMOVED******REMOVED******REMOVED***assertSnapshot(of: view, as: .image(layout: .sizeThatFits), named: "image")
***REMOVED***
***REMOVED***
***REMOVED***private class BMap {
***REMOVED******REMOVED***private var style: Int = 0
***REMOVED******REMOVED***private var parameters: Int = 0

***REMOVED******REMOVED******REMOVED***@available(*, deprecated, message: "deprecated!")
***REMOVED******REMOVED******REMOVED***init(style: Int) {
***REMOVED******REMOVED******REMOVED******REMOVED***self.style = style
***REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(style: Int, parameters: Int = 99) {
***REMOVED******REMOVED******REMOVED***self.style = style
***REMOVED******REMOVED******REMOVED***self.parameters = parameters
***REMOVED***
***REMOVED***

***REMOVED***func testPerformanceExample() throws {
***REMOVED******REMOVED******REMOVED*** This is an example of a performance test case.
***REMOVED******REMOVED***self.measure {
***REMOVED******REMOVED******REMOVED******REMOVED*** Put the code you want to measure the time of here.
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct MyView: SwiftUI.View {
***REMOVED******REMOVED***var body: some SwiftUI.View {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "testtube.2")
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Some Text")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(Color.red)
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "eraser")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(5)
***REMOVED******REMOVED******REMOVED******REMOVED***.background(RoundedRectangle(cornerRadius: 5.0).fill(Color.blue))
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(10)
***REMOVED***
***REMOVED***

***REMOVED***
***REMOVED******REMOVED***func makeView() -> some View {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "testtube.2")
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Some Text")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(Color.red)
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "eraser")
***REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
