//
//  TransactionRepresentation.swift
//  Finances
//
//  Created by Dmitriy Zharov on 09.10.2023.
//

import Foundation
import CurrencyKit
import SwiftData
import FoundationExtension

struct TransactionRepresentation: ObjectRepresentation, Identifiable {
    typealias Item = Transaction
    
    var id: String = UUID().uuidString
    
    var date: Date = Calendar.autoupdatingCurrent.startOfDay(for: .now)
    var amount: Decimal = .zero.reversed
    var currency: Currency = .current
    var notes: String = ""
    var creationDate: Date = .now

    var payee: String = ""
    var asset: String? = nil
    var category: String? = nil
    var tags: [String] = []
    
    var repetition = Repetition()
}

extension TransactionRepresentation {
    struct Repetition: Hashable {
        enum Frequency: String, CaseIterable {
            case day
            case week
            case month
            case year
        }
        
        var frequency: Frequency?
        var endDate: Date?
    }
}

extension TransactionRepresentation {
    var assetID: UUID? {
        get {
            if let asset{
                return UUID(uuidString: asset)
            } else {
                return nil
            }
        }
        set {
            asset = newValue?.uuidString
        }
    }
    
    var categoryID: UUID? {
        get {
            if let category {
                return UUID(uuidString: category)
            } else {
                return nil
            }
        }
        set {
            category = newValue?.uuidString
        }
    }
}

extension TransactionRepresentation: CompositeIdentifierRepresentable {
    var compositeIdentifierString: String {
        [date.formatted(.iso8601.year().month().day()), amount.formatted(.number.grouping(.never)), currency.identifier].joined(separator: ";")
    }
}

extension TransactionRepresentation {
    func validate() -> Bool {
        !(amount == .zero || amount == .zero.reversed)
    }
}

extension Transaction: ObjectRepresentable {
    var objectRepresentation: TransactionRepresentation {
        get {
            TransactionRepresentation(
                id: externalIdentifier.uuidString,
                date: date,
                amount: amount,
                currency: Currency(currencyCode),
                notes: notes ?? "",
                payee: payee?.name ?? "",
                asset: asset?.externalIdentifier.uuidString,
                category: category?.externalIdentifier.uuidString,
                tags: tags.map { $0.map(\.name) } ?? []
            )
        }
        set(representation) {
            setObjectRepresentation(representation)
        }
    }
    
    func setObjectRepresentation(_ representation: TransactionRepresentation, withRelationshipUpdates relationship: Relationship = .all) {
        guard let modelContext = modelContext else {
            fatalError()
        }
        
        setIdentityString(representation.id)
        date = Calendar.current.startOfDay(for: representation.date, in: .gmt)
        amount = representation.amount
        currencyCode = representation.currency.identifier
        notes = !representation.notes.isEmpty ? representation.notes : nil
        
        if relationship.contains(.payee) {
            if !representation.payee.isEmpty {
                self.payee = Merchant.unique(representation.payee, modelContext: modelContext)
            } else {
                self.payee = nil
            }
        }
        
        if relationship.contains(.asset) {
            if let assetID = representation.assetID {
                self.asset = Asset.retrieve(assetID, modelContext: modelContext)
            } else if self.asset != nil {
                self.asset = nil
            }
        }
        
        if relationship.contains(.category) {
            if let categoryID = representation.categoryID {
                self.category = Category.retrieve(categoryID, modelContext: modelContext)
            } else if self.category != nil {
                self.category = nil
            }
        }
        
        if relationship.contains(.tags) {
            if !representation.tags.isEmpty {
                self.tags = representation.tags.filter { !$0.isEmpty }.map { name in
                    Tag.unique(name, modelContext: modelContext)
                }
            } else if self.tags != nil {
                self.tags = []
            }
        }
        
        if modelContext.autosaveEnabled {
            NotificationCenter.default.post(name: ModelContext.didChange, object: modelContext)
        }
    }
}


extension Decimal {
    var reversed: Decimal {
        Decimal(sign: sign.reversed, exponent: exponent, unsignedSignificand: significand.magnitude)
    }
    
    var _sign: FloatingPointSign {
        get {
            sign
        }
        set {
            if sign != newValue {
                self = Decimal(sign: newValue, exponent: exponent, unsignedSignificand: significand.magnitude)
            }
        }
    }
}

extension Decimal {
    public init(sign: FloatingPointSign, exponent: Int, unsignedSignificand significand: Decimal) {
        self.init(
            _exponent: Int32(exponent) + significand._exponent,
            _length: significand._length,
            _isNegative: sign == .plus ? 0 : 1,
            _isCompact: significand._isCompact,
            _reserved: 0,
            _mantissa: significand._mantissa
        )
    }
}

extension FloatingPointSign {
    var reversed: FloatingPointSign {
        switch self {
        case .plus:
            return .minus
        case .minus:
            return .plus
        }
    }
}

extension CharacterSet {
    func containsUnicodeScalars(of character: Character) -> Bool {
        character.unicodeScalars.allSatisfy(contains(_:))
    }
}
