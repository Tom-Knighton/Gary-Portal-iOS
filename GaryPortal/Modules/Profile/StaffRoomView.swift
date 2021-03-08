//
//  StaffRoomView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 15/01/2021.
//

import SwiftUI
import AVFoundation

struct StaffRoomView: View {
    @ObservedObject var garyportal = GaryPortal.shared
    
    var body: some View {
        NavigationView {
            StaffRoomHome()
                .navigationTitle("Staff Room")
        }
    }
}

struct StaffRoomHome: View {
    
    @ObservedObject var garyportal = GaryPortal.shared
    @State var announcements: [StaffRoomAnnouncement] = []
    let manageTeamGradient = [Color(UIColor(hexString: "#DA4453")), Color(UIColor(hexString: "#89216B"))]
    let queueGradient = [Color(UIColor(hexString: "#c94b4b")), Color(UIColor(hexString: "#4b134f"))]
    let relieveGradient = [Color(UIColor(hexString: "#603813")), Color(UIColor(hexString: "#b29f94"))]
    let jokeGradient = [Color(UIColor(hexString: "#11998e")), Color(UIColor(hexString: "#38ef7d"))]
    
    @State var isShowingTeamList = false
    @State var isShowingRelieveSelf = false
    @State var isShowingMessage = false
    @State var isShowingQueueList = false
    @State var messageTitle = ""
    @State var message = ""
    
    var body: some View {
        VStack {
            ScrollView {
                NavigationLink(destination: AnnouncementsView(announcements: $announcements)) {
                    VStack {
                        Spacer().frame(height: 16)
                        Text(announcements.first?.announcement ?? "Test announcement 2")
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding(.leading, 8)
                            .padding(.trailing, 8)
                            .padding(.bottom, 8)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.primary)
                        Text("See all announcements ➜")
                            .padding(.bottom, 8)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 5).stroke()
                            .foregroundColor(Color.primary)
                    )
                    .padding()
                }
                
                Text("Team: \(garyportal.currentUser?.userTeam?.team?.teamName ?? "Team")")
                    .font(.custom("Montserrat-SemiBold", size: 19))
                
                Group {
                    Spacer().frame(height: 16)
                    GPGradientButton(action: { self.isShowingTeamList = true }, buttonText: "Manage Team ➜", gradientColours: manageTeamGradient)
                        .padding()
                        .sheet(isPresented: $isShowingTeamList, content: {
                            UserList(teamId: garyportal.currentUser?.userTeam?.teamId ?? 0)
                        })
                    
                    if garyportal.currentUser?.userIsAdmin ?? true {
                        GPGradientButton(action: { self.isShowingQueueList = true }, buttonText: "Manage Queue ➜", gradientColours: queueGradient)
                            .padding()
                            .sheet(isPresented: $isShowingQueueList, content: {
                                UserList(teamId: 0, isQueue: true)
                            })
                    }
                    
                    GPGradientButton(action: { self.isShowingRelieveSelf = true }, buttonText: "Relieve Self ➜", gradientColours: relieveGradient)
                        .padding()
                        .sheet(isPresented: $isShowingRelieveSelf, content: {
                            StaffRoomRelieveView()
                        })
                    GPGradientButton(action: { getJoke() }, buttonText: "Tell me a joke", gradientColours: jokeGradient)
                        .padding()
                }
                Spacer()
            }
        }
        .alert(isPresented: $isShowingMessage, content: {
            Alert(title: Text(messageTitle), message: Text(message), dismissButton: .default(Text("Haha! :)")))
        })
        .onAppear {
            self.loadAnnouncements()
        }
    }
    
    func loadAnnouncements() {
        StaffService.getStaffAnnouncements { (announcements, error) in
            if let _ = error {
                return
            }
            self.announcements = announcements ?? []
        }
    }
    
    func getJoke() {
        StaffService.getJoke { (joke, error) in
            if error == nil {
                self.messageTitle = joke?.setup ?? ""
                self.message = joke?.punchline ?? ""
                self.isShowingMessage = true
            }
        }
    }
}

struct UserList: View {
    
    @ObservedObject var garyportal = GaryPortal.shared
    @State var users: [UserDTO] = []
    @State var teamId = 0
    @State var editingUser: UserDTO? = nil
    @State var isQueue = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                ScrollView {
                    LazyVStack {
                        ForEach(users, id: \.userUUID) { user in
                            UserListElement(user: user)
                                .onTapGesture {
                                    self.editingUser = user
                                }
                                .sheet(item: $editingUser, onDismiss: {
                                    self.loadView(queued: isQueue)
                                }, content: { (tappedUser) in
                                    EditUserView(editingUser: tappedUser)
                                })
                                .disabled((user.userIsAdmin ?? false) && garyportal.currentUser?.userIsAdmin == false)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Users")
        }
        .onAppear {
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.label]
            self.loadView(queued: isQueue)
        }
    }
    
    func loadView(queued: Bool = false) {
        if garyportal.currentUser?.userIsAdmin == true {
            self.teamId = 0
        }
        if queued {
            AdminService.getQueuedUsers { (returned, error) in
                self.users = (returned?.compactMap { $0.ConvertToDTO() }) ?? []
            }
        } else {
            UserService.getAllUsers(for: self.teamId) { (returned, error) in
                self.users = (returned?.filter { $0.userUUID != garyportal.currentUser?.userUUID ?? ""}.compactMap { $0.ConvertToDTO() }) ?? []
            }
        }
    }
}

struct UserListElement: View {
    
    @State var user: UserDTO?
    @State var secondaryText: String?
    var displaysChevron = true
    
    var body: some View {
        HStack {
           
            AsyncImage(url: user?.userProfileImageUrl ?? "")
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                .padding()
                .frame(width: 80, height: 80)
            VStack {
                Text(user?.userFullName ?? "")
                    .frame(maxWidth: .infinity)
                if let secondaryText = secondaryText {
                    Text(secondaryText)
                        .font(.custom("Montserrat-Light", size: 14))
                        .frame(maxWidth: .infinity)

                }
            }
            Spacer()
            if displaysChevron {
                Button(action: {}) {
                    Image(systemName: "chevron.right")
                        .font(.body)
                }
            }
            Spacer().frame(width: 16)
        }
        .frame(maxWidth: .infinity)
        .background(Color("Section"))
        .cornerRadius(20)
        .padding(.top, 8)
        .padding(.leading, 8)
        .padding(.trailing, 8)
    }
}

struct AnnouncementsView: View {
    
    @Binding var announcements: [StaffRoomAnnouncement]
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List(announcements, id: \.announcementId) { announcement in
                VStack {
                    Group {
                        Text("\(announcement.userDTO?.userFullName ?? ""):")
                            .font(.custom("Montserrat-SemiBold", size: 19))
                        Text(announcement.announcement ?? "")
                            .font(.custom("Montserrat-Regular", size: 17))
                            .multilineTextAlignment(.center)
                        Text(announcement.announcementDate?.niceDateAndTime() ?? "")
                            .font(.custom("Montserrat-Light", size: 14))
                    }
                    .contextMenu(menuItems: {
                        Button(action: { UIPasteboard.general.string = announcement.announcement ?? "" } ) {
                            Text("Copy Announcement")
                            Image(systemName: "doc.on.doc")
                        }
                        if GaryPortal.shared.currentUser?.userIsAdmin == true {
                            Button(action: { self.deleteAnnouncement(announcementId: announcement.announcementId ?? 0) }) {
                                Text("Delete Announcement")
                                Image(systemName: "trash")
                            }
                        }
                    })
                }
                .frame(maxWidth: .infinity)
            }
            
            HStack {
                Spacer()
                NavigationLink(destination: NavigationLazyView(NewAnnouncementView(announcements: $announcements)), label: {
                    Image(systemName: "plus.circle")
                        .padding(16)
                        .background(Color.purple)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                })
                Spacer().frame(width: 16)
            }
           
        }
        .navigationTitle("Announcements")
        .onAppear {
            self.announcements.sort(by: { $0.announcementDate ?? Date() > $1.announcementDate ?? Date() })
        }
    }
    
    func deleteAnnouncement(announcementId: Int) {
        AdminService.deleteStaffAnnouncement(id: announcementId)
        self.announcements.removeAll(where: { $0.announcementId == announcementId })
    }
}

struct NewAnnouncementView: View {
    
    @Binding var announcements: [StaffRoomAnnouncement]
    @State var text: String = ""
    var buttonGradient = [Color(UIColor(hexString: "#0575E6")), Color(UIColor(hexString: "#021B79"))]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Enter your announcement message:")
            TextEditor(text: $text)
                .padding()
                .shadow(radius: 5)
                .overlay(
                    ZStack(alignment: .leading) {
                        if self.text.isEmpty {
                            Text("Your announcement...")
                                .foregroundColor(.gray)
                                .disabled(true)
                                .padding()
                        }
                    }
                )
            GPGradientButton(action: { self.postAnnouncement() }, buttonText: "Post Announcement", gradientColours: self.buttonGradient)
                .padding()
        }
        .navigationTitle("New Announcement")
    }
    
    func postAnnouncement() {
        if !self.text.isEmptyOrWhitespace() {
            AdminService.postStaffAnnouncement(uuid: GaryPortal.shared.currentUser?.userUUID ?? "", announcement: self.text.trim()) { (announcement, error) in
                if let announcement = announcement {
                    DispatchQueue.main.async {
                        self.announcements.append(announcement)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct StaffRoomRelieveView: View {
    
    @ObservedObject var garyportal = GaryPortal.shared
    @State var tempRelieved = 0
    var messages = [", wow!", ", great job!", ", keep going!", ", nearly there!", ", are you okay?", ", fantastic news!", ", marvellous!", ", nearly as much as me!", ", and I can feel more!", ", and it doesnt even hurt!", ", never question yourself", ", it takes more than that!", ", keep going and version 5 will be released!", ", you make me so proud 😢", ", that's impressive!", ", but I could do more", ", all I feel now is pain :(", ", those are some dirty eggs", ", must be under a lot of stress!", ", let me see!"]
    @State var currentMessage = "."
    var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        VStack {
            Button(action: relieveSelf, label: {
                Image("toilet")
            })
            Text("You've relieved yourself \(tempRelieved) times this session\(currentMessage)")
                .font(.custom("Montserrat-SemiBold", size: 19))
                .multilineTextAlignment(.center)
                .padding()
            if (garyportal.currentUser?.userPoints?.bowelsRelieved ?? 0) > 1 {
                Text("You've relieved yourself \((garyportal.currentUser?.userPoints?.bowelsRelieved ?? 0) + self.tempRelieved) times so far in total!")
                    .font(.custom("Montserrat-ExtraLight", size: 15))
            }
        }
        .onDisappear {
            guard var points = garyportal.currentUser?.userPoints else { return }
            points.bowelsRelieved = (points.bowelsRelieved ?? 0) + self.tempRelieved
            UserService.updatePointsForUser(userUUID: garyportal.currentUser?.userUUID ?? "", userPoints: points) { (newPoints, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        garyportal.currentUser?.userPoints = newPoints
                    }
                }
            }
        }
    }
    
    func relieveSelf() {
        self.tempRelieved += 1
        self.currentMessage = self.messages.randomElement() ?? "."
        Sounds.playSounds(soundfile: "toilet.mp3")
    }
}
