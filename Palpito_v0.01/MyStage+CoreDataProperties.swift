//
//  MyStage+CoreDataProperties.swift
//  Palpito
//
//  Created by 김정식 on 07/02/2019.
//  Copyright © 2019 김정식. All rights reserved.
//
//

import Foundation
import CoreData


extension MyStage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyStage> {
        return NSFetchRequest<MyStage>(entityName: "MyStage")
    }

    @NSManaged public var stage: String?

}
