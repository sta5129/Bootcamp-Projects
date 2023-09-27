//
//  CategoryViewControllerTableViewController.swift
//  Todoey
//
//  Created by Samarah Anderson on 7/8/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import ChameleonFramework
import RealmSwift

class CategoryViewControllerTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
        
    override func viewDidLoad() {
        super.viewDidLoad()
            
        loadCategories()

        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Naviagtion Controller does not exist.")
        }
        
        navBar.backgroundColor = UIColor(hexString: "1D9BF6")
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet"

        if let category = categories?[indexPath.row] {
            guard let categoryColor = UIColor(hexString: category.color) else {fatalError()}
            
            cell.backgroundColor = categoryColor
            
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
                
        return cell
    }

    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TodoListViewController
        
        //index path that identifies the current row selected
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - Delete data from swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
         if let categoryForDeletion = self.categories?[indexPath.row] {
             do {
                 try self.realm.write {
                     self.realm.delete(categoryForDeletion)
                 }
             } catch {
                 print("Error deleting category \(error)")
             }
         } 
    }
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) {
            action in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            
            self.save(category: newCategory)
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
    //MARK: - Data Manipulation Methods
    //CRUD: Create
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("error saving context \(error)")
        }
        
        tableView.reloadData()
    }
        //CRUD: Read
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
}


