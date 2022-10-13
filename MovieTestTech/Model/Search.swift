//
//  Search.swift
//  MovieTestTech
//
//  Created by Christophorus Davin on 11/10/22.
//

import Foundation

// MARK: - Welcome
struct SearchResult: Codable {
    let page: Int
    let results: [Search]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// MARK: - Result
struct Search: Codable {
    let id: Int
    let logoPath: String?
    let name, originCountry: String

    enum CodingKeys: String, CodingKey {
        case id
        case logoPath = "logo_path"
        case name
        case originCountry = "origin_country"
    }
}

