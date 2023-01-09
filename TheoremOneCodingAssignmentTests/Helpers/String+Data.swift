//
//  Bundle+Data.swift
//  TheoremOneCodingAssignmentTests
//
//  Created by Maksym Bondar on 09.01.2023.
//

import Foundation

extension String {
    func data(with type: String = "json") -> Data? {
        let bundle = Bundle(for: MockURLProtocol.self)
        guard let path = bundle.path(forResource: self, ofType: type) else {
            return nil
        }
        return try? Data(contentsOf: URL(filePath: path), options: .mappedIfSafe)
    }
}
