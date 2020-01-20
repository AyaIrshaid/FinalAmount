//
//  ViewController.swift
//  POSRocketTaskAI
//
//  Created by Aya Irshaid on 1/19/20.
//  Copyright © 2020 Aya Irshaid. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import Network


private typealias Router = ViewController


class ViewController: UIViewController {

    
    let realm = try! Realm()
    
    
    // TODO: replace values with desired URLS
    let discountsURL = "http://www.json-generator.com/api/json/get/bVWmDdjYVu?indent=2"//""
    let extraChargeURL = "http://www.json-generator.com/api/json/get/cfEXUQGNXC?indent=2"//""
    

    // Data
    var discountsArray = [Discount]()
    var extraChargesArray = [ExtraCharge]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check for Internet Connection
        if NetworkReachabilityManager()!.isReachable {
            
            // Connected
            print("Connected, get data from URL--------------------------------------------------\n")
            
            // clear old data
            clearDB()
            
            // Load discounts and extra charges from the provided URLs.
            getDiscounts()
            getExtraCharges()
           
            
        }else{
            // Offline
            print("No connection, try read from database-----------------------------------------\n")
            
            // Try read from local database
            readDiscountsFromLocalDataBase()
            readExtraChargesFromLocalDataBase()
            
            // Apply discounts and extra charges.
            applyDiscounts()
            applyExtraCharge()
        }
        
        
        
    }
    
    // MARK: - Loaders
    func getDiscounts(){
        
        // Load discounts from the provided URL.
        fetchArrayData(API: discountsURL, jsonKeyString: "discounts", arrayDataType: Discount.self, onSuccess: { (dataArray) in
            
            self.discountsArray = (dataArray as! [Discount])
            
            // Apply discounts
            self.applyDiscounts()
            
            // Make the downloaded data available when no internet connection.
            self.saveDiscountsToLocalDataBase()
            
        }) { (message) in
            print("error: \(message)")
        }
    }
    
    func getExtraCharges(){
        
        // Load extra charges from the provided URL.
        fetchArrayData(API: extraChargeURL, jsonKeyString: "extra_charges", arrayDataType: ExtraCharge.self, onSuccess: { (dataArray) in
            
            self.extraChargesArray = (dataArray as! [ExtraCharge])
           
            // Apply extra charges
            self.applyExtraCharge()
            
            // Make the downloaded data available when no internet connection.
            self.saveExtraChargesToLocalDataBase()
            
        }) { (message) in
            print("error: \(message)")
        }
        
    }
    
    
    // MARK: - Handlers
    func applyDiscounts(){
        
        print("-------------------------------Discounts--------------------------------------")
        
        for item in discountsArray {
            
            // Apply discount on a sale with an amount of 10.0 JD.
            let rate = item.rate// Double(item.rate)
            let discount = rate * 10
            let totalValue = 10 - discount
            
            // Print the total amount.
            print("Total Value = \(totalValue), rate = \(rate), discount = \(discount)")
        }
        print("")
    }
    
    func applyExtraCharge(){
        
        print("------------------------------Extra Charge------------------------------------")
        
        for item in extraChargesArray {
            
            // Apply extra charge on a sale with an amount of 10.0 JD.
            let rate = item.rate// Double(item.rate)
            let extraCharge = rate * 10
            let totalValue = 10 + extraCharge
            
            // Print the total amount.
            print("Total Value = \(totalValue), rate = \(rate), extra charge = \(extraCharge)")
        }
        print("")
    }
    
    
    // MARK: - Database
    func saveDiscountsToLocalDataBase(){
        
        try! realm.write {
            
            for item in discountsArray {
                
                realm.add(item)
            }
            
        }
    }
    
    func saveExtraChargesToLocalDataBase(){
        
       try! realm.write {
            
            for item in extraChargesArray {

                realm.add(item)
            }
            
        }
    }
    
    func readDiscountsFromLocalDataBase(){

        var dataArray = [Discount]()
        let resultArray = realm.objects(Discount.self)
        for item in resultArray {
            dataArray.append(item)
        }
        
        discountsArray = dataArray
        
        if discountsArray.count == 0 {
            print("No data in database-----------------------------------------------------------\n")
        }
    }
    
    func readExtraChargesFromLocalDataBase(){

        var dataArray = [ExtraCharge]()
        let resultArray = realm.objects(ExtraCharge.self)
        for item in resultArray {
            dataArray.append(item)
        }
        
        extraChargesArray = dataArray
    }
    
    func clearDB(){
        
        try! realm.write {
          realm.deleteAll()
        }
    }

}


extension Router {
    
    func fetchArrayData <T : Codable> (API: String, jsonKeyString: String, arrayDataType: T.Type, onSuccess success: @escaping (_ returnedDataArray: [Any]) -> Void, onFailure failure: @escaping (_ message: String) -> Void) {
        
        // Data
        var mutatingReturnedDataArray = [Any]()
        
        // Request
        Alamofire.request(API, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON{ response in
            
            // Getting json
            if let json = response.result.value as? NSDictionary {
                
                // Get array from JSON
                if let dataArray : NSArray = json[jsonKeyString] as? NSArray {
                    
                    // Get items from the array
                    for item  in dataArray {
                        
                        do {
                            // Serialize JSON to data
                            let jsonData = try JSONSerialization.data(withJSONObject: item)
                            
                            do {
                                // Decode data to Codable object
                                let decoder = JSONDecoder()
                                let itemData = try decoder.decode(arrayDataType, from: jsonData)
                               
                                // Append itme to returned array
                                mutatingReturnedDataArray.append(itemData)
                                
                            }catch {
                                // Decoding error
                                print(error)
                                failure(error.localizedDescription)
                            }
                            
                        }catch {
                            // Serialization error
                            print(error)
                            failure(error.localizedDescription)
                        }
                        
                    }
                    
                    // Returned array
                    success(mutatingReturnedDataArray)
                    
                }
            }
        }
    }


    

}
