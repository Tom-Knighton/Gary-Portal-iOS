//
//  GPReverseList.swift
//  GaryPortal
//
//  Created by Tom Knighton on 06/05/2021.
//

import SwiftUI

struct IsVisibleKey: PreferenceKey {
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

struct GPReverseList<Element, Content>: View where Element: Identifiable, Content: View {
    
    private let items: [Element]
    private let reverseOrder: Bool
    private let viewForItem: (Element) -> Content
    @Binding var canShowPaginator: Bool
    @Binding var hasReachedTop: Bool
    
    init(_ items: [Element], reverseItemOrder: Bool = true, hasReachedTop: Binding<Bool>, canShowPaginator: Binding<Bool> = .constant(true), viewForItem: @escaping (Element) -> Content) {
        self.items = items
        self.reverseOrder = reverseItemOrder
        self._canShowPaginator = canShowPaginator
        self._hasReachedTop = hasReachedTop
        self.viewForItem = viewForItem
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                GeometryReader { topGeometry in
                    let frame = topGeometry.frame(in: .global)
                    let isVisible = geometry.frame(in: .global).contains(CGPoint(x: frame.midX, y: frame.midY))
                    
                    HStack {
                        Spacer()
                        ProgressView().progressViewStyle(CircularProgressViewStyle())
                        Spacer()
                    }
                    .preference(key: IsVisibleKey.self, value: isVisible)
                }
                .frame(height: 30)
                .onPreferenceChange(IsVisibleKey.self, perform: { value in
                    hasReachedTop = value
                })
                .if(!self.canShowPaginator) {
                    $0.hidden()
                }
                LazyVStack(spacing: 0) {
                    ForEach(reverseOrder ? items : items.reversed()) { item in
                        self.viewForItem(item)
                    }
                    .id(UUID())
                }
                
            }
        }
    }
    
    func setCanPaginate(_ value: Bool) {
        self.canShowPaginator = value
    }
}

struct gptestview: View {
    
    @State var paginate = false
    @State var showPaginate = true
    @ObservedObject var datasource = ChatMessagesDataSource()
    var body: some View {
        GPReverseList(["", ""], hasReachedTop: $paginate, canShowPaginator: $showPaginate) { message in
            VStack {
                
                    
            }
        }
    }
}
