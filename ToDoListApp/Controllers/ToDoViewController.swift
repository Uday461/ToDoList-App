//
//  ViewController.swift
//  ToDoListApp
//
//  Created by UdayKiran Naik on 04/07/23.
//

import UIKit
import RealmSwift

class ToDoViewController: SwipeTableViewController {
    
    var todoItems:Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 65.0
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.color {
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
            navBar.backgroundColor = UIColor(hexString: colorHex)
            title = selectedCategory!.name
            let textAttributes = [NSAttributedString.Key.foregroundColor:            UIColor(contrastingBlackOrWhiteColorOn: UIColor(hexString: colorHex)!, isFlat: true)]
            navBar.titleTextAttributes = textAttributes
        }
    }
    
    //MARK: - TableView DataSource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.name
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count))
            {
                cell.backgroundColor = color
                cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)
            }
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added."
        }
        return cell
    }
    
    //MARK: - TableView Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write{
                    item.done = !item.done
                }
            } catch{
                print("Error in updating the status done: \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - AddButtonPressed Methods
    //
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Todo Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            if let text = textField.text{
                if self.selectedCategory != nil{
                    do{
                        try self.realm.write{
                            let newItem = Item()
                            newItem.name = text
                            newItem.date = Date()
                            self.selectedCategory?.items.append(newItem)
                        }
                    } catch {
                        print("Error in adding item: \(error)")
                    }
                }
                self.tableView.reloadData()
            }
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Saving and Reloading data into Relam Database
    
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "name", ascending: true)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Update Delete in SwipeViewCellDelegate method
    
    override func update(indexPath: IndexPath) {
        if let itemForDeletion = self.todoItems?[indexPath.row] {
            do{
                try self.realm.write{
                    self.realm.delete(itemForDeletion)
                }
            } catch{
                print("Error in deleting todoItems: \(error)")
            }
        }
    }
}

//MARK: - SearchBar Methods

extension ToDoViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "date",ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

//MARK: - For saving data in plist.

//func saveData(){
//    let encoder = PropertyListEncoder()
//    do {
//        let data = try encoder.encode(itemArray)
//        if let dataFilePath = dataFilePath {
//            try data.write(to: dataFilePath)
//        }
//    } catch {
//        print("Error in data encoding: \(error)")
//    }
//
//    DispatchQueue.main.async {
//        self.tableView.reloadData()
//    }
//}


//    func loadItems(){
//        if let dataFilePath = dataFilePath {
//           if let data = try? Data(contentsOf: dataFilePath){
//                let decoder = PropertyListDecoder()
//               do {
//                   itemArray = try decoder.decode([Item].self, from: data)
//               } catch {
//                   print("Error in decoding data \(error)")
//               }
//            }
//
//        }
//    }
