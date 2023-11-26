//
//  Dynamic.swift
//  Accountant
//
//  Created by Roman Topchii on 26.11.2023.
//

import Foundation

class Dynamic<T> {
    typealias Listener = (T) -> Void
    
    private var listener: Listener?
    
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
}
