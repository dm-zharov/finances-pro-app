//
//  AssetRepresentation.swift
//  Finances
//
//  Created by Dmitriy Zharov on 09.10.2023.
//

import Foundation
import CurrencyKit
import FoundationExtension

struct AssetRepresentation: ObjectRepresentation, Hashable, Identifiable {
    typealias Item = Asset
    
    var id: String = UUID().uuidString
     
    var type: AssetType = .other
    var balance: Decimal = .zero
    var currency: Currency = .current
    
    var name: String = ""
    var institutionName: String = ""
    
    var isHidden: Bool = false
    
    var creationDate: Date = .now
    var lastUpdatedDate: Date = .now
}

extension AssetRepresentation {
    func validate() -> Bool {
        switch type {
        case .cash:
            balance != .zero.reversed
        case .checking, .savings, .brokerage, .other:
            !name.isEmpty && balance != .zero.reversed
        }
    }
}

extension Asset: ObjectRepresentable {
    var objectRepresentation: AssetRepresentation {
        get {
            AssetRepresentation(
                id: externalIdentifier.uuidString,
                type: AssetType(rawValue: type, default: .other),
                balance: balance,
                currency: Currency(currencyCode),
                name: name,
                institutionName: institutionName ?? "",
                isHidden: isHidden,
                creationDate: creationDate,
                lastUpdatedDate: lastUpdatedDate
            )
        }
        set(representation) {
            setIdentityString(representation.id)
            type = representation.type.rawValue
            balance = representation.balance
            currencyCode = representation.currency.identifier
            name = !representation.name.isEmpty ? representation.name : "Unnamed"
            institutionName = !representation.institutionName.isEmpty ? representation.institutionName : nil
            isHidden = representation.isHidden
            creationDate = representation.creationDate
            lastUpdatedDate = representation.lastUpdatedDate
        }
    }
}
