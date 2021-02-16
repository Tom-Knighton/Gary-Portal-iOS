//
//  StaffManageUserViews.swift
//  GaryPortal
//
//  Created by Tom Knighton on 19/01/2021.
//

import Foundation
import SwiftUI

struct EditUserView: View {
    
    @EnvironmentObject var garyportal: GaryPortal
    @Environment(\.presentationMode) var presentationMode
    var editingUser: UserDTO?
    @State var oldUser: User?
    @ObservedObject var tempUser = EditingUser()
    
    @State var isShowingImagePicker = false
    @State var isShowingImageCropper = false
    @State var possibleTeams: [Team] = []
    @State var chosenTeam: Team?
    
    @State var possibleRanks: [Rank] = []
    @State var selectedAmigoRank: Rank? = nil
    @State var selectedPositivityRank: Rank? = nil
    @State var onAppearCalled = false
    @State var isQueued = false
    
    @State var isShowingAlert = false
    @State var alertMessage = ""
    
    var body: some View {
        if self.isShowingImageCropper == true {
            ImageCropper(image: $tempUser.chosenUIImage, visible: $isShowingImageCropper) { (newImage) in
                self.tempUser.chosenUIImage = newImage
                self.tempUser.chosenImage = Image(uiImage: newImage)
                self.tempUser.hasChosenImage = true
            }
        }
        NavigationView {
            Form {
                Section {
                    VStack {
                        Spacer().frame(height: 8)
                        HStack {
                            Text("Username: ")
                            Spacer()
                        }
                        GPTextField(text: $tempUser.usernameText, placeHolder: "Username")
                        
                        HStack {
                            Text("Spanish Name: ")
                            Spacer()
                        }
                        GPTextField(text: $tempUser.spanishtext, placeHolder: "Spanish Name")
                        
                        HStack {
                            Text("Profile Picture: ")
                            Spacer()
                        }
                                                
                        if !tempUser.hasChosenImage {
                            AsyncImage(url: editingUser?.userProfileImageUrl ?? "")
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(Color.white, lineWidth: 1)
                                )
                                .frame(width: 80, height: 80)
                                .shadow(radius: 5)
                                .onTapGesture(perform:  {
                                    self.isShowingImagePicker = true
                                })
                        } else {
                            tempUser.chosenImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(Color.white, lineWidth: 1)
                                )
                                .frame(width: 80, height: 80)
                                .shadow(radius: 5)
                                .onTapGesture(perform:  {
                                    self.isShowingImagePicker = true
                                })
                        }
                    }
                    .sheet(isPresented: $isShowingImagePicker, onDismiss: showCropper, content: {
                        ImagePicker(image: $tempUser.chosenUIImage)
                    })
                    
                }
                
                Section {
                    Picker("User's Team: \(chosenTeam?.teamName ?? "")", selection: $chosenTeam) {
                        ForEach(possibleTeams) {
                            Text($0.teamName ?? "").tag(Optional($0))
                        }
                    }
                    .foregroundColor(garyportal.currentUser?.userIsAdmin == true ? Color.blue : Color.red)
                    .disabled(garyportal.currentUser?.userIsAdmin == false)
                }
                
                if garyportal.currentUser?.userIsAdmin == true {
                    Section {
                        Toggle("Is User Queued: ", isOn: $isQueued)
                    }
                }
                

                Section {
                    VStack {
                        Spacer().frame(height: 8)
                        HStack {
                            Text("Amigo Points: ")
                            Spacer()
                        }
                        GPNumberField(value: $tempUser.amigoPoints, placeHolder: "Amigo Points")
                        Spacer().frame(height: 16)
                        HStack {
                            Text("Positive Points: ")
                            Spacer()
                        }
                        GPNumberField(value: $tempUser.positivePoints, placeHolder: "Positive Points")
                        Spacer().frame(height: 8)
                    }
                }
                
                Section {
                    Picker("Amigo Rank: ", selection: $selectedAmigoRank) {
                        ForEach(possibleRanks, id: \.rankId) { rank in
                            Text(rank.rankName ?? "Rank").tag(Optional(rank))
                        }
                    }
                    Picker("Positive Rank: ", selection: $selectedPositivityRank) {
                        ForEach(possibleRanks, id: \.rankId) { rank in
                            Text(rank.rankName ?? "Rank").tag(Optional(rank))
                        }
                    }
                }
                .foregroundColor(garyportal.currentUser?.userIsAdmin == true ? Color.blue : Color.red)
                .disabled(garyportal.currentUser?.userIsAdmin == false)
                
                Section {
                    NavigationLink(destination: ManageUserBans(user: oldUser)) {
                        Text("Manage Bans")
                    }
                }
            }
            .alert(isPresented: $isShowingAlert, content: {
                Alert(title: Text("Warning"), message: Text(alertMessage), dismissButton: .cancel(Text("Ok")))
            })
            .disabled(oldUser == nil)
            .redacted(reason: oldUser == nil ? .placeholder : [])
            .frame(maxWidth: .infinity)
            .navigationTitle("Edit: \(editingUser?.userFullName ?? "")")
            .navigationBarItems(trailing:
                Button("Save User") {
                    saveUser()
                }
            )
            .onAppear {
                if (!self.onAppearCalled) {
                    self.loadTeams()
                    self.loadRanks()
                    self.loadFullUser()
                    self.onAppearCalled = true
                }
            }
        }
    }
    
    func showCropper() {
        self.isShowingImageCropper = true
    }
    
    func loadFullUser() {
        UserService.getUser(with: editingUser?.userUUID ?? "") { (completeUser) in
            self.oldUser = completeUser
            self.tempUser.load(from: self.oldUser)
            self.chosenTeam = self.oldUser?.userTeam?.team
            self.selectedAmigoRank = self.oldUser?.userRanks?.amigoRank
            self.selectedPositivityRank = self.oldUser?.userRanks?.positivityRank
            self.isQueued = self.oldUser?.isQueued == true
        }
    }
    
    func loadTeams() {
        StaffService.getTeams { (teams, error) in
            self.possibleTeams = teams ?? []
        }
    }
    
    func loadRanks() {
        StaffService.getRanks { (ranks, error) in
            self.possibleRanks = ranks ?? []
        }
    }
    
    func saveUser() {
        
        let sameUsername =  (oldUser?.userName ?? "") == tempUser.usernameText
        let sameSpanishName = (oldUser?.userSpanishName ?? "") == tempUser.spanishtext
        let sameAmigoPoints = (oldUser?.userPoints?.amigoPoints ?? 0) == Int(tempUser.amigoPoints)
        let samePositivePoints = (oldUser?.userPoints?.positivityPoints ?? 0) == Int(tempUser.positivePoints)
        let sameTeam = (oldUser?.userTeam?.teamId ?? 0) == chosenTeam?.teamId ?? 0
        let sameAmigoRank = (oldUser?.userRanks?.amigoRankId ?? 0) == selectedAmigoRank?.rankId ?? 0
        let samePositiveRank = (oldUser?.userRanks?.positivityRankId ?? 0) == selectedPositivityRank?.rankId ?? 0
        let sameQueued = (oldUser?.isQueued == self.isQueued)

        if sameUsername && sameSpanishName && sameAmigoPoints && samePositivePoints && sameTeam && sameAmigoRank && samePositiveRank && !tempUser.hasChosenImage && sameQueued {
            self.presentationMode.wrappedValue.dismiss()
            return
        }
        
        AuthService.isUsernameFree(username: tempUser.usernameText) { (isUsernameFree) in
            if !isUsernameFree && !sameUsername {
                self.alertMessage = "That username is already taken"
                return
            }

            var userdetails = StaffManagedUserDetails(userName: tempUser.usernameText, spanishName: tempUser.spanishtext, profilePictureUrl: oldUser?.userProfileImageUrl ?? "", teamId: chosenTeam?.teamId, amigoPoints: Int(tempUser.amigoPoints), positivePoints: Int(tempUser.positivePoints), amigoRankId: selectedAmigoRank?.rankId ?? 0, positiveRankId: selectedPositivityRank?.rankId ?? 0, isQueued: isQueued)

            if tempUser.hasChosenImage {
                UserService.updateUserProfileImage(userUUID: oldUser?.userUUID ?? "", newImage: tempUser.chosenUIImage) { (newURL) in
                    userdetails.profilePictureUrl = newURL
                }
            }
            
            StaffService.staffEditUser(userUUID: oldUser?.userUUID ?? "", details: userdetails) { (newUser, error) in
                DispatchQueue.main.async {
                    if error == nil {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

class EditingUser: ObservableObject {
    
    @Published var emailText = ""
    @Published var usernameText = ""
    @Published var spanishtext = ""
    @Published var fullNameText = ""
    @Published var hasChosenImage = false
    @Published var chosenUIImage = UIImage(named: "IconSprite") ?? UIImage()
    @Published var chosenImage = Image("IconSprite")
    @Published var amigoPoints = "0"
    @Published var positivePoints = "0"
    
    
    func load(from user: User?) {
        DispatchQueue.main.async {
            self.emailText = user?.userAuthentication?.userEmail ?? ""
            self.usernameText = user?.userName ?? ""
            self.fullNameText = user?.userFullName ?? ""
            self.spanishtext = user?.userSpanishName ?? ""
            self.amigoPoints = String(describing: user?.userPoints?.amigoPoints ?? 0)
            self.positivePoints = String(describing: user?.userPoints?.positivityPoints ?? 0)
            
        }
    }
}


struct ManageUserBans: View {
    
    @EnvironmentObject var garyportal: GaryPortal
    @State var user: User?
    
    @State var isShowingAlert = false
    @State var alertMessage = ""
    @State var selectedBanId = 0
    
    let secondaryButton = Alert.Button.cancel(Text("Cancel"))
    
    var body: some View {
        List {
            NavigationLink(destination: StaffCreateBanView(user: user).environmentObject(garyportal)) {
                Text("Add New ban")
            }
            ForEach(user?.userBans ?? [], id: \.userBanId) { ban in
                VStack {
                    Text(ban.banType?.banTypeName ?? "")
                        .font(.custom("Montserrat-SemiBold", size: 19))
                    Spacer()
                    Text("Reason: " + (ban.banReason ?? ""))
                        .multilineTextAlignment(.center)
                        .font(.custom("Montserrat-Regular", size: 17))
                    Spacer()
                    Text("Expires: \(ban.banExpires ?? Date())")
                        .multilineTextAlignment(.center)
                    GPGradientButton(action: { self.selectedBanId = ban.userBanId ?? 0; isShowingAlert = true; alertMessage = "Are you sure you want to revoke this ban?" }, buttonText: "Revoke Ban", gradientColours: [Color(UIColor(hexString: "#333333")), Color(UIColor(hexString: "#dd1818"))])
                        
                        .alert(isPresented: $isShowingAlert, content: {
                            Alert(title: Text("Warning"), message: Text(alertMessage), primaryButton: Alert.Button.default(Text("Revoke Ban")) {
                                revokeBan(banId: selectedBanId)
                            }, secondaryButton: secondaryButton)
                        })
                        
                }
            }
        }
        .navigationTitle("Manage Bans")
        .onAppear {
            loadUser()
        }
       
    }
    
    func revokeBan(banId: Int) {
        StaffService.revokeBan(banId: banId, userUUID: garyportal.currentUser?.userUUID ?? "")
        user?.RemoveBan(banId: banId)
    }
    
    func loadUser() {
        UserService.getUser(with: user?.userUUID ?? "") { (newUser) in
            if newUser != nil {
                self.user = newUser
            }
        }
    }
}

struct StaffCreateBanView: View {
    
    @State var user: User?
    @EnvironmentObject var garyportal: GaryPortal
    @Environment(\.presentationMode) var presentationMode
    
    @State var banTypes: [BanType] = []
    @State var selectedBanType: BanType?
    @State var selectedBanReason = ""
    @State var banExpiry = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    
    var body: some View {
        Form {
            Section {
                VStack {
                    Text("Ban Type:")
                        .font(.custom("Montserrat-SemiBold", size: 17))
                    Picker("Ban Reason:", selection: $selectedBanType) {
                        ForEach(banTypes, id: \.banTypeId) { banType in
                            Text(banType.banTypeName ?? "Ban Type").tag(Optional(banType))
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            
            Section {
                VStack {
                    Text("Ban Reason:")
                        .font(.custom("Montserrat-SemiBold", size: 17))
                    TextEditor(text: $selectedBanReason)
                        .padding()
                        .overlay(
                            ZStack {
                                RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).foregroundColor(Color.clear)
                                if self.selectedBanReason.isEmpty {
                                    HStack {
                                        Spacer().frame(width: 16)
                                        Text("Ban Reason...")
                                            .foregroundColor(.gray)
                                        Spacer()
                                    }
                                }
                            }
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color(UIColor.secondarySystemBackground))
                                .shadow(radius: 10)
                        )
                    Spacer().frame(height: 8)
                }
            }
            
            Section {
                VStack {
                    Text("Ban Expires:")
                        .font(.custom("Montserrat-SemiBold", size: 17))
                    
                    DatePicker("Ban Expiry:", selection: $banExpiry)
                        .datePickerStyle(CompactDatePickerStyle())
                }
            }
        }
        .navigationTitle("Add New Ban")
        .navigationBarItems(trailing:
            Button("Save Ban") {
                createBan()
            }
        )
        .onAppear {
            self.loadBanTypes()
        }
    }
    
    func loadBanTypes() {
        StaffService.getBanTypes { (_bantypes, error) in
            if error == nil {
                self.banTypes = _bantypes ?? []
                self.selectedBanType = self.banTypes.first
            }
        }
    }
    
    func createBan() {
        let userBan = UserBan(userBanId: 0, userUUID: user?.userUUID ?? "", banIssued: Date(), banExpires: self.banExpiry, banTypeId: self.selectedBanType?.banTypeId ?? 0, banReason: self.selectedBanReason, bannedByUUID: garyportal.currentUser?.userUUID ?? "", bannedUser: nil, banType: nil, bannedBy: nil)
        StaffService.createBan(userBan: userBan) { (newBan, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}



struct editpreview: PreviewProvider {
    
    static var previews: some View {
        EditUserView()
            .environmentObject(GaryPortal.shared)
    }
}
