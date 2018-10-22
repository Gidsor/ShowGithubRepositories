//
//  Owner.swift
//  ShowGithubRepositories
//
//  Created by Vadim Denisov on 22/10/2018.
//  Copyright © 2018 Vadim Denisov. All rights reserved.
//

import ObjectMapper

class Owner: Mappable {
    var id: Int!
    var login: String!
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        id <- map["id"]
        login <- map["login"]
    }
}
