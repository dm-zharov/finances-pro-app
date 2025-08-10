//
//  LunchMoneyAccessTokenView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 14.12.2023.
//

import SwiftUI
#if canImport(SwiftUIIntrospect)
import SwiftUIIntrospect
#endif

struct LunchMoneyAccessTokenView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var statement: Statement?
    let onCompletion: () -> Void
    
    @State private var dataProvider = LunchMoneyDataProvider()
    @State private var accessToken: String = .empty
    
    @State private var isReady: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack {
            Form {
                VStack(spacing: 16.0) {
                    HStack {
                        Image(.lunchMoney)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80.0, height: 80.0)
                    }
                    .frame(maxWidth: .infinity)

                    NavigationTitle(
                        "Authorization",
                        description: "Sign in with an access token to automatically import existing financial data. You could safely revoke the token after the process is finished."
                    )
                    #if os(iOS)
                    .padding(.bottom, 16.0)
                    #endif
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                Section {
                    TextField("Enter Access Token", text: $accessToken)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .introspect(.textField, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18)) { textField in
                            textField.clearButtonMode = .whileEditing
                        }
                        #endif
                        .submitLabel(.continue)
                } footer: {
                    HStack(spacing: .zero) {
                        Spacer(minLength: .zero)

                        Link(
                            "Don't have an Access Token?",
                            destination: URL(string: "https://my.lunchmoney.app/developers")!
                        )
                        .font(.callout)

                        Spacer(minLength: .zero)
                    }
                    .padding(.vertical, 8.0)
                }
            }
            .formStyle(.grouped)
        }
        .navigationDestination(isPresented: $isReady) {
            ImportProgressView()
                .task(priority: .high) {
                    do {
                        let statement = Statement()
                        statement.assets = try await dataProvider.loadAssets()
                        statement.categories = try await dataProvider.loadCategories()
                        statement.transactions = try await dataProvider.loadTransactions()
                        
                        guard !Task.isCancelled else {
                            throw ThirdPartyDataProviderError.undefined
                        }

                        self.statement = statement
                        self.isReady = false
                    } catch {
                        self.isReady = false
                    }
                }
        }
        .sheet(item: $statement) { statement in
            NavigationStack {
                ImportResultView(statement, onCompletion: onCompletion)
            }
        }
        .confirmationContainer {
            Button {
                submit()
            } label: {
                VStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text("Continue")
                    }
                }
                .animation(.none, value: isLoading)
            }
            .disabled(accessToken.isEmpty)
            
            Button(String.empty) { }
                .hidden()
        }
        .disabled(isLoading)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    private func submit() {
        Task {
            isLoading = true
            do {
                try await dataProvider.authorize(with: accessToken)
                isReady = true
            } catch {
                accessToken = .empty
                isReady = false
            }
            isLoading = false
        }
    }
}

#Preview {
    LunchMoneyAccessTokenView {
        
    }
}
