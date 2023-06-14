//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct FreshnessColor: Codable {
    public let rgb: [Int]

    enum CodingKeys: String, CodingKey {
        case rgb = "RGB"
    }
}

extension FreshnessColor: Equatable {}
