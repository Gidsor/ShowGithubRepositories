//
//  Repository.swift
//  ShowGithubRepositories
//
//  Created by Vadim Denisov on 22/10/2018.
//  Copyright © 2018 Vadim Denisov. All rights reserved.
//

import ObjectMapper

class Repository: Mappable {
    var id: Int!
    var name: String!
    var description: String!
    var url: String!
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        description <- map["description"]
        url <- map["html_url"]
    }
}


