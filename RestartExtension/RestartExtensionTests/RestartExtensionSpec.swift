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
    
    private let testError = NSError(domain: "AnyDomain", code: 0, userInfo: nil)
    
    override func spec() {
        
        describe("test for restart command from custom extension") {
            
            it("should restart after given delay") {
                
                var firstCompleted = false
                var restarted = false
                let scheduler = QueueScheduler()
                let timeout = 0.5
                
                let producer = SignalProducer<String, NSError> { observer, outerDisposable in
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
                expect(restarted).toEventually(equal(true), timeout: timeout*2)
            }
            
            var observer: Signal<String, NSError>.Observer!
            var producer: SignalProducer<String, NSError>!
            
            beforeEach {
                producer = SignalProducer<String, NSError>() { incomingObserver, disposable in
                    observer = incomingObserver
                }
            }
            
            it("all next events are received") {
                
                var counter: Int = 0
                
                producer
                    .restart(withDelay: 0, on: QueueScheduler())
                    .on(next: { e in
                            counter += 1
                    }).start()
                
                observer.sendNext("1")
                observer.sendNext("2")
                observer.sendNext("3")
                
                expect(counter) == 3
            }
            
            // common behavior test
            
            var completed = false
            var next = false
            
            beforeEach {
                
                completed = false
                next = false
                
                producer
                    .restart(withDelay: 0, on: QueueScheduler())
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
                
                observer.sendFailed(self.testError)
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
