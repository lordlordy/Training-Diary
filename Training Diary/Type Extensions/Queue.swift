//
//  Queue.swift
//  Training Diary
//
//  Created by Steven Lord on 03/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

/*
 First in first out queue of fix size. You can add to the queue but not manually remove. Once the queue hit's it's maximum size it will get no larger. At this point as each item is added the first item in will be removed.
 The array can be returned.
 The var returnArrayIfLessThanMaximum is set to true it will always return the array. if this is false it will return an empty array.
 */
public struct Queue<T> {
    
    fileprivate var list = LinkedList<T>()
    var maxSize: Int = 1
    var currentSize: Int = 0
    
    public var isEmpty: Bool { return list.isEmpty }
    public var isMaxSize: Bool { return currentSize == maxSize }
    
    //returns the value removed. Returns nil if nothing removed
    public mutating func enqueue(_ element: T) -> T? {
        list.append(element)
        currentSize += 1
        if currentSize > maxSize{
            return dequeue()
        }else{
            return nil
        }
    }
    
    public func array() -> [T]{
        return list.array()
    }
    
    public func peek() -> T? {
        return list.first?.value
    }
    
    public mutating func resetQueue(){
        list = LinkedList<T>()
        currentSize = 0
    }

    //returns the value removed.
    private mutating func dequeue() -> T?{
        currentSize -= 1
        if !list.isEmpty{
            return list.remove(list.first!)
        }else{
            return nil
        }
    }
}
