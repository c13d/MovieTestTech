//
//  Service.swift
//  MovieTestTech
//
//  Created by Christophorus Davin on 11/10/22.
//

import Foundation

struct ReviewServiceResponse {
    let maxPage: Int
    let datas: [Review]?
}

struct MovieServiceResponse {
    let maxPage: Int
    let datas: [Movie]?
}

struct SearchServiceResponse {
    let maxPage: Int
    let datas: [Search]?
}
