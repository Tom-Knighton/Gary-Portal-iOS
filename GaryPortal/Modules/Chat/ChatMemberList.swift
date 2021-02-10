//
//  ChatMemberList.swift
//  GaryPortal
//
//  Created by Tom Knighton on 10/02/2021.
//

import SwiftUI

struct ChatMemberList: View {
    @State var users: [ChatMember] = []
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            ScrollView {
                LazyVStack {
                    ForEach(users, id: \.userUUID) { user in
                        let lastReadMessage = user.userUUID == GaryPortal.shared.currentUser?.userUUID ? "Last Read: Now" : "Last Read: \(user.lastReadAt?.niceDateAndTime() ?? "Never")"
                        UserListElement(user: user.userDTO, secondaryText: lastReadMessage, displaysChevron: false)
                    }
                }
            }
        }
        .navigationBarTitle("Members")
    }
}

struct ChatMemberList_Previews: PreviewProvider {
    static var previews: some View {
        ChatMemberList()
    }
}
