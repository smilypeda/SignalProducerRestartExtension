//
//  ViewController.swift
//  RestartExtension
//
//  Created by Alex Peda on 8/15/16.
//  Copyright © 2016 Alex Peda. All rights reserved.
//

import UIKit
import ReactiveCocoa

class ViewController: UIViewController {
    
    private var producer: SignalProducer<String, NSError> = {
        return createSignalProducer()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        producer.restart(withDelay: 3.0, on: QueueScheduler.mainQueueScheduler)
                .on(event: {value in print("\(value)")})
                .start()}

    }

    func createSignalProducer() -> SignalProducer<String, NSError> {
        return SignalProducer { observer, outerDisposable in
            observer.sendNext("0")
            observer.sendNext("1")
            observer.sendNext("2")
            observer.sendCompleted()
        }
    }



