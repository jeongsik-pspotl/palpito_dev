//
//  ResultWorkOut+CoreDataProperties.swift
//  Palpito
//
//  Created by 김정식 on 10/04/2019.
//  Copyright © 2019 김정식. All rights reserved.
//
//

import Foundation
import CoreData


extension ResultWorkOut {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ResultWorkOut> {
        return NSFetchRequest<ResultWorkOut>(entityName: "ResultWorkOut")
    }

    @NSManaged public var avgHeartRate: String?
    @NSManaged public var avgSpeedHour: String?
    @NSManaged public var todayDate: String?
    @NSManaged public var todayWorkOutCount: Int16
    @NSManaged public var totalcalBurn: String?
    @NSManaged public var totalScore: String?
    @NSManaged public var totalWorkOutTime: String?

}
