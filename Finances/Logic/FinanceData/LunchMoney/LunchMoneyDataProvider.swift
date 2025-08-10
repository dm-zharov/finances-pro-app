//
//  LunchMoneyDataProvider.swift
//  Finances
//
//  Created by Dmitriy Zharov on 09.10.2023.
//

import Foundation
import Combine
import CoreTransferable
import CurrencyKit

enum LunchMoneyError: Error {
    case wrongToken
    case notAuthorized
}

class LunchMoneyDataProvider: ThirdPartyDataProvider {
    private var apiService: APIService?
    private var cancellables: Set<AnyCancellable> = []
    
    var providerName: String {
        "lunchmoney.app"
    }
    
    func authorize(with accessToken: String) async throws {
        guard !accessToken.isEmpty else {
            throw LunchMoneyError.wrongToken
        }
        do {
            let apiService = APIService(token: accessToken)
            _ = try await loadUser(apiService)
            self.apiService = apiService
        } catch {
            throw LunchMoneyError.wrongToken
        }
    }

    func loadAssets() async throws -> [AssetRepresentation] {
        guard let apiService else {
            throw LunchMoneyError.notAuthorized
        }
        return try await withCheckedThrowingContinuation { continuation in
            apiService.getAssets()
                .sink { completion in
                    if case .failure(_) = completion {
                        continuation.resume(throwing: ThirdPartyDataProviderError.undefined)
                    }
                } receiveValue: { response in
                    let representations: [AssetRepresentation] = response.assets.map { importingAsset in
                        return AssetRepresentation(
                            id: String(importingAsset.id),
                            type: importingAsset.assetType ?? .other,
                            balance: Decimal(Double(importingAsset.balance) ?? .zero),
                            currency: Currency(importingAsset.currency),
                            name: importingAsset.displayName ?? importingAsset.name,
                            institutionName: importingAsset.institutionName ?? .empty,
                            isHidden: importingAsset.closedOn != nil,
                            creationDate: importingAsset.$createdAt!,
                            lastUpdatedDate: importingAsset.$balanceAsOf!
                        )
                    }
                    continuation.resume(with: .success(representations))
                }
                .store(in: &cancellables)
        }
    }
    
    func loadCategories() async throws -> [CategoryRepresentation] {
        guard let apiService else {
            throw LunchMoneyError.notAuthorized
        }
        return try await withCheckedThrowingContinuation { continuation in
            apiService.getCategories()
                .sink { completion in
                    if case .failure(_) = completion {
                        continuation.resume(throwing: ThirdPartyDataProviderError.undefined)
                    }
                } receiveValue: { response in
                    let representations: [CategoryRepresentation] = response.categories.compactMap { importingCategory in
                        guard importingCategory.isGroup == false else { return nil }
                        return CategoryRepresentation(
                            id: String(importingCategory.id),
                            name: importingCategory.name,
                            isIncome: importingCategory.isIncome,
                            isTransient: importingCategory.excludeFromTotals,
                            creationDate: importingCategory.$createdAt!,
                            lastUpdatedDate: importingCategory.$updatedAt!
                        )
                    }
                    continuation.resume(with: .success(representations))
                }
                .store(in: &cancellables)
            
        }
    }
    
    func loadTransactions() async throws -> [TransactionRepresentation] {
        guard let apiService else {
            throw LunchMoneyError.notAuthorized
        }
        
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .gmt
        
        let start = Date("2022-01-01")!
        let end = calendar.date(byAdding: .year, value: 1, to: .now)!
        let dateInterval = DateInterval(start: start, end: end)
        
        var dates: [Date] = [start]
        calendar.enumerateDates(startingAfter: dateInterval.start, matching: .init(day: 1, hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) { result, exactMatch, stop in
            guard let date = result, dateInterval.contains(date) else {
                stop = true; return
            }
            dates.append(date)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            Publishers.Sequence(sequence: dates)
                .flatMap(maxPublishers: .max(1)) { date -> AnyPublisher<API.GetTransactions.Response, Error> in
                    guard let dateInterval = calendar.dateInterval(of: DatePeriod.month, for: date) else {
                        return Fail<API.GetTransactions.Response, Error>(error: ThirdPartyDataProviderError.undefined).eraseToAnyPublisher()
                    }
                    
                    let iso8601 = Date.ISO8601FormatStyle.iso8601.calendar()
                    let startDate: String = dateInterval.start.formatted(iso8601)
                    let endDate: String = dateInterval.beforeEnd!.formatted(iso8601)
                    
                    return apiService.getTransactions(query: .init(startDate: startDate, endDate: endDate))
                }
                .map(\.transactions).reduce([], +)
                .sink { completion in
                    if case .failure(_) = completion {
                        continuation.resume(throwing: ThirdPartyDataProviderError.undefined)
                    }
                } receiveValue: { transactions in
                    let representations: [TransactionRepresentation] = transactions.compactMap { importingTransaction in
                        return TransactionRepresentation(
                            id: String(importingTransaction.id),
                            date: importingTransaction.$date!,
                            amount: Decimal(importingTransaction.$amount!),
                            currency: Currency(importingTransaction.currency),
                            notes: importingTransaction.notes ?? .empty,
                            payee: importingTransaction.payee ?? .empty,
                            asset: importingTransaction.assetId.map { String($0) },
                            category: importingTransaction.categoryId.map { String($0) },
                            tags: importingTransaction.tags.map { $0.map(\.name) } ?? []
                        )
                    }
                    continuation.resume(with: .success(representations))
                }
                .store(in: &cancellables)
        }
    }
}

private extension LunchMoneyDataProvider {
    func loadUser(_ apiService: APIService) async throws -> LMUser {
        return try await withCheckedThrowingContinuation { continuation in
            apiService.getUser()
                .sink { completion in
                    if case let .failure(error) = completion {
                        continuation.resume(throwing: error)
                    }
                } receiveValue: { user in
                    continuation.resume(returning: user)
                }
                .store(in: &cancellables)
        }
    }
}
