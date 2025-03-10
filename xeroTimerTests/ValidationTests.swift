import XCTest

class ValidationTests: XCTestCase {
    var validationService: ValidationService!
    var testEntry: XeroTimeEntry!
    
    override func setUp() {
        super.setUp()
        validationService = ValidationService.shared
        testEntry = XeroTimeEntry(projectID: "test-project", taskID: "test-task")
    }
    
    override func tearDown() {
        testEntry = nil
        super.tearDown()
    }
    
    func testValidTimeEntry() {
        XCTAssertNoThrow(try validationService.validateTimeEntry(testEntry))
    }
    
    func testEmptyProjectID() {
        testEntry = XeroTimeEntry(projectID: "", taskID: "test-task")
        XCTAssertThrowsError(try validationService.validateTimeEntry(testEntry)) { error in
            XCTAssertEqual(error as? ValidationError, ValidationError.emptyProjectID)
        }
    }
    
    func testEmptyTaskID() {
        testEntry = XeroTimeEntry(projectID: "test-project", taskID: "")
        XCTAssertThrowsError(try validationService.validateTimeEntry(testEntry)) { error in
            XCTAssertEqual(error as? ValidationError, ValidationError.emptyTaskID)
        }
    }
    
    // Add more tests as needed
} 