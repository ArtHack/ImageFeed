//
//  Array+Extension.swift
//  ImageFeed
//
//  Created by arthack on 12.04.2023.
//

import Foundation

extension Array {
    func withReplaced(itemAt: Int, newValue: Photo) -> [Photo] {
        var photos = ImagesListService.shared.photos
        photos.replaceSubrange(itemAt...itemAt, with: [newValue])
        return photos
    }
}
