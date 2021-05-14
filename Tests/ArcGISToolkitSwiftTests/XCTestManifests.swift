import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(arcgis_runtime_toolkit_swiftTests.allTests),
    ]
}
#endif
