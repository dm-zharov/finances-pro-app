//
//  TransactionQuery.swift
//  Finances
//
//  Created by Dmitriy Zharov on 18.04.2024.
//

import Foundation
import SwiftData
import FoundationExtension

struct TransactionQuery: Hashable, Codable {
    var sortBy: [SortDescriptor<Transaction>] = .defaultValue
    var groupBy: Transaction.GroupBy = .defaultValue
    
    /// An asset to use when filtering transactions.
    var searchAssetID: Asset.ExternalID? = nil
    
    /// A category to use when filtering transactions.
    var searchCategoryID: Category.ExternalID? = nil
    
    /// A payee to use when filtering transactions.
    var searchMerchantID: Merchant.ExternalID? = nil
    
    /// A text to use when filtering transactions.
    var searchText: String = ""
    
    /// The range of dates to use when filtering transactions.
    ///
    /// The list display only the transactions that occur between
    /// the start and end of the day in the current time zone.
    var searchDateInterval: DateInterval?
}

extension TransactionQuery {
    func dateInterval(_ dateInterval: DateInterval) -> TransactionQuery {
        var query = self
        query.searchDateInterval = dateInterval
        return query
    }
}

extension TransactionQuery: DefaultValueProvidable {
    static let defaultValue = TransactionQuery()
}

extension TransactionQuery {
    var fetchDescriptor: FetchDescriptor<Transaction> {
        let predicate = TransactionQuery.predicate(
            searchText: searchText,
            searchDateInterval: searchDateInterval,
            searchAssetID: searchAssetID,
            searchCategoryID: searchCategoryID,
            searchMerchantID: searchMerchantID
        )
        return Transaction.prefetchDescriptor(predicate: predicate, sortBy: sortBy)
    }
}

extension TransactionQuery {
    /// A filter that checks for a date and text.
    static func predicate(
        searchText: String = "",
        searchDateInterval: DateInterval? = nil,
        searchAssetID: Asset.ExternalID? = nil,
        searchCategoryID: Category.ExternalID? = nil,
        searchCategoryGroupID: CategoryGroup.ExternalID? = nil,
        searchMerchantID: Merchant.ExternalID? = nil
    ) -> Predicate<Transaction> {
        let searchDateInterval = searchDateInterval ?? DateInterval(start: .distantPast, end: .distantFuture)
        
        let start = searchDateInterval.start
        let end = searchDateInterval.end

        if !searchText.isEmpty {
            if let searchAmount = Decimal(string: searchText, locale: .current) {
                let lowerBound = searchAmount
                let upperBound = searchAmount + 1
                return #Predicate<Transaction> { transaction in
                    return transaction.amount >= lowerBound && transaction.amount < upperBound
                }
            } else {
                return #Predicate<Transaction> { transaction in
                    return transaction.payee?.name.starts(with: searchText) == true
                        || transaction.category?.name.starts(with: searchText) == true
                }
            }
        } else if let searchAssetID {
            return #Predicate<Transaction> { transaction in
                if let asset = transaction.asset {
                    return asset.externalIdentifier == searchAssetID && (transaction.date >= start && transaction.date < end)
                } else {
                    return false
                }
            }
        } else if let searchCategoryID {
            return #Predicate<Transaction> { transaction in
                if let category = transaction.category {
                    return category.externalIdentifier == searchCategoryID && (transaction.date >= start && transaction.date < end)
                } else {
                    return false
                }
            }
        } else if let searchMerchantID {
            return #Predicate<Transaction> { transaction in
                if let payee = transaction.payee {
                    return payee.name == searchMerchantID && (transaction.date >= start && transaction.date < end)
                } else {
                    return false
                }
            }
        } else if let searchCategoryGroupID {
            return #Predicate<Transaction> { transaction in
                if let category = transaction.category, let categoryGroup = category.group {
                    return categoryGroup.externalIdentifier == searchCategoryGroupID && (transaction.date >= start && transaction.date < end)
                } else {
                    return false
                }
            }
        } else {
            return #Predicate<Transaction> { transaction in
                (transaction.date >= start && transaction.date < end)
            }
        }
    }
    
    static func predicate(
        dateInterval: DateInterval,
        isIncome: Bool? = nil,
        includeTransient: Bool = false
    ) -> Predicate<Transaction> {
        switch isIncome {
        case let .some(isIncome):
            if includeTransient {
                return #Predicate<Transaction> { transaction in
                    if let category = transaction.category {
                        return (transaction.date >= dateInterval.start && transaction.date < dateInterval.end) && category.isIncome == isIncome
                    } else {
                        return (transaction.date >= dateInterval.start && transaction.date < dateInterval.end)
                    }
                }
            } else {
                return #Predicate<Transaction> { transaction in
                    if let category = transaction.category {
                        return (transaction.date >= dateInterval.start && transaction.date < dateInterval.end)
                            && category.isIncome == isIncome
                            && category.isTransient == false
                    } else {
                        return (transaction.date >= dateInterval.start && transaction.date < dateInterval.end)
                    }
                }
            }
        case .none:
            if includeTransient {
                return #Predicate<Transaction> { transaction in
                    (transaction.date >= dateInterval.start && transaction.date < dateInterval.end)
                }
            } else {
                return #Predicate<Transaction> { transaction in
                    if let category = transaction.category {
                        return (transaction.date >= dateInterval.start && transaction.date < dateInterval.end)
                            && category.isTransient == false
                    } else {
                        return (transaction.date >= dateInterval.start && transaction.date < dateInterval.end)
                    }
                }
            }
        }
    }
    
    static func predicate(searchPayee: String) -> Predicate<Transaction> {
        return #Predicate<Transaction> { transaction in
            if let merchant = transaction.payee {
                return merchant.name.starts(with: searchPayee)
            } else {
                return false
            }
        }
    }
}
