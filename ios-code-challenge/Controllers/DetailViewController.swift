//
//  DetailViewController.swift
//  ios-code-challenge
//
//  Created by Joe Rocca on 5/31/19.
//  Copyright © 2019 Dustin Lange. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!

    lazy private var favoriteBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Star-Outline"), style: .plain, target: self, action: #selector(onFavoriteBarButtonSelected(_:)))

    @objc var detailItem: YLPBusiness?
    
    private var _favorite: Bool = false
    private var isFavorite: Bool {
        get {
            return _favorite
        } 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        navigationItem.rightBarButtonItems = [favoriteBarButtonItem]
    }
    
    private func configureView() {
        guard let detailItem = detailItem else { return }
        nameLabel.text = detailItem.name
        ratingLabel.text = ratingToStars(rating: detailItem.rating)

        if let thumbnailURL = URL(string: detailItem.thumbnailURLText) {
            thumbnailImage.load(url: thumbnailURL)

            // TODO: Show a default image if we can’t get one from Yelp for some reason
        }

        let formattedDistance = String(format: "%.1f miles",
                                       arguments: [metersToMiles(meters: detailItem.distance)])
        distanceLabel.text = formattedDistance

        reviewCountLabel.text = ("\(String(detailItem.reviewCount)) reviews")
        categoriesLabel.text = categoryTitleList(categories: detailItem.categories)
    }
    
    func setDetailItem(newDetailItem: YLPBusiness) {
        guard detailItem != newDetailItem else { return }
        detailItem = newDetailItem
        configureView()
    }
    
    private func updateFavoriteBarButtonState() {
        favoriteBarButtonItem.image = isFavorite ? UIImage(named: "Star-Filled") : UIImage(named: "Star-Outline")
    }
    
    @objc private func onFavoriteBarButtonSelected(_ sender: Any) {
        _favorite.toggle()
        updateFavoriteBarButtonState()
    }

    // MARK: Data conversion methods

    func ratingToStars(rating: Double) -> String {
        var wholeNumberPart: Double = 0.0
        let fractionPart = modf(rating, &wholeNumberPart)
        let wholeNumberRating = Int(wholeNumberPart)
        let ratingHasHalfStar = (fractionPart == 0.5)

        var stars = String(repeating: "⭐️", count: wholeNumberRating)
        if ratingHasHalfStar {
            stars.append("½")
        }
        return stars
    }

    func metersToMiles(meters: Double) -> Double {
        let METERS_PER_MILE = 1609.344
        return meters / METERS_PER_MILE
    }

    func categoryTitleList(categories: [Any]) -> String {
        // TODO: Update to show full list of categories
        // (Ah, the joys of types...)
        let numCategories = categories.count
        return ("\(numCategories) categories")
    }

}


extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
