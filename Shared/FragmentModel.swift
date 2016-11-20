//
//  FragmentModel.swift
//  drag
//
//  Created by Robert Carlsen on 11/20/16.
//  Copyright © 2016 Robert Carlsen. All rights reserved.
//

import UIKit

class FragmentModel: NSObject {
    let identifier: String
    let imageUrl: String

    var text: String?
    var matches: [MatchModel]?

    init(id:String, url: String) {
        identifier = id
        imageUrl = url
        super.init()
    }
}

class MatchModel: NSObject {
    let identifier: String
    let edge: String

    var baseId: String?
    var targetId: String?
    
    var confidence: Float?
    var votes: Int?

    init(id: String, edge _edge: String) {
        identifier = id
        edge = _edge
        super.init()
    }
}
