//
//  Guide.swift
//  Accountant
//
//  Created by Roman Topchii on 13.11.2021.
//

import Foundation
import UIKit

struct Guide {
    let title: String
    let image: String?
    let body: String?
    let items: [GuideItem]
    init(title: String, image: String?, body: String?, items: [GuideItem]) {
        self.title = title
        self.image = image
        self.body = body
        self.items = items
    }
}

struct GuideItem {
    let image: String?
    let emoji: String?
    let backgroungColor: UIColor?
    let tintColor: UIColor?
    let text: String

    init(image: String, backgroungColor: UIColor, text: String) {
        self.image = image
        self.emoji = nil
        self.tintColor = nil
        self.backgroungColor = backgroungColor
        self.text = text
    }

    init(image: String, backgroungColor: UIColor, tintColor: UIColor, text: String) {
        self.image = image
        self.emoji = nil
        self.tintColor = tintColor
        self.backgroungColor = backgroungColor
        self.text = text
    }

    init(emoji: String, backgroungColor: UIColor, text: String) {
        self.image = nil
        self.emoji = emoji
        self.backgroungColor = backgroungColor
        self.tintColor = nil
        self.text = text
    }

    init(image: String, text: String) {
        self.image = image
        self.emoji = nil
        self.backgroungColor = nil
        self.tintColor = nil
        self.text = text
    }

    init(image: String, tintColor: UIColor, text: String) {
        self.image = image
        self.emoji = nil
        self.backgroungColor = nil
        self.tintColor = tintColor
        self.text = text
    }

    init(emoji: String, text: String) {
        self.emoji = emoji
        self.image = nil
        self.backgroungColor = nil
        self.tintColor = nil
        self.text = text
    }
    
    init(text: String) {
        self.backgroungColor = nil
        self.emoji = nil
        self.image = nil
        self.tintColor = nil
        self.text = text
    }
}
