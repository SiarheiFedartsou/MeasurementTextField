//
//  SwiftProductGenerator.swift
//
//
//  Created by Øyvind Grimnes on 09/09/15.
//
//

import Foundation

/**
 A cartesian product generator
 :discussion:    Generates the cartesian product of collections, or repetitions
 of a collection. The rightmost element is advanced every
 iteration which ensures that if the input is sorted, the
 output will be sorted as well.
 */
internal struct Product<T, C: Collection>: IteratorProtocol, Sequence
    where C.Iterator.Element == T
{
    
    /// Private variable to manage where to get next element in each pool
    private var indices : [C.Index]
    /// Pool containing all the collections to be combined
    private var pools   : [C]
    /// Terminate the generation on completion
    private var done    : Bool = false
    
    
    /**
     Initiates the generator with an array of collections to be combined.
     :param:        collections    array containing the collections to be
     combined
     */
    internal init(_ collections: [C]) {
        self.pools   = collections
        self.indices = collections.map{ $0.startIndex }
        self.done    = pools.reduce(true, { $0 && $1.count == 0 })
    }
    
    /**
     Initiates the generator with a collection repeated 'count' times.
     :param:        repeating      collection to be combined with itself
     :param:        count          number of times to repeat the collection
     */
    
    internal init(repeating collection: C, count: Int) {
        precondition(count >= 0, "count must be >= 0")
        self.init([C](repeating: collection, count: count))
    }
    
    
    /**
     Generates the next element and returns it.
     */
    internal mutating func next() -> [T]? {
        if done {
            return nil
        }
        
        let element = self.pools.enumerated().map {
            $1[ self.indices[$0] ]
        }
        
        self.incrementLocationInPool(poolIndex: self.pools.count - 1)
        return element
    }
    
    
    /**
     Increments the indices of the collections in the pools.
     :discussion:   The location in the pool for the provided 'poolIndex' will
     be incremented. If the new location is out of range, the
     location is set to zero and the location in the preceding
     pool will be incremented. If 'poolIndex' is less than zero,
     the generation is complete.
     :param:        poolIndex      index of the pool for which to update the
     location
     :returns:      An array containing the products of the provided array
     repeated 'repeat' times
     */
    mutating private func incrementLocationInPool(poolIndex: Int) {
        guard self.pools.indices.contains(poolIndex) else {
            done = true
            return
        }
        
        self.indices[poolIndex] = self.pools[poolIndex].index(after: self.indices[poolIndex])
        
        if self.indices[poolIndex] == self.pools[poolIndex].endIndex {
            self.indices[poolIndex] = self.pools[poolIndex].startIndex
            self.incrementLocationInPool(poolIndex: poolIndex - 1)
        }
    }
    
    
    /**
     Returns a cartesian product generator.
     :returns:      A cartesian product generator
     */
    internal func generate() -> Product {
        return self
    }
}
