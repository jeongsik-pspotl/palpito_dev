//
//  ResultRelax+CoreDataProperties.swift
//  Palpito
//
//  Created by 김정식 on 30/05/2019.
//  Copyright © 2019 김정식. All rights reserved.
//
//

import Foundation
import CoreData


extension ResultRelax {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ResultRelax> {
        return NSFetchRequest<ResultRelax>(entityName: "ResultRelax")
    }

    @NSManaged public var avgHeartRate: String?
    @NSManaged public var todayDate: String?
    @NSManaged public var todayRelaxCount: Int16
    @NSManaged public var totalRelaxTime: String?
    @NSManaged public var relaxType: String?

}
