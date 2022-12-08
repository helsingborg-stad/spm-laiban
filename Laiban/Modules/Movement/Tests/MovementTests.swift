//
//  MovementTests.swift
//  
//
//  Created by Fredrik Häggbom on 2022-11-10.
//

import XCTest
@testable import Laiban

final class MovementTests: XCTestCase {
    let service = MovementService()
    var settingsBackup: MovementSettings?
    var activitiesBackup: [MovementActivity]?
    var movementBackup: [Movement]?
    
    override func setUpWithError() throws {
        movementBackup = service.data.movement
        settingsBackup = service.data.settings
        activitiesBackup = service.data.activities
    }

    override func tearDownWithError() throws {
        if let movementBackup = movementBackup {
            service.data.movement = movementBackup
        }
        if let settingsBackup = settingsBackup {
            service.data.settings = settingsBackup
        }
        if let activitiesBackup = activitiesBackup {
            service.data.activities = activitiesBackup
        }
    }

    func testVerifyInitialData() throws {
        XCTAssertTrue(service.data.activities.count > 0)
        XCTAssertTrue(service.data.settings.stepLength > 0)
        XCTAssertTrue(service.data.settings.maxMetersPerDay > 0)
        XCTAssertTrue(service.data.settings.stepsPerMinute > 0)
    }
    
    func testAddMovement() throws {
        let initialMeters = service.movementManager.movementMeters()
        service.add(Movement(minutes: 60, date: Date(), numMoving: 20))
        
        let updatedMeters = service.movementManager.movementMeters()
        XCTAssertNotEqual(initialMeters, updatedMeters)
    }
    
    func testAddAndRemoveMovement() throws {
        let initialMeters = service.movementManager.movementMeters()
        let movement = Movement(minutes: 60, date: Date(), numMoving: 20)
        service.add(movement)
        
        var updatedMeters = service.movementManager.movementMeters()
        XCTAssertNotEqual(initialMeters, updatedMeters)
        
        service.remove(movement)
        updatedMeters = service.movementManager.movementMeters()
        XCTAssertEqual(initialMeters, updatedMeters)
    }
    
    func testAddActivity() throws {
        let initialNumberOfActivities = service.data.activities.count
        XCTAssertNotEqual(initialNumberOfActivities, 0)
        let newActivity = MovementActivity(id: UUID().uuidString, colorString: MovementActivity.colorStrings.randomElement()!, title: "Testactivity", emoji: "📶")
        service.addActivity(newActivity: newActivity, callback: {})
        
        var updatedNumberOfActivities = service.data.activities.count
        XCTAssertEqual(initialNumberOfActivities + 1, updatedNumberOfActivities)
        
        XCTAssertNotNil(service.data.activities.first { $0.id == newActivity.id })
        
        service.deleteActivity(activity: newActivity, callback: {})
        updatedNumberOfActivities = service.data.activities.count
        XCTAssertEqual(initialNumberOfActivities, updatedNumberOfActivities)
    }
    
    func testSettings() throws {
        service.add(Movement(minutes: 60, date: Date(), numMoving: 20))
        service.add(Movement(minutes: 30, date: Date(), numMoving: 15))

        let initialMeters = service.movementManager.movementMeters()
        service.data.settings.stepsPerMinute = service.data.settings.stepsPerMinute / 2
        let updatedMeters = service.movementManager.movementMeters()
        XCTAssertEqual(initialMeters / 2, updatedMeters)
    }
}
