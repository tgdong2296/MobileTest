//
//  Stack.swift
//  MoblileTest
//
//  Created by Giang Dong Trinh on 14/5/24.
//

import Foundation

class Stack<T> {
    private(set) var items: [T] = []
    
    func push(_ item: T) {
        items.append(item)
    }
    
    @discardableResult
    func pop() -> T? {
        return items.popLast()
    }
}
