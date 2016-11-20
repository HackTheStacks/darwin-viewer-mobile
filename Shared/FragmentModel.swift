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

    func matchWithHashValue(hashString:String) -> MatchModel? {
        guard let matches = self.matches, matches.count > 0 else { return nil }
        let results = matches.filter({match -> Bool in
            print(match.hashValue)
            return String(match.hashValue) == hashString})
        return results.first
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
