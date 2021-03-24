//
//  StickerPickerView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 24/03/2021.
//

import SwiftUI

class StickerPickerDataSource: ObservableObject {
    
    @Published var stickers: [Sticker] = []
    
    func loadStickers() {
        AppService.GetStickers { (received) in
            DispatchQueue.main.async {
                self.stickers = received ?? []
            }
        }
    }
    
    func filteredStickers(filter: String) -> [Sticker] {
        guard filter.trim().count != 0 else { return self.stickers }
        
        return self.stickers.filter { (sticker) -> Bool in
            sticker.stickerName?.lowercased().contains(filter.lowercased()) == true
        }
    }
}

struct StickerPickerView: View {
    @ObservedObject var datasource = StickerPickerDataSource()
    @State var filterText = ""
    
    var onSelectedSticker: (_ urlToSticker: String) -> ()
    
    init(_ completion: @escaping (_ urlToSticker: String) -> ()) {
        self.onSelectedSticker = completion
    }
    
    var body: some View {
        ScrollView {
            SearchBar(text: $filterText).padding(.top, 30)
            LazyVGrid(columns: [
                GridItem(.flexible(minimum: 100, maximum: 150)),
                GridItem(.flexible(minimum: 100, maximum: 150)),
                GridItem(.flexible(minimum: 100, maximum: 150)),
            ], spacing: 12) {
                ForEach(datasource.filteredStickers(filter: self.filterText), id: \.self) { sticker in
                    Button(action: { self.onSelectedSticker(sticker.stickerURL ?? "") }) {
                        AsyncImage(url: sticker.stickerURL ?? "")
                            .aspectRatio(contentMode: .fit)
                    }
                }
            }.padding(.horizontal, 12)
        }
        .onAppear {
            self.datasource.loadStickers()
        }
    }
}
