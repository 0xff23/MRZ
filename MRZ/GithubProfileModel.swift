//
//  GithubProfileModel.swift
//  MRZ
//
//  Created by Kirill G on 9/12/19.
//  Copyright © 2019 k-ios. All rights reserved.
//

import Foundation


struct GithubProfileModel: Codable {
  var total_count: Int
  var incomplete_results: Bool
  var items: [Profile]
}

struct Profile: Codable {
  var login: String
  var id: Int
  var node_id: String
  var type: String
}
