//
//  MostPopular.swift
//  NYTimes
//
//  Created by Senthil on 13/05/23.
//

import Foundation
import CoreData


/**
    MostPopularFetchResult Error Enum
 */
enum MostPopularFetchResult {
    case success
    case error(APIError)
}

//MARK: -   Most Popular Articles list decodable data model

/**
    Most Popular Articles list decodable data model
 */

struct MostPopular: Decodable {
    
    /**
        Static Time period. It will fetch based on time period
     */
    static let period = 1
    
    let id: Int
    let title: String
    let author : String
    let url : URL
    
    var section: String?
    var source : String?
    var abstract: String?
    
    private var dateString: String?
    fileprivate var media: [Media]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case section
        case dateString = "published_date"
        case media = "media"
        case author = "byline"
        case url
        case source
        case abstract

    }
    
    private var _date : Date?
    var date : Date? {
        if let date = _date {
            return date
        }else if let dtStr = self.dateString {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-mm-dd"
            let date = dateFormatter.date(from: dtStr)
            return date
        }
        return nil
    }
    
    private var _thumbnail : String?
    var thumbnail : String? {
        if let thumb = _thumbnail {
            return thumb
        }else if let mediaMeta = media?.first?.meta {
            guard  mediaMeta.count > 0 else {return nil}
            return (mediaMeta.first(where: {$0.format == "Standard Thumbnail"}) ?? mediaMeta[0]).url
        }
        return nil
    }
    
    private var _coverPic : String?
    var coverPic : String? {
        if let cover = _coverPic {
            return cover
        }else if let mediaMeta = media?.first?.meta {
            guard  mediaMeta.count > 0 else {return nil}
            return (mediaMeta.max(by: {$0.size() <= $1.size()}) ?? mediaMeta[0]).url
        }
        return nil
    }
    
    fileprivate init(id: Int, title: String, url: URL, author: String, date: Date?, thumb:String?) {
        self.id = id
        self.title = title
        self.url = url
        self._date = date
        self.author = author
        if let dt = date {
            self.dateString  = dt.string(format: "yyyy-mm-dd")
        }
        self._thumbnail = thumb
    }
    
    fileprivate mutating func setAdditionalDetails(section:String?,abstract:String?,source:String?,coverPic:String?) {
        self.section = section
        self.abstract = abstract
        self.source = source
        self._coverPic = coverPic
    }
    
    static func fetchList(completion:@escaping(MostPopularFetchResult)->()) {
        APIManager.shared.execute(MostPopular.request(for: period)) {  result in
            switch result {
            case .success(let page):
                let  mostPopular = page.results
                MostPopularSyncHandler.sharedHandler.save(mostPopular)
                completion(.success)
            case .failure(let error):
                completion(.error(error))

            }
        }
    }
}


extension MostPopular {
    static func request(for period: Int) -> Request<Response<MostPopular>>{
        return Request(method: .get, path: "mostpopular/v2/viewed/\(period).json")
    }
}

fileprivate struct Media : Decodable {
    let meta : [MediaMeta]?

    enum CodingKeys: String, CodingKey {
        case meta = "media-metadata"
    }
    struct MediaMeta   : Decodable {
        let url: String?
        let format: String?
        let height: Int
        let width: Int
        
        func size () -> CGSize {
            return CGSize(width: width, height: height)
        }
    }
}

//MARK: -  Most Popular Articles list core data model
/**
    Most Popular Articles list core data model
 */
@objc(MostPopularEntity)
class MostPopularEntity: NSManagedObject {

    var dataSource : MostPopular? {
        if let title = self.title, let author = self.author, let url = self.url {
            var data =  MostPopular(id: Int(self.id) ?? 0,
                                    title: title, url: url, author: author,
                                    date: self.date,
                                    thumb: self.thumbnail)
            data.setAdditionalDetails(section: self.section, abstract: self.abstract, source: self.source, coverPic: self.coverPic)
            return data
        }
        return nil
    }
}

fileprivate extension MostPopularEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<MostPopularEntity> {
        return NSFetchRequest<MostPopularEntity>(entityName: "MostPopularEntity")
    }
    
    @NSManaged  var id: String!
    @NSManaged  var author: String?
    @NSManaged  var date: Date?
    @NSManaged  var section: String?
    @NSManaged  var title: String?
    @NSManaged  var thumbnail: String?
    @NSManaged  var source: String?
    @NSManaged  var abstract: String?
    @NSManaged  var coverPic: String?
    @NSManaged  var url: URL?
}

//MARK: -   Most Popular Articles list core data entity handler

class MostPopularSyncHandler : DatabaseHandler {
    
    static var sharedHandler: MostPopularSyncHandler = {
        let handler = MostPopularSyncHandler()
        handler.entityName = "MostPopularEntity"
        handler.uniqueIdName = "id"
        return handler
    }()
    
    override var listSortedKeys: [[String : Any]]! {
        return [["value":"date" ,"type": 1 , "sort": false ]]
        
    }
        
    fileprivate func save( _ mostPopular: [MostPopular]) {
        dispatchOnSerialThreadWithContext(priority: .userInteractive) { context in
            for popular in mostPopular {
                if let obj = self.getSingleObjectOrNewObject(id: "\(popular.id)", context: context) as? MostPopularEntity {
                    obj.author = popular.author
                    obj.title = popular.title
                    obj.section = popular.section
                    obj.date = popular.date
                    obj.thumbnail = popular.thumbnail
                    obj.url = popular.url
                    obj.coverPic = popular.coverPic
                    obj.abstract = popular.abstract
                    obj.source = popular.source
                }
            }
            let uniqueIDs = mostPopular.compactMap({"\($0.id)"})
            self.deleteNonSyncItems(ids: uniqueIDs, context: context)
            context.saveContext()
        }
    }
    
    private func deleteNonSyncItems(ids:[String], context:NSManagedObjectContext) {
        if  let objects = self.getAllObjectForPredicate(predicate: NSPredicate(format: "NOT %K IN %@",uniqueIdName, ids), context: context) as? [NSManagedObject] {
            for object in objects {
                context.delete(object)
            }
        }
    }
}



