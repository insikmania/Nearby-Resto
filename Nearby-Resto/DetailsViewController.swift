//
//  DetailsViewController.swift
//  Nearby-Resto
//
//  Created by John Bariquit on 17/04/2017.
//  Copyright © 2017 John Bariquit. All rights reserved.
//

import UIKit
import YelpAPI

class HeaderCell: UITableViewHeaderFooterView {
    
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var restaurantPhoneLabel: UILabel!
    @IBOutlet weak var restaurantRatingLabel: UILabel!
    @IBOutlet weak var restaurantCategoryLabel: UILabel!
}

class Cell: UITableViewCell {
    
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var reviewComment: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.clipsToBounds = true
    }
}

class DetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var details = YLPBusiness()
    var list = NSMutableArray()
    
    @IBOutlet weak var tableView: UITableView!
    
    var appDelegate:AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    override func viewDidLoad() {
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 350
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: "HeaderCell", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "Header")
        
        self.loadRestaurantInfo()
        self.loadRestaurantReviews()
        
    }
    
    func loadRestaurantInfo() {
        
        
    }
    
    func loadRestaurantReviews() {
        
        
        
        appDelegate.client?.reviewsForBusiness(withId: details.identifier, completionHandler: {
            (reviews, error) in
            self.list.removeAllObjects()
            self.list.addObjects(from: (reviews?.reviews)!)
            print("reviews: \(self.list)")
        
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! Cell
        let review = list[indexPath.row] as! YLPReview
        cell.userImageView.setImageWith(review.user.imageURL!)
        cell.reviewComment.text = review.excerpt;
        print("text: \(review.excerpt)")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header") as! HeaderCell
        header.backgroundView?.backgroundColor = UIColor.white
        header.tintColor = UIColor.white
        header.restaurantImageView.setImageWith(details.imageURL!)
        header.restaurantNameLabel.text = "Name: \(details.name)"
        header.restaurantPhoneLabel.text = "Phone: \(details.phone)"
        header.restaurantRatingLabel.text = "Ratings: \(details.rating)"
        header.restaurantCategoryLabel.text = "Categories: \(self.stringCategories(details.categories))"
        return header
    }
    
    func stringCategories(_ category: [YLPCategory]) -> String {
        
        var string = ""
        for object in category {
            string += "\(object.name), "
        }
        
        string.remove(at: string.index(before: string.endIndex))
        return string
    }
    
}

