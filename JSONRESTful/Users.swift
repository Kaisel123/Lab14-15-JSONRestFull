//
//  Users.swift
//  JSONRESTful
//
//  Created by David Alejo on 6/20/21.
//  Copyright © 2021 David Alejo. All rights reserved.
//

import Foundation
struct Users:Decodable {
    var id:Int
    var nombre:String
    var clave:String
    var email:String
}
