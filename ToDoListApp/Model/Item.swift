//
//  Item.swift
//  ToDoListApp
//
//  Created by UdayKiran Naik on 09/07/23.
//

import Foundation
import RealmSwift

class Item: Object{
    @objc dynamic var name: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var date: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
