import XCTest

class TimeEntryTests: XCTestCase {
    var timeEntry: XeroTimeEntry!
    
    override func setUp() {
        super.setUp()
        timeEntry = XeroTimeEntry(projectID: "test-project", taskID: "test-task")
    }
    
    override func tearDown() {
        timeEntry = nil
        super.tearDown()
    }
    
    func testInitialization() {
        XCTAssertNotNil(timeEntry)
        XCTAssertEqual(timeEntry.projectID, "test-project")
        XCTAssertEqual(timeEntry.taskID, "test-task")
        XCTAssertEqual(timeEntry.description, "")
        XCTAssertFalse(timeEntry.isActive)
        XCTAssertFalse(timeEntry.isPaused)
        XCTAssertNil(timeEntry.endDate)
    }
    
    func testStartTimer() {
        timeEntry.start()
        XCTAssertTrue(timeEntry.isActive)
        XCTAssertFalse(timeEntry.isPaused)
    }
    
    func testPauseTimer() {
        timeEntry.start()
        Thread.sleep(forTimeInterval: 2)
        timeEntry.pause()
        
        XCTAssertTrue(timeEntry.isPaused)
        let pausedDuration = timeEntry.duration
        
        Thread.sleep(forTimeInterval: 2)
        XCTAssertEqual(timeEntry.duration, pausedDuration)
    }
    
    func testResumeTimer() {
        timeEntry.start()
        timeEntry.pause()
        timeEntry.resume()
        
        XCTAssertTrue(timeEntry.isActive)
        XCTAssertFalse(timeEntry.isPaused)
    }
    
    func testStopTimer() {
        timeEntry.start()
        Thread.sleep(forTimeInterval: 2)
        timeEntry.stop()
        
        XCTAssertFalse(timeEntry.isActive)
        XCTAssertNotNil(timeEntry.endDate)
        XCTAssertGreaterThan(timeEntry.duration, 0)
    }
} 