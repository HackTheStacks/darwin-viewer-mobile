//
//  DarwinApiManager.swift
//  drag
//
//  Created by Robert Carlsen on 11/19/16.
//  Copyright © 2016 Robert Carlsen. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

import Alamofire
import AlamofireImage

class DarwinApiManager: NSObject {
    static let baseURL = "http://localhost:3000"

    static func fragments(callback:@escaping ([FragmentModel]?, Bool)->Void) {

        Alamofire.request("\(baseURL)/api/fragments").responseJSON { response in
            if let JSON = response.result.value {
                print("JSON: \(JSON)")

                guard let entities = JSON as? NSArray else {
                    callback(nil, false)
                    return
                }

                let fragments = entities.map { entity -> FragmentModel? in
                    guard let dict = entity as? NSDictionary else { return nil }
                    let identifier = String(dict["id"] as! Int)
                    let filename = dict["filename"] as! String
                    let fragment = FragmentModel(id: identifier, url: filename)

                    if let matches = dict["matches"] as? [NSDictionary] {
                        fragment.matches = matches.map { match -> MatchModel in
                            let identifier = String(match["id"] as! Int)
                            let edgeId = match["edge"] as? String ?? "unknown"
                            let matchModel = MatchModel(id: identifier, edge: edgeId)

                            matchModel.targetId = String(describing: match["targetId"])
                            matchModel.baseId = String(describing: match["baseId"])
                            
                            return matchModel
                        }
                    }
                    return fragment
                }.flatMap { $0 }
                callback(fragments, true)

            } else {
                callback(nil, false)
            }
        }
    }

    static func fragment(identifier:String, callback:@escaping (FragmentModel?, Bool)->Void) {
        Alamofire.request("\(baseURL)/api/fragments/\(identifier)").responseJSON { response in
            if let JSON = response.result.value {
                print("JSON: \(JSON)")

                guard let entity = JSON as? NSDictionary else {
                    callback(nil, false)
                    return
                }

                let identifier = String(entity["id"] as! Int)
                let filename = entity["filename"] as! String

                let fragment = FragmentModel(id: identifier, url: filename)

                let matches = entity["matches"] as! [NSDictionary]
                fragment.matches = matches.map { match -> MatchModel in
                    let identifier = String(match["id"] as! Int)
                    let edgeId = match["edge"] as? String ?? "unknown"
                    let matchModel = MatchModel(id: identifier, edge: edgeId)

                    matchModel.targetId = String(describing: match["targetId"])
                    matchModel.baseId = String(describing: match["baseId"])

                    return matchModel
                }
                callback(fragment, true)

            } else {
                callback(nil, false)
            }
        }
    }

    static func fragmentImage(identifier:String, callback:@escaping(UIImage?, Bool)->Void) {
        Alamofire.request("\(baseURL)/api/fragments/\(identifier)/image").responseImage { response in
            if let image = response.result.value {
                callback(image, true)
            } else {
                callback(nil, false)
            }
        }
    }
}
