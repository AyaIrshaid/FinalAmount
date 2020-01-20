//
//  ExtraCharge.swift
//  POSRocketTaskAI
//
//  Created by Aya Irshaid on 1/19/20.
//  Copyright © 2020 Aya Irshaid. All rights reserved.
//

import UIKit
import RealmSwift

class ExtraCharge: Object, Codable {
    
    @objc dynamic var name = ""
    @objc dynamic var rate = 0.0

}
