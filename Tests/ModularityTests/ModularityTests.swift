import XCTest
@testable import Modularity

final class ModularityTests: XCTestCase {

    func testLoadingByIdentifier() throws {
        let module = ModuleLoader[TestModuleGroup.self]["ModularityTests.TestModule"]
        XCTAssertEqual(module?.test(), "Hello from TestModule!")
    }

    func testLoadingFromDirectory() throws {
        let modules = ModuleLoader[TestModuleGroup.self].loadFromDirectory("Modules", "ModularityTests")
        modules.forEach { XCTAssertEqual($0.test(), "Hello from TestModule!") }
    }

    func testModuleManager() throws {
        let modules = ModuleLoader[TestModuleGroup.self].getManager()
        try! modules.load("ModularityTests.TestModule")
        modules[{ $0 is TestModule }, { XCTAssertEqual($0.test(), "Hello from TestModule!") }]
    }

}
