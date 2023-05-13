//
//  MostPopularDetailViewController.swift
//  NYTimes
//
//  Created by Senthil on 13/05/23.
//

import UIKit

final class MostPopularDetailViewController: UIViewController {
    
    var article: MostPopular
    
    private var articleDisplayView : MostPopularDetailsView? {
        return self.view as? MostPopularDetailsView
    }

    
    init(article: MostPopular) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
        Loading View
     */
    
    override func loadView() {
        view = MostPopularDetailsView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUI()
        self.articleDisplayView?.configure(article: article)

    }
    
    /**
        Loading UI
     */
    
    private func loadUI() {
        self.title =  LocalizedString(key: "nytimes.page.article.title")
        self.articleDisplayView?.readArticleButton.addTarget(self, action: #selector(didTapReadArticle), for: .touchUpInside)
    }

}


// MARK: - Button Actions

extension MostPopularDetailViewController {

    @objc fileprivate func didTapReadArticle() {
        if UIApplication.shared.canOpenURL(self.article.url) {
            UIApplication.shared.open(self.article.url)
        }
    }
    

}
