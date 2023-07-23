//
//  Category.swift
//  ToDoListApp
//
//  Created by UdayKiran Naik on 09/07/23.
//

import Foundation
import RealmSwift
class Category: Object{
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    var items = List<Item>()
}
