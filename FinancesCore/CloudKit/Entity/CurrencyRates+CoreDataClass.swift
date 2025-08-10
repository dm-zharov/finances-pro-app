//
//  CurrencyRates+CoreDataClass.swift
//  Finances
//
//  Created by Dmitriy Zharov on 10.11.2023.
//
//

import Foundation
import CoreData
import CurrencyKit
import FoundationExtension

@objc(CurrencyRates)
public class CurrencyRates: NSManagedObject { }

extension CurrencyRates {
    @MainActor
    static func dictionaryRepresentation() -> [Date: [CurrencyCode.RawValue: Decimal]] {
        let modelContext = PersistentController.public.newBackgroundContext()
        
        let fetchRequest: NSFetchRequest<CurrencyRates> = CurrencyRates.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.resultType = .dictionaryResultType
        
        guard let fetchResults: [NSDictionary] = try? (modelContext.fetch(fetchRequest) as! [NSDictionary]) else {
            return [:]
        }
        
        var dictionary: [Date: [CurrencyCode.RawValue: Decimal]] = [:]
        for result in fetchResults {
            guard let date = result["date"] as? Date else {
                assertionFailure(); continue
            }
            let values = Dictionary(uniqueKeysWithValues: Currency.supportedCurrencies.map { currency in
                (currency.normalizedIdentifier, Decimal(result[currency.normalizedIdentifier] as! Double))
            })
            dictionary[date] = values
        }
        
        if dictionary.isEmpty, let url = Bundle.main.url(forResource: "CurrencyRates", withExtension: "json") {
            do {
                let jsonData = try Data(contentsOf: url)
                let json = try JSONDecoder().decode(Dictionary<String, [String: Decimal]>.self, from: jsonData)
                
                return Dictionary(
                    uniqueKeysWithValues: json.compactMap({ dateString, rates in
                        if let date = try? Date(dateString, strategy: .iso8601.day().month().year()) {
                            return (date, rates)
                        } else {
                            return nil
                        }
                    })
                )
            } catch {
                return [:]
            }
        } else {
            return dictionary
        }
    }
}
