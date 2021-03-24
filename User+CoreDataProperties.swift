//
//  User+CoreDataProperties.swift
//  LoginValidationTest
//
//  Created by Vignesh Krishnamurthy on 24/03/21.
//  Copyright © 2021 vignesh. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var username: String?
    @NSManaged public var userID: Int32
    @NSManaged public var created_date: Date?

}
