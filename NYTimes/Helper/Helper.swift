//
//  Helper.swift
//  NYTimes
//
//  Created by Senthil on 13/05/23.
//

import Foundation

func LocalizedString(key: String) -> String {
    return NSLocalizedString(key, comment: "")
}
func LocalizedString(key: String, arguments: CVarArg...) -> String {
    return  String(format: NSLocalizedString(key, comment: ""), arguments)
}


func NYDispatchOnMainThread(_ block: @escaping ()->())
{
    if Thread.isMainThread {
        block()
    }
    else {
        DispatchQueue.main.async(execute: block)
    }
}


/* dictionary that allows thread safe concurrent access */
class SynchronizedDictionary<KeyType:Hashable,ValueType> : NSObject, ExpressibleByDictionaryLiteral {

    private var internalDictionary : [KeyType:ValueType]

    private let queue = DispatchQueue(label: "dictionary.access", attributes: .concurrent)

    var count : Int {
        return self.queue.sync {
            return self.internalDictionary.count
        }
    }
    // safely get or set a copy of the internal dictionary value
    var dictionary : [KeyType:ValueType] {
        get {
            return self.queue.sync {
                return self.internalDictionary
            }
        }
        set {
            let dictionaryCopy = newValue
            self.queue.async(flags: .barrier) {
                self.internalDictionary = dictionaryCopy
            }
        }
    }
    
    var keys : Dictionary<KeyType,ValueType>.Keys {
        get {
            return self.queue.sync {
                return self.internalDictionary.keys
            }
        }
    }
    
    
    var values : Dictionary<KeyType,ValueType>.Values {
        return self.queue.sync {
            return self.internalDictionary.values
        }
    }
    /* initialize an empty dictionary */
    override convenience init() {
        self.init( dictionary: [KeyType:ValueType]() )
    }
    /* allow a concurrent dictionary to be initialized using a dictionary literal of form: [key1:value1, key2:value2, ...] */
    convenience required init(dictionaryLiteral elements: (KeyType, ValueType)...) {
        var dictionary = Dictionary<KeyType,ValueType>()
        for (key,value) in elements {
            dictionary[key] = value
        }
        self.init(dictionary: dictionary)
    }
    /* initialize a concurrent dictionary from a copy of a standard dictionary */
    init( dictionary: [KeyType:ValueType] ) {
        self.internalDictionary = dictionary
    }
    /* provide subscript accessors */
    subscript(key: KeyType) -> ValueType? {
        get {
            return self.queue.sync {
                return self.internalDictionary[key]
            }
        }
        set {
            self.queue.async(flags: .barrier) {
                self.internalDictionary[key] = newValue
            }
        }
    }
    
    /* remove the value associated with the specified key and return its value if any */
    @discardableResult
    func removeValue(forKey key: KeyType) -> ValueType? {
        var oldValue : ValueType? = nil
        // need to synchronize removal for consistent modifications
        self.queue.async(flags: .barrier) {
            oldValue = self.internalDictionary.removeValue(forKey: key)
        }
        return oldValue
    }
    
    func removeAll() {
        self.queue.async(flags: .barrier) {
            self.internalDictionary.removeAll()
        }
    }
}

