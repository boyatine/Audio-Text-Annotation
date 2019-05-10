//
//  TableViewController.swift
//  Midterm Q2
//
//  Created by Wonsug E on 4/12/19.
//  Copyright © 2019 Wonsug E. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    var items: [Item] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        getItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getItems()
        tableView.reloadData()
    }
    
    func getItems() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let coredatastuff = try? context.fetch(Item.fetchRequest())  as? [Item] {
                items = coredatastuff
                tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.name
        
        if let imageData = item.image {
            cell.imageView?.image = UIImage(data: imageData)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewSegue", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? EditViewController {
            nextVC.previousVC = self
            nextVC.location = sender as! Int
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                let item = items[indexPath.row]
                context.delete(item)
                try? context.save()
                getItems()
            }
        }
        
        
    }
}
