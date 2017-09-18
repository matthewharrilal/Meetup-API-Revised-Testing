//
//  ViewController.swift
//  Meetup-API-Revised-Testing
//
//  Created by Matthew Harrilal on 9/18/17.
//  Copyright © 2017 Matthew Harrilal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let network1 = Networking()
        print(network1.network())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

struct meetupListings {
    let country:String?
    let city:String?
    let name: String?
    let amount: Int?
    let accepts: String?
    let description: String?
    let currency: String?
    let label: String?
    let required: String?
    init(country: String?, city: String?, name: String?, amount: Int?, accepts: String?, description:String?,currency:String?,label:String?,required:String?) {
        self.country = country
        self.city = city
        self.name = name
        self.amount = amount
        self.accepts = accepts
        self.description = description
        self.currency = currency
        self.label = label
        self.required = required
    }
}

extension meetupListings: Decodable {
    enum firstLayer: String, CodingKey {
        case venue
    }
    enum fee: String, CodingKey {
        case fee
    }
    enum feeKeys: String, CodingKey {
        case amount
        case accepts
        case description
        case currency
        case label
        case required
        
    }
    enum Keys: String, CodingKey {
        case country
        case city
        case name
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: firstLayer.self)
        let feeContainer = try decoder.container(keyedBy: fee.self)
        let fees = try feeContainer.nestedContainer(keyedBy: feeKeys.self, forKey: .fee)
        let amount = try fees.decodeIfPresent(Int.self, forKey: .amount) ?? Int("The amount for this listing is not available")
        let accepts = try fees.decodeIfPresent(String.self, forKey: .accepts) ?? "The form of payment you are trying to use is not accepted by this meetup listing"
        let currency = try fees.decodeIfPresent(String.self, forKey: .currency) ?? "The form of currency you are trying to use is not accepted by this meetup listing"
        let label = try fees.decodeIfPresent(String.self, forKey: .label) ?? "The label of this listing is not present"
        let required = try fees.decodeIfPresent(String.self, forKey: .required) ?? "The number of people required to attend this meetup listing is not available by this listing"
        let description = try fees.decodeIfPresent(String.self, forKey: .description) ?? "The description of this listing is not available"
        let nestedContainer = try container.nestedContainer(keyedBy: Keys.self, forKey: .venue)
        let country = try nestedContainer.decodeIfPresent(String.self, forKey: .country) ?? "The country of this listing is not present"
        let city = try nestedContainer.decodeIfPresent(String.self, forKey: .city) ?? "The city of this listing is not present"
        let name = try nestedContainer.decodeIfPresent(String.self, forKey: .name) ?? "The name of this listing is not present"
       self.init(country: country, city: city, name: name, amount: amount, accepts: accepts, description: description, currency: currency, label: label, required: required)
    }
}
struct ListingList: Decodable {
    let results: [meetupListings]
}
class Networking {
    func network() {
        let session = URLSession.shared
        var getRequest = URLRequest(url: URL(string: "https://api.meetup.com/2/events?key=6d68436679717c306328646d777e611d&group_urlname=ny-tech&sign=true")!)
        getRequest.httpMethod = "GET"
        session.dataTask(with: getRequest) { (data, response, error) in
            if let data  = data {
                let meetup = try? JSONDecoder().decode(ListingList.self, from: data)
                print(meetup)
            }
            }.resume()
    }
}
