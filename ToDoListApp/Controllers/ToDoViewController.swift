//
//  ViewController.swift
//  ToDoListApp
//
//  Created by UdayKiran Naik on 04/07/23.
//

import UIKit
import CoreData

class ToDoViewController: UITableViewController {

    var itemArray = [Item]()
    var selectedCategory: CategoryList? {
        didSet{
            loadItems()
        }
    }
 //  let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
        
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
 //       print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
//        print(dataFilePath!)
        loadItems()
    }
    
    //MARK: - TableView DataSource methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .default, reuseIdentifier: "TodoCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        if (itemArray[indexPath.row].done == true){
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    //MARK: - TableView Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
 //       context.delete(itemArray[indexPath.row]) //method for deleting data in core data.
 //       itemArray.remove(at: indexPath.row)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
            saveData()
            tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - AddButtonPressed Methods
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Todo Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            if let text = textField.text{
                let newItem = Item(context: self.context)
                newItem.title = text
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                self.itemArray.append(newItem)
                self.saveData()
            }
         }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
  
    //MARK: - Saving and Reloading data into CoreData

    func saveData(){
        do {
             try context.save()
        } catch {
            print("Error in context saving: \(error)")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), withPredicate predicate: NSPredicate? = nil){
      //      let request: NSFetchRequest<Item> = Item.fetchRequest()
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = predicate{
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate, categoryPredicate])
            request.predicate = compoundPredicate
        } else{
            request.predicate = categoryPredicate
        }
          do{
              itemArray = try context.fetch(request)
            } catch{
                print("Error loading items: \(error)")
            }
            
        }


}

//MARK: - SearchBar Methods

extension ToDoViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        if let searchBarText = searchBar.text {
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBarText)
            request.predicate = predicate
        }
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        loadItems(with: request, withPredicate: request.predicate)
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
