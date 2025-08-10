//
//  PageControl.swift
//  Finances
//
//  Created by Dmitriy Zharov on 30.11.2023.
//

import SwiftUI

#if os(iOS)
struct PageControl: UIViewRepresentable {
    @Binding var currentPage: Int
    let numberOfPages: Int
    
    func makeUIView(context: Context) -> UIPageControl {
        let uiView = UIPageControl()
        uiView.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        return uiView
    }
    
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
        uiView.numberOfPages = numberOfPages
        uiView.currentPageIndicatorTintColor = UIColor.label
        uiView.pageIndicatorTintColor = UIColor.placeholderText
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIPageControl, context: Context) -> CGSize? {
        return uiView.size(forNumberOfPages: numberOfPages)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject {
        @Binding var currentPage: Int
        let numberOfPages: Int
        
        @objc func valueChanged(_ sender: UIPageControl) {
            self.currentPage = sender.currentPage
        }
        
        init(currentPage: Binding<Int>, numberOfPages: Int) {
            self._currentPage = currentPage
            self.numberOfPages = numberOfPages
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(currentPage: $currentPage, numberOfPages: numberOfPages)
    }
}
#endif
