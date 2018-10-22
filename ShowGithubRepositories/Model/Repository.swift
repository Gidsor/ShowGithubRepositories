//
//  Repository.swift
//  ShowGithubRepositories
//
//  Created by Vadim Denisov on 22/10/2018.
//  Copyright © 2018 Vadim Denisov. All rights reserved.
//

import SwiftyJSON

class Repository {
    var id: Int!
    var name: String!
    var login: String!
    var description: String!
    var url: String!
    
    init(json: JSON) {
        
        if let id = json["id"].int {
            self.id = id
        }
        
        if let name = json["name"].string {
            self.name = name
        }
        
        if let login = json["owner"]["login"].string {
            self.login = login
        }
        
        if let description = json["description"].string {
            self.description = description
        } else {
            self.description = ""
        }
        
        if let url = json["html_url"].string {
            self.url = url
        }
        
    }
}

