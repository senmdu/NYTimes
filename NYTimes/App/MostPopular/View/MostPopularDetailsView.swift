//
//  MostPopularDetailsView.swift
//  NYTimes
//
//  Created by Senthil on 13/05/23.
//

import UIKit


final class MostPopularDetailsView: UIView {
    
    //MARK: -   UI Elements
    
    private let scrollView : UIScrollView = {
        let scView = UIScrollView()
        scView.translatesAutoresizingMaskIntoConstraints = false
        return scView
    }()
    
    private let backdropImageView :  UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        imgView.isUserInteractionEnabled = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    private let sourceLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor =  .systemGray4
        lbl.numberOfLines = 1
        lbl.textAlignment = .left
        lbl.font = .italicSystemFont(ofSize: 16)
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()
    
    private let titleLabel : UILabel = {
        let lbl = UILabel()
        lbl.accessibilityIdentifier = "article_title"
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        lbl.textColor = UIColor(named: "Black")
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.setContentHuggingPriority(.required, for: .vertical)
        return lbl
    }()
    
    private let overviewLabel : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .light)
        lbl.textColor = UIColor.systemGray
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()
    
    private let dateLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor =  .systemGray2
        lbl.numberOfLines = 1
        lbl.textAlignment = .right
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .light)
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()
    
    
    private lazy var contentStackView :  UIStackView  = {
        let stackView  = UIStackView(arrangedSubviews: [backdropImageView, sourceLabel, titleLabel, overviewLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 25
        stackView.setCustomSpacing(8, after: titleLabel)
        stackView.setCustomSpacing(4, after: backdropImageView)
        stackView.setCustomSpacing(18, after: sourceLabel)
        return stackView
    }()
    
    private let authorLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor =  .systemBrown
        lbl.numberOfLines = 0
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()
    
    let readArticleButton : UIButton = {
        let lbl = UIButton()
        lbl.backgroundColor = .systemBlue
        lbl.setTitleColor(.white, for: .normal)
        lbl.accessibilityIdentifier = "read_article_button"
        lbl.setTitle("Read Full Article", for: .normal)
        lbl.layer.cornerRadius = 8
        lbl.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .systemBackground
        
        setupViewsHierarchy()
        setupConstraints()
    }
    /**
     Adding Views to `Hierarchy`
     */
    private func setupViewsHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        let calendarImage = UIImageView(image: UIImage(systemName: "calendar"))
        calendarImage.tintColor = .systemGray2
        
        let dateStackView = UIStackView(arrangedSubviews: [calendarImage,dateLabel])
        dateStackView.spacing = 8
        
        let dateAuthorStackView =  UIStackView(arrangedSubviews: [authorLabel,dateStackView])
        dateAuthorStackView.spacing = 4
        dateAuthorStackView.alignment = .trailing
        dateAuthorStackView.axis = .vertical
        
        contentStackView.addArrangedSubview(dateAuthorStackView)
        contentStackView.setCustomSpacing(25, after: dateAuthorStackView)
        contentStackView.addArrangedSubview(readArticleButton)
    }
    /**
     Setting up `Constraints`
     */
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                // ScrollView Constraints
                scrollView.topAnchor.constraint(equalTo: topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
                scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
                
                backdropImageView.heightAnchor.constraint(equalTo: backdropImageView.widthAnchor, multiplier: 11 / 16, constant: 0),
                
                readArticleButton.heightAnchor.constraint(equalToConstant: 50),

                
                // Content Stackview Constraints
                contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
                contentStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
                contentStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
                contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24)
            ]
        )
    
        
        scrollView.layoutMargins = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
        preservesSuperviewLayoutMargins = false
    }
    /**
     Configuring `Details`
     */
    func configure(article: MostPopular) {
        if let backDropImage = article.coverPic ?? article.thumbnail {
            backdropImageView.dm_setImage(url: backDropImage)
        }
       
        titleLabel.text = article.title
        overviewLabel.text = article.abstract
        dateLabel.text = article.date?.string(format: "MMM dd,yyyy")
        authorLabel.text = article.author
        if let source = article.source {
            sourceLabel.text = LocalizedString(key: "nytimes.page.article.source", arguments: source)
        }

    }
}
