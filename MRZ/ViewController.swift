//
//  ViewController.swift
//  MRZ
//
//  Created by Kirill G on 9/12/19.
//  Copyright © 2019 k-ios. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var mrzInputField: UITextField!
  @IBOutlet weak var searchButton: UIButton!
  @IBOutlet weak var firstLastNameLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
  var profiles = [Profile]() {
    didSet {
      if profiles.count > 1 {
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    tableView.delegate = self
    
    view.accessibilityIdentifier = "searchView"
  }
  
  
  @IBAction func searhByMRZ(_ sender: Any) {
    guard let passportCode = mrzInputField.text else { return }
    
    if passportCode.isEmpty || passportCode == "" {
      AlertView.create(.alert, title: "Error", message: "Please enter barcode").show()
      return
    }
    
    if isContyCodeIncluded(passportCode) && isPassportFormatt(passportCode) {
      DispatchQueue.main.async {
        self.firstLastNameLabel.text = self.getPersonID(passportCode) ?? "Incorrect barcode"
      }
    } else {
      AlertView.create(.alert, title: "Error", message: "Barcode invalid. Please try again.").show()
      return
    }
    
  }
  
  func isContyCodeIncluded(_ barCode: String) -> Bool {
    // Assuming that Code will be at the same location all the time, check prefix
    return barCode.prefix(6).contains("USA")
  }
  
  func isPassportFormatt(_ barCode: String) -> Bool {
    // P, indicating passport. So if we have something else just return false to stop process.
    return (barCode.first { $0.uppercased() == "P"} != nil)
  }
  
  private func names(from string: String) -> (primary: String, secondary: String) {
    let identifiers = string.trimmingCharacters(in: CharacterSet(charactersIn: "<")).components(separatedBy: "<<").map({$0.replacingOccurrences(of: "<", with: " ")})
    let secondaryID = identifiers.indices.contains(1) ? identifiers[1] : ""
    
    return (primary: identifiers[0], secondary: secondaryID)
  }
  
  func getPersonID(_ barCode: String) -> String? {
    var firstName = ""
    var lastName = ""
    
    if let rangeTwo = barCode.range(of: "<<") {
      guard let firstNameUpperBound = barCode.range(of: "<<<<")?.upperBound else { return nil }
      guard let countryCodeUpperBound = barCode.range(of: "USA")?.upperBound else { return nil }
      
      // Get first and last name using substring
      firstName = String(barCode[rangeTwo.upperBound..<firstNameUpperBound].dropLast(4))
      lastName = String(barCode[countryCodeUpperBound..<rangeTwo.upperBound].dropLast(2))
    }
  
    
    let extractedName = names(from: barCode)
    firstName = extractedName.secondary
    
    // Search profiles with first and last name in git
    GithubAPICleint().getProfilesList(withFirstName: firstName, lastName: lastName) { result in
      self.profiles.removeAll()
      switch result {
      case .success(let data):
          do {
            let res = try JSONDecoder().decode(GithubProfileModel.self, from: data)
            self.profiles.append(contentsOf: res.items)
          } catch {
            print(error)
          }
      case .failure(let error):
        AlertView.create(.alert, title: "Error", message: error.localizedDescription).show()
      }
    }
    
    return String("\(firstName) \(lastName)")
  }
  
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return profiles.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "profile_cell")
    
    cell?.textLabel?.text = "Login: \(profiles[indexPath.row].login)"
    cell?.detailTextLabel?.text = "ID: \(String(profiles[indexPath.row].id)) | Type: \(profiles[indexPath.row].type)"
    
    return cell!
  }
}

