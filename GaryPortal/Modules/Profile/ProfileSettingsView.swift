//
//  ProfileSettingsView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 15/01/2021.
//

import SwiftUI

struct ProfileSettingsView: View {
    
    @ObservedObject var datasource: ProfileViewDataSource
    @Environment(\.presentationMode) var presentationMode
    
    @State var usernameText = ""
    @State var emailText = ""
    @State var fullNameText = ""
    @State var hasChosenNewImage = false
    @State var newImage: Image?
    @State var newUIImage: UIImage = UIImage()
    @State var notificationsMuted = false
    
    @State var isShowingError = false
    @State var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                ScrollView {
                    AccountSettingsView(datasource: self.datasource, usernameText: $usernameText, emailText: $emailText, fullNameText: $fullNameText, hasChosenNewImage: $hasChosenNewImage, newImage: $newImage, newUIImage: $newUIImage)
                    Divider()
                    SecuritySettingsView()
                    Divider()
                    AppSettingsView(datasource: self.datasource, notifications: $notificationsMuted)
                }
                .padding()
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }, label: {
                    Text("Cancel")
                        .font(.body)
                        .foregroundColor(.primary)
                })
                .padding(5)
                .background(Color("Section"))
                .cornerRadius(5)
                
                Button(action: { saveSettings() }, label: {
                    Text("Save Settings")
                        .bold()
                        .foregroundColor(.primary)
                })
                .padding(5)
                .background(Color("Section"))
                .cornerRadius(5)
            })
        }
        .background(Color.red)
        .alert(isPresented: $isShowingError, content: {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("Ok")))
        })
    }
    
    func saveSettings() {
        guard let oldUsername = self.datasource.user?.userName, let oldEmail = self.datasource.user?.userAuthentication?.userEmail, let oldFullName = self.datasource.user?.userFullName, let oldMute = self.datasource.user?.notificationsMuted else { return }
        
        if oldUsername != usernameText || oldEmail != emailText || oldFullName != fullNameText || hasChosenNewImage || oldMute != notificationsMuted {
            AuthService.isEmailFree(email: emailText.trim()) { (isEmailFree) in
                if !isEmailFree && oldEmail != emailText.trim() {
                    self.isShowingError = true
                    self.errorMessage = GaryPortalConstants.Errors.EmailTaken
                    return
                }
                
                AuthService.isUsernameFree(username: usernameText.trim()) { (isUsernameFree) in
                    if !isUsernameFree && oldUsername != usernameText.trim() {
                        self.isShowingError = true
                        self.errorMessage = GaryPortalConstants.Errors.UsernameTaken
                        return
                    }
                    
                    var newDetails = UserDetails(userName: usernameText, userEmail: emailText, fullName: fullNameText, profilePictureUrl: self.datasource.user?.userProfileImageUrl ?? "", notificationsMuted: notificationsMuted)
                    
                    if hasChosenNewImage {
                        UserService.updateUserProfileImage(userUUID: self.datasource.user?.userUUID ?? "", newImage: self.newUIImage) { (newURL) in
                            newDetails.profilePictureUrl = newURL
                            self.updateSettings(userDetails: newDetails)
                        }
                    } else {
                        self.updateSettings(userDetails: newDetails)
                    }
                }
            }
        }
    }
    
    func updateSettings(userDetails: UserDetails) {
        UserService.updateUserDetails(userUUID: self.datasource.user?.userUUID ?? "", userDetails: userDetails) { (newUser, error) in
            if let _ = error {
                return
            }
            DispatchQueue.main.async {
                GaryPortal.shared.currentUser = newUser
                self.datasource.user = newUser
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct AccountSettingsView: View {
    
    @ObservedObject var datasource: ProfileViewDataSource
    @Binding var usernameText: String
    @Binding var emailText: String
    @Binding var fullNameText: String
    @Binding var hasChosenNewImage: Bool
    @Binding var newImage: Image?
    @Binding var newUIImage: UIImage
    
    @State var isShowingImagePicker = false
    @State var isShowingImageCropper = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer().frame(height: 8)
                HStack {
                    Spacer().frame(width: 8)
                    Text("Account:")
                        .font(.custom("Montserrat-SemiBold", size: 19))
                    Spacer()
                }
                
                Group {
                    Spacer().frame(height: 16)
                    HStack {
                        Spacer().frame(width: 8)
                        Text("Username:")
                            .font(.custom("Montserrat-Light", size: 15))
                        Spacer()
                    }
                    HStack {
                        Spacer().frame(width: 16)
                        GPTextField(text: $usernameText, placeHolder: "Username")
                        Spacer()
                    }
                    Spacer().frame(height: 8)
                }
                 
                Group {
                    HStack {
                        Spacer().frame(width: 8)
                        Text("Email:")
                            .font(.custom("Montserrat-Light", size: 15))
                        Spacer()
                    }
                    HStack {
                        Spacer().frame(width: 16)
                        GPTextField(text: $emailText, placeHolder: "Email Address")
                        Spacer()
                    }
                    Spacer().frame(height: 8)
                }
                
                Group {
                    HStack {
                        Spacer().frame(width: 8)
                        Text("Full Name:")
                            .font(.custom("Montserrat-Light", size: 15))
                        Spacer()
                    }
                    HStack {
                        Spacer().frame(width: 16)
                        GPTextField(text: $fullNameText, placeHolder: "Full Name")
                        Spacer()
                    }
                    Spacer().frame(height: 16)
                }
                
                if !hasChosenNewImage {
                    AsyncImage(url: self.datasource.user?.userProfileImageUrl ?? "")
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
                    newImage?
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
                
                NavigationLink(destination: BlockedUsersManagement()) {
                    GPGradientButton(action: {}, buttonText: Text("Blocked Users   ") + Text(Image(systemName: "chevron.right")), gradientColours: [Color.red])
                        .foregroundColor(.white)
                        .disabled(true)
                }
                
                
                Spacer().frame(height: 16)
            }
            .cornerRadius(radius: 15, corners: [.allCorners])
            
            if self.isShowingImageCropper {
                ImageCropper(image: self.$newUIImage, visible: self.$isShowingImageCropper) { (finalImage) in
                    self.newUIImage = finalImage
                    self.newImage = Image(uiImage: finalImage)
                    self.hasChosenNewImage = true
                }
            }
            
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(radius: 15, corners: [.topLeft, .topRight])
        .background(Color("Section"))
        .sheet(isPresented: $isShowingImagePicker) {
            MediaPicker(limit: 1, filter: .images) { (picked, items) in
                self.isShowingImagePicker = false
                if picked {
                    if let items = items,
                       let item = items.items.first,
                       item.mediaType == .photo, let photo = item.photo {
                        self.newUIImage = photo
                        self.isShowingImageCropper = true
                    }
                }
            }
        }
        .onAppear(perform: loadData)
        .cornerRadius(radius: 15, corners: [.topLeft, .topRight])
    }
    
    func loadData() {
        self.usernameText = self.datasource.user?.userName ?? ""
        self.emailText = self.datasource.user?.userAuthentication?.userEmail ?? ""
        self.fullNameText = self.datasource.user?.userFullName ?? ""
    }
}

struct SecuritySettingsView: View {
       
    @State var isShowingAlert = false
    @State var alertContent: [String] = []
    
    var body: some View {
        VStack {
            Spacer().frame(height: 8)
            HStack {
                Spacer().frame(width: 8)
                Text("Security:")
                    .font(.custom("Montserrat-SemiBold", size: 19))
                Spacer()
            }
           
            GPGradientButton(action: { self.sendResetEmail() }, buttonText: "Reset Password", gradientColours: [Color(UIColor.darkText)])
            GPGradientButton(action: { GaryPortal.shared.logoutUser() }, buttonText: "Log Out", gradientColours: [Color(UIColor.darkText)])
            Spacer().frame(height: 16)
            
        }
        .frame(maxWidth: .infinity)
        .background(Color("Section"))
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text(alertContent[0]), message: Text(alertContent[1]), dismissButton: .default(Text("Ok")))
        }
    }
    
    func sendResetEmail() {
        AuthService.requestPassReset(uuid: GaryPortal.shared.currentUser?.userUUID ?? "")
        self.alertContent = ["Password Reset", "An e-mail has been sent to the email address associated with your account, allowing you to reset your password. Please allow up to 15 minutes for this email to arrive and please note it may appear in your 'spam' or 'junk' inboxes."]
        self.isShowingAlert = true
    }
}

struct AppSettingsView: View {
    
    @ObservedObject var datasource: ProfileViewDataSource
    @Binding var notifications: Bool
    
    var body: some View {
        VStack {
            Spacer().frame(height: 8)
            HStack {
                Spacer().frame(width: 8)
                Text("App:")
                    .font(.custom("Montserrat-SemiBold", size: 19))
                Spacer()
            }
           
            HStack {
                Spacer().frame(width: 8)
                Toggle("Mute all notifications", isOn: $notifications)
                Spacer().frame(width: 8)
            }
            .padding()
            
            GPGradientButton(action: {}, buttonText: "View Latest Changelog", gradientColours: [Color(UIColor.darkText)])
            GPGradientButton(action: {}, buttonText: "Rate App", gradientColours: [Color(UIColor.darkText)])
            Text("\(Bundle.main.appName) v\(Bundle.main.versionNumber) (Build \(Bundle.main.buildNumber))")
            Spacer().frame(height: 16)
            
        }
        .frame(maxWidth: .infinity)
        .background(Color("Section"))
        .onAppear {
            self.notifications = datasource.user?.notificationsMuted ?? false
        }
        .cornerRadius(radius: 15, corners: [.bottomLeft, .bottomRight])
    }
}

struct BlockedUsersManagement: View {
    
    @ObservedObject var datasource: GaryPortal = GaryPortal.shared
    @ObservedObject var blocksDataSource = BlockedUsersDataSource()
    
    var body: some View {
        List {
            ForEach(self.blocksDataSource.userBlocks, id: \.blockedUserUUID) { block in
                Menu(content: {
                    Button(action: { self.blocksDataSource.unblockUser(uuid: block.blockedUserUUID ?? "") }, label: {
                        Text("Unblock User")
                    })
                    Button(action: {}, label: { Text("Cancel") })
                }, label: {
                    UserListElement(user: block.blockedUserDTO, displaysChevron: false)
                })
            }
        }
        .navigationTitle("Blocked Users")
        .onAppear {
            self.blocksDataSource.load(for: datasource.currentUser?.userUUID ?? "")
        }
    }
}

class BlockedUsersDataSource: ObservableObject {
    @Published var userBlocks: [UserBlock] = []
    @ObservedObject var profileDataSource: GaryPortal = GaryPortal.shared
    var currentUUID = ""
    
    func load(for uuid: String) {
        self.currentUUID = uuid
        UserService.getBlockedUsers(userUUID: uuid) { (blocks, error) in
            if let blocks = blocks {
                DispatchQueue.main.async {
                    self.userBlocks = blocks
                    self.profileDataSource.currentUser?.blockedUsers = blocks
                }
            }
        }
    }
    
    func unblockUser(uuid: String) {
        UserService.unblockUser(blockerUUID: GaryPortal.shared.currentUser?.userUUID ?? "", blockedUUID: uuid) {
            DispatchQueue.main.async {
                self.userBlocks.removeAll(where: { $0.blockedUserUUID == uuid })
                self.load(for: self.currentUUID)
            }
        }
    }
}

struct SettingsPreview: PreviewProvider {
    static var previews: some View {
        ProfileSettingsView(datasource: ProfileViewDataSource())
    }
}
