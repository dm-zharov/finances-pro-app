//
//  LMAsset.swift
//  Finances
//
//  Created by Dmitriy Zharov on 27.09.2023.
//

import Foundation
import FoundationExtension

struct LMAsset: Decodable, Identifiable, Hashable {
    /// Unique identifier for asset
    let id: UInt64
    /// Primary type of the asset
    let typeName: TypeName?
    /// Optional asset subtype
    let subtypeName: SubtypeName?
    /// Name of the asset
    let name: String
    /// Display name of the asset (as set by user)
    let displayName: String?
    /// Current balance of the asset in numeric format to 4 decimal places
    @StringRepresentation<Double>
    var balance: String
    /// Date/time the balance was last updated in ISO 8601 extended format
    @StringRepresentation<Date>
    var balanceAsOf: String
    /// The date this asset was closed
    let closedOn: String?
    /// Three-letter lowercase currency code of the balance in ISO 4217 format
    let currency: String
    /// Name of institution holding the asset
    let institutionName: String?
    /// If true, this asset will not show up as an option for assignment when creating transactions manually
    let excludeTransactions: Bool
    /// Date/time the asset was created in ISO 8601 extended format
    @StringRepresentation<Date>
    var createdAt: String
}

extension LMAsset {
    enum TypeName: String, CaseIterable, Decodable, DefaultValueProvidable {
        case cash
        case credit
        case cryptocurrency
        case investment
        case loan
        case realEstate = "real estate"
        case vehicle
        case employeeCompensation = "employee compensation"
        case otherLiability = "other liability"
        case otherAsset = "other asset"
        
        static let defaultValue: LMAsset.TypeName = .otherAsset
    }
    
    enum SubtypeName: String, CaseIterable, Decodable, DefaultValueProvidable {
        case checking
        case savings
        case digitalWallet = "digital wallet (paypal, venmo)"
        case physicalCash = "physical cash"
        case brokerage
        
        case automobile
        case motorcycle
        case boat
        case snowmobile
        case scooter
        
        case other
        
        static let defaultValue: LMAsset.SubtypeName = .other
    }
}

extension LMAsset {
    var assetType: AssetType? {
        switch typeName {
        case .cash:
            switch subtypeName {
            case .physicalCash:
                return .cash
            case .checking, .digitalWallet:
                return .checking
            case .savings:
                return .savings
            default:
                return .other
            }
        default:
            return .other
        }
    }
}
