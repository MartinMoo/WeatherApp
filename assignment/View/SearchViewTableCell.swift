//
//  searchViewTableCell.swift
//  assignment
//
//  Created by Martin Miklas on 24/01/2021.
//

import UIKit

class SearchViewTableCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var location: Location? {
        didSet {
            guard let location = location else {
                return
            }
            cellTitleLabel.text = location.city
            cellCountryLabel.text = location.country
        }
    }
    
    let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let cellTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let cellCountryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let cellArrow: UIImageView = {
        let imageView = UIImageView()
        let rightArrow = UIImage(systemName: "chevron.right")?.withTintColor(UIColor.Custom.gray!, renderingMode: .alwaysOriginal)
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = rightArrow?.withAlignmentRectInsets(UIEdgeInsets(top: -16, left: 0, bottom: -16, right: 0))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    fileprivate func setupCellView() {
        addSubview(cellView)
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        cellView.addSubview(cellTitleLabel)
        cellView.addSubview(cellCountryLabel)
        cellView.addSubview(cellArrow)
        
        cellView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        cellView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        cellView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        cellView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        cellTitleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cellTitleLabel.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true
        cellTitleLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor,constant: 15).isActive = true
        cellTitleLabel.trailingAnchor.constraint(equalTo: cellCountryLabel.leadingAnchor).isActive = true
        
        cellCountryLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cellCountryLabel.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true
        cellCountryLabel.trailingAnchor.constraint(equalTo: cellArrow.leadingAnchor,constant: -5).isActive = true
        
        cellArrow.heightAnchor.constraint(equalTo: cellView.heightAnchor).isActive = true
        cellArrow.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -15).isActive = true
        
    }
}
