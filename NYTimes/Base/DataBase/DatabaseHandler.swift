//
//  DatabaseHandler.swift
//  NYTimes
//
//  Created by Senthil on 13/05/23.
//

import Foundation
import CoreData

enum NYContextProcessPriority {
    case main
    case userInitiated
    case userInteractive
    case `default`
    case backgroundSave
    case low
    case createNew
    
    func mainType() -> NYContextProcessPriority {
        if self == .userInitiated || self == .userInteractive {
            return .userInitiated
        }
        if self == .createNew {
            return .createNew
        }
        return .default
    }
    
}

class DatabaseHandler : NSObject {
    static private let queue = DispatchQueue(label: "context.access", attributes: .concurrent)
    
    internal static var sharedInstance: DatabaseHandler = {
        let handler = DatabaseHandler()
        return handler
    }()
    
    override init() {
        super.init()
        if super.isKind(of: DatabaseHandler.self) == false {
            _ = self.mainThreadManagedObjectContext
        }
        
    }
    
    static var mainContext: NSManagedObjectContext!
    
    
    var entityName: String!
    var uniqueIdName: String!

    
    static var currentStoreIdentifier: String = ""
    
    var listSortedKeys: [[String: Any]]! {
        return nil
    }
    
    var processingContexts: SynchronizedDictionary<NYContextProcessPriority, NSManagedObjectContext> = SynchronizedDictionary(dictionary: [:])

    
    
    func contextForThread() -> NSManagedObjectContext? {
        if Thread.isMainThread {
            return DatabaseHandler.mainContext
        }
        return contextFor(prioriry: NYContextProcessPriority.userInitiated)
    }
    
    func contextFor(prioriry: NYContextProcessPriority) -> NSManagedObjectContext? {
        if prioriry == .main {
            return DatabaseHandler.mainContext
        }
        guard let parent = DatabaseHandler.mainContext else {
            return nil
        }
        if let context = processingContexts[prioriry.mainType()] {
            return context
        }
        else {
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.automaticallyMergesChangesFromParent = true
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            context.parent = parent
            processingContexts[prioriry.mainType()] = context
            
            return context
        }
    }
    
    @objc func resetAllHandlers() {
        self.processingContexts.removeAll()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    private lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "NYTimes")
      //  container.persistentStoreDescriptions.append(description)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    private var mainThreadManagedObjectContext: NSManagedObjectContext? {
        didSet {
            if mainThreadManagedObjectContext == nil {
                NotificationCenter.default.removeObserver(self)
                DatabaseHandler.mainContext = nil
            }
        }
    }
    
    func initiateDataBase() {
        if DatabaseHandler.sharedInstance.mainThreadManagedObjectContext == nil {
            DatabaseHandler.currentStoreIdentifier = self.persistentContainer.persistentStoreCoordinator.persistentStores.first?.identifier ?? ""
            
            
            mainThreadManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            mainThreadManagedObjectContext?.name = "\(DatabaseHandler.currentStoreIdentifier)-main"
            
            mainThreadManagedObjectContext?.parent = self.persistentContainer.viewContext
            mainThreadManagedObjectContext?.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
            DatabaseHandler.mainContext = self.mainThreadManagedObjectContext
        }
    }
    
    
    
    func dispatchOnSerialThreadWithContext(priority: NYContextProcessPriority = NYContextProcessPriority.default,_ block: @escaping (NSManagedObjectContext)->()) {
        guard let context = self.contextFor(prioriry: priority) else {
            return
        }
        context.perform {
            block(context)
        }
    }
    
    func getAllObjects(predicate: NSPredicate, sortDesc: [NSSortDescriptor],limit:Int, context: NSManagedObjectContext) -> [Any]? {
        return executeFetchRequest(getFetchRequestForPredicate(predicate: predicate, limit: limit, sort: sortDesc), context: context)
    }
    
    func clearCache() {
        MediaCache.clearCache()
    }
    
    func resetDatabase() {
        guard let storeURL = persistentContainer.persistentStoreCoordinator.persistentStores.first?.url else {
            return
        }
        DatabaseHandler.currentStoreIdentifier = ""
        DatabaseHandler.mainContext.performAndWait {
            DatabaseHandler.mainContext.reset()
            self.destroyAndCreatePersitentStore(storeURL: storeURL)
            DatabaseHandler.sharedInstance.mainThreadManagedObjectContext = nil
        }
        self.clearCache()
    }
    
    private func destroyAndCreatePersitentStore(storeURL: URL) {
        self.persistentContainer.persistentStoreCoordinator.performAndWait {
            do {
                try self.persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
                try self.persistentContainer.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL)
            } catch {
                print(error)
            }
        }
    }
   
    func executeFetchRequest (_ request : NSFetchRequest<NSFetchRequestResult>, context : NSManagedObjectContext) -> [Any]? {
        func objects() -> [Any]? {
            var objects : [Any]?
                do {
                    objects =  try context.fetch(request)
                } catch _ {
                }
            return objects
        }
        if context.name?.contains("main") == true {
            var objs: [Any]?
            context.performAndWait {
                objs = objects()
            }
            return objs
        }
         return objects()
    }
    
    func getSingleObjectOrNewObject(id: String, context: NSManagedObjectContext) -> NSManagedObject? {
        return getNewObject(id: id, context)
    }
    
    func getSingleObject(id: String?, context: NSManagedObjectContext?) -> NSManagedObject? {
        if context != nil {
            var object: NSManagedObject?
            let request = self.getFetchRequest(uniqueId: (id == nil) ? nil : [id!])
            request.fetchLimit = 1
            let objects = self.executeFetchRequest(request, context: context!)
            object = objects?.first as? NSManagedObject
            return object
        }
        return nil
    }
    
    
    func getFetchRequestForPredicate(predicate: NSPredicate?, limit: Int? = nil, sort: [NSSortDescriptor]? = nil,propertiesToFetch:[String]? = nil) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        if limit != nil {
            fetchRequest.fetchLimit = limit!
        }
        if sort != nil {
            fetchRequest.sortDescriptors = sort!
        }
        if propertiesToFetch != nil{
            fetchRequest.propertiesToFetch = propertiesToFetch
            fetchRequest.resultType = .dictionaryResultType
        }
        return fetchRequest
    }
    
    func getFetchRequest(uniqueId: [String]?, sort: Bool = false) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        fetchRequest.includesPendingChanges = true
        if let ids = uniqueId {
            fetchRequest.fetchLimit = uniqueId!.count
            if ids.count == 1 {
                fetchRequest.predicate = NSPredicate(format: "%K == %@",uniqueIdName, ids[0])
            }
            else {
                fetchRequest.predicate = NSPredicate(format: "%K IN %@",uniqueIdName, ids)
            }
        }
        if sort == true {
            fetchRequest.sortDescriptors = self.getSortDescriptors()
        }
        return fetchRequest
    }
    
    func getSortDescriptors(_ sortedKeys: [[String:Any]]? = nil) -> [NSSortDescriptor]  {
        var sortDescriptors : [NSSortDescriptor] = [NSSortDescriptor]()
        for sortKey in sortedKeys ?? listSortedKeys {
            if let type = sortKey["type"] as? Int {
                if type == 0 {//String
                    sortDescriptors.append(NSSortDescriptor(key: sortKey["value"] as? String, ascending: (sortKey["sort"] == nil) ? true : sortKey["sort"] as! Bool, selector: #selector(NSString.caseInsensitiveCompare(_:))))
                }else {
                    sortDescriptors.append(NSSortDescriptor(key: sortKey["value"] as? String, ascending: sortKey["sort"] as! Bool))
                }
            }
        }
        return sortDescriptors
    }
    
    func getNewObject(id: String, _ context: NSManagedObjectContext) -> NSManagedObject? {
        guard let createcontext = contextFor(prioriry: NYContextProcessPriority.createNew) else {
            return nil
        }
        var object: NSManagedObject?
        createcontext.performAndWait {
            if let obj = getSingleObject(id: id, context: createcontext) {
                object = obj
            }
            else {
                let obj = createNewObject(id: id, context: createcontext)
                do {
                        try createcontext.save()
                        object = obj
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }
        if let obj = object?.objectID {
            return context.object(with: obj)
        }
        return nil
    }
    
    func createNewObject(id: String, context: NSManagedObjectContext) -> NSManagedObject {
        let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        entity.setValue(id, forKey: uniqueIdName)
        do {
            try context.obtainPermanentIDs(for: [entity])
        } catch _ {
        }
        return entity
    }
    
    func getAllObjectForPredicate(predicate: NSPredicate?,properties:[String]? = nil, context: NSManagedObjectContext) -> [Any]? {
        return executeFetchRequest(getFetchRequestForPredicate(predicate:predicate, limit: nil, sort: nil, propertiesToFetch:properties ), context: context)
    }
    
    func getFetchResultController(_ predicate: NSPredicate?, sectionKeyPath: String? = nil, sortedKeys: [[String:Any]]? = nil, delegate: NSFetchedResultsControllerDelegate?, sectionIncrement: Int = 0,limit:Int? = 0, exclude: [String]? = nil, context: NSManagedObjectContext = DatabaseHandler.mainContext) -> CustomNSFetchedResultsController {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        fetchRequest.includesPendingChanges = true
        
        fetchRequest.sortDescriptors = getSortDescriptors(sortedKeys)
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 100
        let controller = CustomNSFetchedResultsController(fetchRequest: fetchRequest,
                                                          managedObjectContext: context,
                                                          sectionNameKeyPath: sectionKeyPath,
                                                          cacheName: nil)

        controller.delegate = delegate

        do {
            try controller.performFetch()
        } catch  {
            print(error)
         }
        return controller
    }
    
}

typealias CompletionBlock = () -> ()

private let databaseSavingSerialQueue: DispatchQueue = DispatchQueue(label: "com.avrioc.NYTimes.db.save.root", attributes: DispatchQueue.Attributes.concurrent)

extension NSManagedObjectContext {
    
    func saveContext(completion:  CompletionBlock? = nil) {
        var parentC: Bool = false
        defer {
            if parentC == false {
                databaseSavingSerialQueue.async {
                    completion?()
                }
            }
        }
        if self.hasChanges {
            do {
                try self.save()
                if let root = parent {
                    parentC = true
                    root.perform {
                        root.saveContext(completion: completion)
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
}
