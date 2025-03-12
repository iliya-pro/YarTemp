//
//  YarTempTests.swift
//  YarTempTests
//
//  Created by Iliya Prostakishin on 15.04.2024.
//

import XCTest
@testable import YarTemp

final class YarTempTests: XCTestCase {
    let model = YarTempViewModel()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Check model in offline mode
    // To emulate various data errors, offline data strings is used instead of
    // getting real data from the server.
    
    func testValidOfflineData() async {
        await model.refresh(offline:
                                "3.833;1666900230;0.212;6.646;1666869475;1.332;1666841275;6.0732;3.284;758.6;-1.0;-0.2")
        
        XCTAssertNil(model.error, "Model error property should be <nil>")
        
        XCTAssertEqual(model.temperature.value,             3.833)
        XCTAssertEqual(model.temperatureChange.value,       0.212)
        XCTAssertEqual(model.temperatureDayMin.value,       1.332)
        XCTAssertEqual(model.temperatureDayMax.value,       6.646)
        XCTAssertEqual(model.temperatureDayAverage.value,   3.284)
        XCTAssertEqual(model.temperatureDayLastYear.value,  6.0732)
        XCTAssertEqual(model.pressure.value,                758.6)
        XCTAssertEqual(model.pressureChange.value,          -0.2)
    }
    
    func testThrowingErrors() async {
        do {
            func refreshThrow(offline str: DataString) async throws  {
                await model.refresh(offline: str)
                if let error = model.error {
                    print(error.localizedDescription)
                    throw error
                }
            }
            
            let unexpectedDataSize = expectation(description:
                                                    "Expect to throw \(ModelError.unexpectedDataSize(found: 8, needed: 12))")
            do {
                // Use a string, shorten than expected.
                try await refreshThrow(offline:
                                        "3.833;1666900230;0.212;6.646;1666869475;1.332;1666841275;6.0732")
            } catch ModelError.unexpectedDataSize(let found, let needed) {
                if found == 8,
                   needed == 12 {
                    unexpectedDataSize.fulfill()
                }
            }
            
            let undefinedTemperature = expectation(description:
                                                    "Expect to throw \(ModelError.undefinedTemperature)")
            do {
                // Use 'abcd' as temperature.
                try await refreshThrow(offline:
                                        "abcd;1666900230;0.212;6.646;1666869475;1.332;1666841275;6.0732;3.28471111111111;758.6;-1.0;0.0")
            } catch ModelError.undefinedTemperature {
                undefinedTemperature.fulfill()
            }
            
            let temperatureTooHigh = expectation(description:
                                                    "Expect to throw \(ModelError.temperatureTooHigh(100, max: 100))")
            do {
                // Use 100, as temperature.
                try await refreshThrow(offline:
                                        "100;1666900230;0.212;6.646;1666869475;1.332;1666841275;6.0732;3.28471111111111;758.6;-1.0;0.0")
            } catch ModelError.temperatureTooHigh(let val, let max) {
                if val == 100,
                   max == 100 {
                    temperatureTooHigh.fulfill()
                }
            }
            
            let temperatureTooLow = expectation(description:
                                                    "Expect to throw \(ModelError.temperatureTooLow(-100, min: -100))")
            do {
                // Use -100, as temperature.
                try await refreshThrow(offline:
                                        "-100;1666900230;0.212;6.646;1666869475;1.332;1666841275;6.0732;3.28471111111111;758.6;-1.0;0.0")
            } catch ModelError.temperatureTooLow(let val, let min) {
                if val == -100,
                   min == -100 {
                    temperatureTooLow.fulfill()
                }
            }
            
            let undefinedTemperatureChange = expectation(description:
                                                            "Expect to throw \(ModelError.undefinedTemperatureChange)")
            do {
                // Use 'abcd' as temperature change.
                try await refreshThrow(offline:
                                        "3.833;1666900230;abcd;6.646;1666869475;1.332;1666841275;6.0732;3.28471111111111;758.6;-1.0;0.0")
            } catch ModelError.undefinedTemperatureChange {
                undefinedTemperatureChange.fulfill()
            }
            let temperatureChangeTooHigh = expectation(description:
                                                        "Expect to throw \(ModelError.temperatureChangeTooHigh(100, max: 100))")
            do {
                // Use 100, as temperature change.
                try await refreshThrow(offline:
                                        "3.833;1666900230;100;6.646;1666869475;1.332;1666841275;6.0732;3.28471111111111;758.6;-1.0;0.0")
            } catch ModelError.temperatureChangeTooHigh(let val, let max) {
                if val == 100,
                   max == 100 {
                    temperatureChangeTooHigh.fulfill()
                }
            }
            let temperatureChangeTooLow = expectation(description:
                                                        "Expect to throw \(ModelError.temperatureChangeTooLow(-100, min: -100))")
            do {
                // Use -100, as temperature change.
                try await refreshThrow(offline:
                                        "3.833;1666900230;-100;6.646;1666869475;1.332;1666841275;6.0732;3.28471111111111;758.6;-1.0;0.0")
            } catch ModelError.temperatureChangeTooLow(let val, let min) {
                if val == -100,
                   min == -100 {
                    temperatureChangeTooLow.fulfill()
                }
            }

            let undefinedTemperatureDayAverage = expectation(description:
                                                        "Expect to throw \(ModelError.undefinedTemperatureDayAverage)")
            do {
                // Use 'abcd' as average temperature.
                try await refreshThrow(offline:
                                        "3.833;1666900230;0.212;6.646;1666869475;1.332;1666841275;6.0732;abcd;758.6;-1.0;0.0")
            } catch ModelError.undefinedTemperatureDayAverage {
                undefinedTemperatureDayAverage.fulfill()
            }
            let temperatureDayAverageTooHigh = expectation(description:
                                                    "Expect to throw \(ModelError.temperatureDayAverageTooHigh(100, max: 100))")
            do {
                // Use 100, as average temperature.
                try await refreshThrow(offline:
                                        "3.833;1666900230;0.212;6.646;1666869475;1.332;1666841275;6.0732;100;758.6;-1.0;0.0")
            } catch ModelError.temperatureDayAverageTooHigh(let val, let max) {
                if val == 100,
                   max == 100 {
                    temperatureDayAverageTooHigh.fulfill()
                }
            }
            let temperatureDayAverageTooLow = expectation(description:
                                                    "Expect to throw \(ModelError.temperatureDayAverageTooLow(-100, min: -100))")
            do {
                // Use -100, as average temperature.
                try await refreshThrow(offline:
                                        "3.833;1666900230;0.212;6.646;1666869475;1.332;1666841275;6.0732;-100;758.6;-1.0;0.0")
            } catch ModelError.temperatureDayAverageTooLow(let val, let min) {
                if val == -100,
                   min == -100 {
                    temperatureDayAverageTooLow.fulfill()
                }
            }

            let undefinedPressure = expectation(description:
                                                    "Expect to throw \(ModelError.undefinedPressure)")
            do {
                // Use 'abcd' as pressure.
                try await refreshThrow(offline:
                                        "3.833;1666900230;0.212;6.646;1666869475;1.332;1666841275;6.0732;3.28471111111111;abcd;-1.0;0.0")
            } catch ModelError.undefinedPressure {
                undefinedPressure.fulfill()
            }
            let pressureTooHigh = expectation(description: "Expect to throw \(ModelError.pressureTooHigh(1000, max: 1000))")
            do {
                // Use 1000, as presure.
                try await refreshThrow(offline:
                                        "3.833;1666900230;0.212;6.646;1666869475;1.332;1666841275;6.0732;3.28471111111111;1000;-1.0;0.0")
            } catch ModelError.pressureTooHigh(let val, let max) {
                if val == 1000,
                   max == 1000 {
                    pressureTooHigh.fulfill()
                }
            }
            let pressureTooLow = expectation(description:
                                                "Expect to throw \(ModelError.pressureTooLow(0, min: 0))")
            do {
                // Use 0, as pressure.
                try await refreshThrow(offline:
                                        "3.833;1666900230;0.212;6.646;1666869475;1.332;1666841275;6.0732;3.28471111111111;0;-1.0;0.0")
            } catch ModelError.pressureTooLow(let val, let min) {
                if val == 0,
                   min == 0 {
                    pressureTooLow.fulfill()
                }
            }
      
            let undefinedPressureChange = expectation(description:
                                                        "Expect to throw \(ModelError.undefinedPressureChange)")
            do {
                // Use 'abcd' as pressure change.
                try await refreshThrow(offline:
                                        "3.833;1666900230;0.212;6.646;1666869475;1.332;1666841275;6.0732;3.284;758.6;-1.0;abcd")
            } catch ModelError.undefinedPressureChange {
                undefinedPressureChange.fulfill()
            }
            let pressureChangeTooHigh = expectation(description:
                                                        "Expect to throw \(ModelError.pressureChangeTooHigh(1000, max: 1000))")
            do {
                // Use 1000, as presure change.
                try await refreshThrow(offline:
                                        "3.833;1666900230;0.212;6.646;1666869475;1.332;1666841275;6.0732;3.284;758.6;-1.0;1000")
            } catch ModelError.pressureChangeTooHigh(let val, let max) {
                if val == 1000,
                   max == 1000 {
                    pressureChangeTooHigh.fulfill()
                }
            }
            let pressureChangeTooLow = expectation(description:
                                                    "Expect to throw \(ModelError.pressureChangeTooLow(-1000, min: -1000))")
            do {
                // Use -1000, as presure change.
                try await refreshThrow(offline:
                                        "3.833;1666900230;0.212;6.646;1666869475;1.332;1666841275;6.0732;3.284;758.6;-1.0;-1000")
            } catch ModelError.pressureChangeTooLow(let val, let min) {
                if val == -1000,
                   min == -1000 {
                    pressureChangeTooLow.fulfill()
                }
            }

            await fulfillment(of: [
                    unexpectedDataSize,
                    
                    undefinedTemperature,
                    temperatureTooHigh,
                    temperatureTooLow,
                    
                    undefinedTemperatureChange,
                    temperatureChangeTooHigh,
                    temperatureChangeTooLow,
                    
                    undefinedTemperatureDayAverage,
                    temperatureDayAverageTooHigh,
                    temperatureDayAverageTooLow,
                    
                    undefinedPressure,
                    pressureTooHigh,
                    pressureTooLow,
                    
                    undefinedPressureChange,
                    pressureChangeTooHigh,
                    pressureChangeTooLow
                ],
                timeout: 1)
        }
        catch {
            XCTFail("Unexpected error: \(error.localizedDescription).")
        }
    }

    // MARK: - Check model in standard, online mode
    // Now get response from the real server and check the returned data.
    
    func testOnlineData() async throws {
        await model.refresh()
        if (model.error != nil) {
            XCTFail(model.error!.localizedDescription)
        }

        print("Temperature is \(model.temperature).")
        print("Temperature change is \(model.temperatureChange).")
        print("Day min temperature is \(model.temperatureDayMin).")
        print("Day max temperature is \(model.temperatureDayMax).")
        print("Day average temperature is \(model.temperatureDayAverage).")
        print("Day last year temperature is \(model.temperatureDayLastYear).")
        print("Pressure is \(model.pressure).")
        print("Pressure change is \(model.pressureChange).")
    }
    
    func testRefreshingByUser() async throws {
        // When refreshing "by user", local response cache should be ignored
        // when reading.
        
        // Test if cache bypassing really works: a few cosequence calls with
        // cache should consume significantly less time than without cache
        // (at least 2 times less for "cold refresh" and 50 for "hot refresh").
        
        var start = Date()
        
        for _ in 1...5 {
            await model.refresh() // faster, reading from cache
        }
        
        var end = Date()
        let consumedTimeWithCache = end.timeIntervalSince(start)
        
        start = Date()
        
        for _ in 1...5 {
            await model.refresh(by: .user) // slower, reading from server
        }

        end = Date()
        let consumedTimeWithoutCache = end.timeIntervalSince(start)

        print("Requests with cache: \(consumedTimeWithCache) sec")
        print("Requests without cache: \(consumedTimeWithoutCache) sec")
        XCTAssert(consumedTimeWithoutCache / consumedTimeWithCache > 2, "Bypassing local cache should significantly increase requests time")
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
