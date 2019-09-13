//
//  GithubAPIClient.swift
//  MRZ
//
//  Created by Kirill G on 9/12/19.
//  Copyright © 2019 k-ios. All rights reserved.
//

import Foundation


struct GithubAPICleint {
  
  enum NetworkError: Error {
    case badURL
    case noData
  }
  
  private func urlConstractorFrom(_ urlParam: String) -> URL? {
    guard let url = URL(string: "https://api.github.com/search/users?q=\(urlParam)") else { return nil }
    
    return url
  }
  
  public func getProfilesList(withFirstName: String, lastName: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
    let urlParam = "\(withFirstName.lowercased())+\(lastName.lowercased())"
  
    guard let url = urlConstractorFrom(urlParam) else {
      AlertView.create(.alert, title: "Error", message: "Request failed. URL is incorrect.").show()
      return
    }
    
    let urlRequest = URLRequest(url: url)
    let task = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
      guard error == nil else {
        AlertView.create(.alert, title: "Error", message: "Error calling api").show()
        return completion(.failure(.badURL))
      }
      guard let responseData = data else {
        AlertView.create(.alert, title: "Error", message: "Data is nil").show()
        return completion(.failure(.noData))
      }
      completion(.success(responseData))
    }
    task.resume()
  }
}
