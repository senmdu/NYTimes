//
//  MostPopularListViewController.swift
//  NYTimes
//
//  Created by Senthil on 13/05/23.
//

import UIKit
import CoreData

class MostPopularListViewController: UITableViewController {
    
    /**
       Setting FetchControl
     */
    lazy var fetchControl : CustomNSFetchedResultsController = {
        return MostPopularSyncHandler.sharedHandler.getFetchResultController(nil,sortedKeys: MostPopularSyncHandler.sharedHandler.listSortedKeys, delegate: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUI()
        setupTableView()
        fetchMostPopular()
    }
    
    /**
        Loading UI
     */
    private func loadUI() {
        self.title = LocalizedString(key: "nytimes.page.popular.title")
    }
    
    /**
        Setting `TableView` for articles list
     */
    private func setupTableView() {
        self.tableView.dm_registerClassWithDefaultIdentifier(cellClass: MostPopularListViewCell.self)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.bounces = true
        self.tableView.alwaysBounceVertical = true

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(fetchMostPopular), for: .valueChanged)

    }
}


//MARK: - API

extension MostPopularListViewController {
    @objc func fetchMostPopular() {
        if self.fetchControl.fetchedObjects?.count == 0 {
            self.showLoaderIndicatorView()
        }
        MostPopular.fetchList { result in
            NYDispatchOnMainThread {
                self.hideIndicatorView()
                self.refreshControl?.endRefreshing()
                if case .error(let aPIError) = result {
                    if aPIError == .networkError {
                        self.showError(LocalizedString(key: "nytimes.load.error.internet"))
                    }else {
                        self.showError(LocalizedString(key: "nytimes.load.error.unknown"))
                    }
                }
            }
        }

    }
}

// MARK: - TableViewDataSource
extension MostPopularListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchControl.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: MostPopularListViewCell = tableView.dm_dequeueReusableCellWithDefaultIdentifier(for: indexPath) else {
            return UITableViewCell()
        }
        cell.titleLabel.accessibilityIdentifier = "cell_\(indexPath.row)_title"
        cell.accessibilityIdentifier = "cell_\(indexPath.row)"
        if let popular = fetchControl.object(at: indexPath) as? MostPopularEntity, let dataSource = popular.dataSource {
            cell.contentView.isHidden = false
            cell.configure(dataSource)
        }else {
            cell.contentView.isHidden = true
        }
        return cell
    }
    
}

// MARK: - TableViewControllerDelegate
extension MostPopularListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let popular = fetchControl.object(at: indexPath) as? MostPopularEntity, let dataSource = popular.dataSource {
            let viewController = MostPopularDetailViewController(article: dataSource)
            if UIDevice.current.userInterfaceIdiom == .pad {
                viewController.modalPresentationStyle = .pageSheet
                let nav = UINavigationController(rootViewController: viewController)
                nav.navigationBar.prefersLargeTitles = true
                self.navigationController?.present(nav, animated: true)
            }else {
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }

    }
}
