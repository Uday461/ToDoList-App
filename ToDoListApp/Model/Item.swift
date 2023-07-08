//
//  Item.swift
//  ToDoListApp
//
//  Created by UdayKiran Naik on 05/07/23.
//

import Foundation
class Item: Encodable, Decodable{
    var title: String = ""
    var done: Bool = false
}
