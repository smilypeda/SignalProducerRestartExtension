//
//  RestartExtensionSpec.swift
//  RestartExtension
//
//  Created by Alex Peda on 8/16/16.
//  Copyright © 2016 Alex Peda. All rights reserved.
//

import ReactiveCocoa
import Result
import Quick
import Nimble
import Foundation

class RestartExtensionSpec: QuickSpec {
    
    override func spec() {
        
        describe("test for restart command from custom extension") {
            
            it("should restart after given delay") {
                
                var firstCompleted = false
                var restarted = false
                let scheduler = TestScheduler()
                let timeout = 0.5
                
                let producer = SignalProducer<String, NSError> { observer, _ in
                    observer.sendNext("1")
                    observer.sendCompleted()
                }
                
                producer
                    .on(completed: {
                        firstCompleted = true
                    })
                    .restart(withDelay: timeout, on: scheduler)
                    .on(next: { e in
                        if firstCompleted {
                            restarted = true
                        }
                    })
                    .start()
                
                expect(restarted) == false
                
                scheduler.advanceByInterval(timeout*2)
                
                expect(restarted) == true
            }
            
            it("all next events are received") {
                
                var counter: Int = 0
                var observer: Signal<String, NSError>.Observer!
                
                SignalProducer<String, NSError>() { incomingObserver, _ in
                    observer = incomingObserver
                    }
                    .restart(withDelay: 0, on: TestScheduler())
                    .on(next: { e in
                        counter += 1
                    }).start()
                
                observer.sendNext("1")
                observer.sendNext("2")
                observer.sendNext("3")
                
                expect(counter) == 3
            }
            
            context("common logic behavior test") {
                
                var observer: Signal<String, NSError>.Observer!
                var completed = false
                var next = false
                let testError = NSError(domain: "AnyDomain", code: 0, userInfo: nil)
                
                beforeEach {
                    completed = false
                    next = false
                    
                    let producer = SignalProducer<String, NSError>() { incomingObserver, _ in
                        observer = incomingObserver
                    }
                    producer
                        .restart(withDelay: 0, on: TestScheduler())
                        .on(completed: {
                            completed = true
                            
                            },
                            next: { e in
                                next = true
                        }).start()
                }
                
                it("completed event should be received on error") {
                    observer.sendNext("1")
                    
                    expect(next) == true
                    expect(completed) == false
                    
                    observer.sendFailed(testError)
                    expect(completed) == true
                }
                
                it("no completed event if no error") {
                    
                    observer.sendNext("1")
                    observer.sendCompleted()
                    
                    expect(next) == true
                    expect(completed) == false
                }
            }
            
        }
    }
}
