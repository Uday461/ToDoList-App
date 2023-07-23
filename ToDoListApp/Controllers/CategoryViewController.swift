//
//  CategoryViewController.swift
//  ToDoListApp
//
//  Created by UdayKiran Naik on 06/07/23.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    var categories:Results<Category>?
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let realm = try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        tableView.rowHeight = 65.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        navBar.backgroundColor = .white
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let cellText = categories?[indexPath.row].name{
            cell.textLabel?.text = cellText
            cell.backgroundColor = UIColor(hexString: categories![indexPath.row].color )
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: cell.backgroundColor!, isFlat: true)

        } else{
            cell.textLabel?.text = "No items added yet."
        }
        return cell
    }

    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoViewController
        if let indexPath = tableView.indexPathForSelectedRow {
        destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }

    //MARK: - Add Button Pressed Manipulation Methods

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            if let text = textField.text{
                let newCategory = Category()
                newCategory.name = text
                newCategory.color = UIColor(randomFlatColorOf:.light).hexValue()
                self.saveData(category: newCategory)
            }
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveData(category: Category){
        do{
            try realm.write {
                realm.add(category)
            }
        } catch{
            print("Error in saving the category data into Realm: \(error)")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func loadCategory(){
            categories = realm.objects(Category.self)
            tableView.reloadData()
    }
    
    //MARK: - Update Delete in SwipeViewCellDelegate method
    
    override func update(indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do{
                try self.realm.write{
                    self.realm.delete(categoryForDeletion)
                }
            } catch{
                print("Error in deleting categories: \(error)")
            }
        }
    }

}
