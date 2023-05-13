//
//  UITableViewController+FetchedResults.swift
//  NYTimes
//
//  Created by Senthil on 13/05/23.
//

import UIKit
import CoreData

class CustomNSFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
    var sectionChanged = false
}

extension UITableViewController: NSFetchedResultsControllerDelegate {

    @objc public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if isViewLoaded && view.window != nil {
            (controller as? CustomNSFetchedResultsController)?.sectionChanged = false
            tableView.beginUpdates()
        }
       
    }
    
    @objc func updateCellForIndexPath(_ indexPath: IndexPath, table: UITableView) {
        let cell = table.cellForRow(at: indexPath)
        if cell != nil {
            table.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    @objc public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if !isViewLoaded || view.window == nil {
            return
        }
        
        if let fetchControl = controller as? CustomNSFetchedResultsController {
            switch type {
            case .insert:
                if let new = newIndexPath {
                    tableView.insertRows(at: [new], with: .fade)
                }
                break
            case .update:
                if newIndexPath == nil || (indexPath == newIndexPath && fetchControl.sectionChanged == false) {
                    if let oldIndexPath = indexPath {
                        updateCellForIndexPath(oldIndexPath, table: self.tableView)
                    }
                  
                }else {
                    if let oldIndexPath = indexPath {
                        tableView.deleteRows(at: [oldIndexPath], with: .fade)
                    }
                    if let new = newIndexPath {
                        tableView.insertRows(at: [new], with: .fade)
                    }
                }
                
                break
            case .move:
                if indexPath == newIndexPath && fetchControl.sectionChanged == false {
                    if let oldIndexPath = indexPath {
                        updateCellForIndexPath(oldIndexPath, table: self.tableView)
                    }
                }
                else {
                    if let oldIndexPath = indexPath {
                        tableView.deleteRows(at: [oldIndexPath], with: .fade)
                    }
                    if let new = newIndexPath {
                        tableView.insertRows(at: [new], with: .fade)
                    }
                }
                break
            case .delete:
                if let oldIndexPath = indexPath {
                    tableView.deleteRows(at: [oldIndexPath], with: .fade)
                }
                break
            
            @unknown default:
                break
            }
        }
       
        
    }
    
    @objc public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if !isViewLoaded || view.window == nil {
            return
        }
        if let fetchControl = controller as? CustomNSFetchedResultsController {
            switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
                fetchControl.sectionChanged = true
                break
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
                fetchControl.sectionChanged = true
                break
            default:
                return
            }
        }

    }
    
    @objc public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
