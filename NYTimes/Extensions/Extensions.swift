//
//  Extensions.swift
//  NYTimes
//
//  Created by Senthil on 13/05/23.
//

import UIKit

//MARK: -  UIViewController Extension

extension UIViewController {
    
    /**
        Common function to show error alert
     */
    public func showError(_ str: String) {
        let alertController = UIAlertController(title: "", message: str, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: LocalizedString(key: "nytimes.actionButton.ok"), style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    

}

//MARK: -  UIImageView Extension

extension UIImageView {
    
    func dm_setImage(url: String) {
        guard let imageURL = URL(string: url) else {return}
        MediaCache.getImage(imageURL: imageURL) { image in
            self.image = image
        }
    }
    
}

//MARK: -  UITableViewCell Extension

extension UITableViewCell {
    @objc static var dm_defaultIdentifier: String { return String(describing: self) }
}

//MARK: -  UITableView Extension

extension UITableView {
    
    func dm_registerClassWithDefaultIdentifier(cellClass: AnyClass) {
        register(cellClass, forCellReuseIdentifier: cellClass.dm_defaultIdentifier)
    }
    
    func dm_dequeueReusableCellWithDefaultIdentifier<T: UITableViewCell>() -> T? {
        return dequeueReusableCell(withIdentifier: T.dm_defaultIdentifier) as? T
    }
    
    func dm_dequeueReusableCellWithDefaultIdentifier<T: UITableViewCell>(for indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withIdentifier: T.dm_defaultIdentifier, for: indexPath) as? T
    }
    
}


//MARK: -  Date Extension

extension Date {
    func string(format:String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return  dateFormatter.string(from: self)
    }
}

//MARK: -  CGSize Extension

extension CGSize {
    static func <= (left: CGSize, right: CGSize) -> Bool {
        let delta = 0.001
        return (left.width - right.width) < delta && (left.height - right.height) < delta
    }
}
