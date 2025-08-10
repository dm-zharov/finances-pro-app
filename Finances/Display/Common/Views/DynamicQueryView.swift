//
//  DynamicQueryView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 18.04.2024.
//

import SwiftUI
import SwiftData

struct DynamicQueryView<Content, Element>: View where Content: View, Element: PersistentModel {
    @Query private var data: [Element]
    let content: ([Element]) -> Content
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        content(data)
    }
    
    init(query: Query<Element, [Element]>, @ViewBuilder content: @escaping ([Element]) -> Content) {
        self._data = query
        self.content = content
    }
}
