//
//  Genre.swift
//  MovieTestTech
//
//  Created by Christophorus Davin on 12/10/22.
//

import Foundation
// MARK: - Welcome
struct GenreResult: Codable {
    let genres: [Genre]
}

// MARK: - Genre
struct Genre: Codable {
    let id: Int
    let name: String
}
