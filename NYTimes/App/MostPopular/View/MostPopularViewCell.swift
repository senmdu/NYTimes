//
//  MostPopularViewCell.swift
//  NYTimes
//
//  Created by Senthil on 13/05/23.
//

import UIKit

class MostPopularListViewCell: UITableViewCell {
    
    private static let coverImageHeightWidth : CGFloat = 75
    
    //MARK: -   UI Elements
    
    private let coverImage : UIImageView = {
        let img = UIImageView()
        img.backgroundColor = .systemGray
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        img.layer.cornerRadius = MostPopularListViewCell.coverImageHeightWidth / 2
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
     let titleLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor =  UIColor(named: "Black")
        lbl.numberOfLines = 3
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        lbl.lineBreakMode = .byTruncatingTail
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let authorLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor =  .systemGray
        lbl.numberOfLines = 0
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .light)
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()
    
    private let dateLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor =  .systemGray
        lbl.numberOfLines = 1
        lbl.textAlignment = .right
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .light)
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()
    
    let containerStackView : UIStackView  = {
        let stcView =  UIStackView()
        stcView.spacing = 10
        stcView.alignment = .top
        stcView.axis = .vertical
        stcView.translatesAutoresizingMaskIntoConstraints = false
        return stcView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        contentView.layoutMargins = UIEdgeInsets(top: 20, left: 25, bottom: 20, right: 20)
        setupViewsHierarchy()
        setupConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    /**
     Adding Views to `Hierarchy`
     */
    
    func setupViewsHierarchy() {
        contentView.addSubview(self.coverImage)
        contentView.addSubview(self.containerStackView)
        
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(authorLabel)
        
        let calendarImage = UIImageView(image: UIImage(systemName: "calendar"))
        calendarImage.tintColor = .systemGray
        let dateLabelContainer = UIStackView(arrangedSubviews: [calendarImage,dateLabel])
        dateLabelContainer.spacing = 8
        containerStackView.addArrangedSubview(dateLabelContainer)
        
        
    }
    
    /**
     Setting up `Constraints`
     */
    
    func setupConstraints() {
    
        NSLayoutConstraint.activate([
            coverImage.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            coverImage.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            coverImage.heightAnchor.constraint(equalToConstant: MostPopularListViewCell.coverImageHeightWidth),
            coverImage.widthAnchor.constraint(equalToConstant: MostPopularListViewCell.coverImageHeightWidth),
            
            containerStackView.leadingAnchor.constraint(equalTo: coverImage.trailingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            containerStackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            
        ])
    }
    
    /**
     Configuring `Details`
     */
    
    func configure(_ popular: MostPopular) {
        self.accessoryType = .disclosureIndicator
        self.titleLabel.text = popular.title
        self.authorLabel.text = popular.author
        self.dateLabel.text = popular.date?.string(format: "yyyy-mm-dd")
        if let thumb = popular.thumbnail {
            self.coverImage.dm_setImage(url: thumb)
        }else {
            self.coverImage.image = nil
        }
        
    }
}
