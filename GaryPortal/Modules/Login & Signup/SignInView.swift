//
//  SignInView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 14/01/2021.
//

import SwiftUI
import Introspect
import AlertToast

let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)

struct GradientBackground: View {
    
    var image = "BackgroundGradient"
    var body: some View {
        GeometryReader { geometry in
            withAnimation(.easeInOut) {
                Image(image)
                    .resizable()
                    .aspectRatio(geometry.size, contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .all)
    }
}

struct SignInNavigationHost: View {

    var body: some View {
        NavigationView {
            ZStack {
                SignInView().padding()
            }
            .background(
                GradientBackground(image: "groove")
            )
            .customNavTitle(text: "Gary Portal", colour: Color(UIColor.systemBackground))
        }
        
        .onAppear {
            UIApplication.shared.addTapGestureRecognizer()
        }
    }
}

struct SignUpHost: View {
    
    var body: some View {
        ZStack {
            GradientBackground()
                .blur(radius: 20, opaque: true)
            SignUpView().padding()
        }
        
        .navigationTitle("Sign Up")
    }
}

struct SignInView: View {
    @State var emailText: String = ""
    @State var passwordText: String = ""
    
    @State var showingAlert = false
    @State var alertContent: [String] = ["", ""]
    
    let emailCharacterSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_@-."
    let passCharacterSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-.&!%$£*"
    
    var body: some View {
        VStack {
            
            GPTextField(text: $emailText, isSystemImage: false, imageName: "user-glyph", isSecure: false, placeHolder: "Email", textContentType: .emailAddress, characterSet: emailCharacterSet, autoCapitalisation: .none, disableCorrection: true)
            Spacer().frame(height: 16)
            GPTextField(text: $passwordText, isSystemImage: false, imageName: "password-glyph", isSecure: true, placeHolder: "Password", characterSet: passCharacterSet, autoCapitalisation: .none, disableCorrection: true)
            
            Spacer().frame(height: 32)
            
            Button(action: { login() }, label: {
                Text("LOGIN")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(15)
            })
            .shadow(radius: 5)
           
            Spacer()
            Button(action: { self.requestReset() } ) {
                Text("Forgot Your Password? →")
                    .foregroundColor(.white)
                    .shadow(radius: 3)
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.black.opacity(0.3).cornerRadius(10))
            }
            

           
            
            HStack {
                Color(UIColor.secondarySystemBackground).frame(height: 1)
                Text("Or")
                    .bold()
                    .foregroundColor( Color(UIColor.secondarySystemBackground))
                Color(UIColor.secondarySystemBackground).frame(height: 1)
            }
            
            NavigationLink(destination: SignUpHost()) {
                Text("SIGN UP")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .shadow(radius: 3)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.pink)
                            .shadow(radius: 15)
                    )
            }
        }
        .toast(isPresenting: $showingAlert) {
            AlertToast(displayMode: .alert, type: .error(.red), title: alertContent[0], subTitle: alertContent[1])
        }
       
    }
    
    func login() {
        let authUser = AuthenticatingUser(authenticatorString: self.emailText, password: self.passwordText)
        AuthService.authenticate(user: authUser) { (user, error) in
            if let error = error {
                if error == APIError.invalidUserDetails {
                    self.alertContent = ["Error", "Email or password is incorrect"]
                    self.showingAlert = true
                } else if error == APIError.globalBan {
                    self.alertContent = ["Error", "You have been temporarily banned from Gary Portal. Please wait until your ban expires to be able to access the app again"]
                    self.showingAlert = true
                } else {
                    self.alertContent = ["Error", "There was a network issue signing you in"]
                    self.showingAlert = true
                }
                return
            }
            DispatchQueue.main.async {
                GaryPortal.shared.currentUser = user
                GaryPortal.shared.updateTokens(tokens: user?.userAuthTokens ?? UserAuthenticationTokens(authenticationToken: "", refreshToken: ""))
                GaryPortal.shared.loginUser(uuid: user?.userUUID ?? "", salt: user?.userAuthentication?.userPassSalt ?? "")
            }
        }
    }
    
    func requestReset() {
        let email = self.emailText.trim()
        if email.isEmptyOrWhitespace() {
            self.alertContent = ["Error", "Please enter the email address for your account to reset your password."]
            self.showingAlert = true
            return
        }
        
        AuthService.requestPassReset(email: email)
        self.alertContent = ["Password Reset", "If the email entered matches a valid user, you should receive an e-mail detailing how to reset your password shortly. Please be aware this can take up to 15 minutes to arrive and may arrive in your 'spam' or 'junk' inbox"]
        self.showingAlert = true
    }
}

struct SignUpView: View {
    
    @ObservedObject var viewModel = SignUpViewModel()
    @State var isShowingImagePicker = false
    @State var isShowingImageCropper = false
    @State var isShowingError = false
    @State var errorText = ""
    
    let emailCharacterSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_@-."
    let passCharacterSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-.&!%$£*"
    let nameCharacterSet = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    let usernameCharacterSet = "abcdefghijklmnopqrstuvwxyz0123456789_"
    
    var body: some View {
        if self.isShowingImageCropper {
            ImageCropper(image: self.$viewModel.chosenUIImage, visible: self.$isShowingImageCropper) { (finalImage) in
                self.viewModel.chosenUIImage = finalImage
                self.viewModel.chosenImage = Image(uiImage: finalImage)
                self.viewModel.hasChosenImage = true
            }
            .zIndex(10)
        }
        
        ScrollView {
            VStack {
                Text("We need some details to get you signed up!")
                    .font(Font.custom("Montserrat-SemiBold", size: 20))
                    .foregroundColor(Color(UIColor.secondarySystemBackground))
                
                Spacer().frame(height: 32)
                
                Group {
                    GPTextField(text: $viewModel.emailText, isSystemImage: true, imageName: "envelope", isSecure: false, placeHolder: "Your email address", characterSet: emailCharacterSet, autoCapitalisation: .none, disableCorrection: true)
                    GPTextField(text: $viewModel.usernameText, isSystemImage: true, imageName: "person.crop.circle", isSecure: false, placeHolder: "Your new username", characterLimit: 32, characterSet: usernameCharacterSet, autoCapitalisation: .none, disableCorrection: true)
                    GPTextField(text: $viewModel.fullNameText, isSystemImage: true, imageName: "person", isSecure: false, placeHolder: "Your full name", characterSet: nameCharacterSet)
                    GPTextField(text: $viewModel.passwordText, isSystemImage: true, imageName: "lock", isSecure: true, placeHolder: "Your new password", characterSet: passCharacterSet, autoCapitalisation: .none, disableCorrection: true)
                    GPTextField(text: $viewModel.confirmPasswordText, isSystemImage: true, imageName: "lock.fill", isSecure: true, placeHolder: "Confirm your password", characterSet: passCharacterSet, autoCapitalisation: .none, disableCorrection: true)
                    
                    DatePicker("Your date of birth:", selection: $viewModel.dateOfBirth, in: ...Calendar.current.date(byAdding: .year, value: -13, to: Date())!, displayedComponents: [.date])
                        .datePickerStyle(CompactDatePickerStyle())
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).foregroundColor(Color.clear)
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color(UIColor.secondarySystemBackground))
                                .shadow(radius: 10)
                        )
                    
                    HStack {
                        Text("Gender:")
                        Picker(selection: $viewModel.gender, label: Text("Your Gender:"), content: {
                            ForEach(0 ..< viewModel.genders.count) {
                                Text(viewModel.genders[$0])
                            }
                        })
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).foregroundColor(Color.clear)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(UIColor.secondarySystemBackground))
                            .shadow(radius: 10)
                    )
                    
                    self.viewModel.chosenImage
                        .if(viewModel.hasChosenImage) { $0.resizable() }
                        .if(viewModel.hasChosenImage) { $0.aspectRatio(contentMode: .fill) }
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.white, lineWidth: 2)
                        )
                        .onTapGesture {
                            self.isShowingImagePicker = true
                        }
                }
                
                Button(action: { signUp() }, label: {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(15)
                })
                .shadow(radius: 3)
                
                Spacer()
                                                
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            MediaPicker(limit: 1, filter: .images) { (picked, items) in
                self.isShowingImagePicker = false
                if picked {
                    if let items = items,
                       let item = items.items.first,
                       item.mediaType == .photo, let photo = item.photo {
                        self.viewModel.chosenUIImage = photo
                        self.isShowingImageCropper = true
                    }
                }
            }
        }
        .alert(isPresented: $isShowingError, content: {
            Alert(title: Text("Error"), message: Text(errorText), dismissButton: .default(Text("Ok")))
        })
        
    }
    
    func signUp() {
        
        let allFields = [viewModel.emailText, viewModel.usernameText, viewModel.fullNameText, viewModel.passwordText, viewModel.confirmPasswordText]
        
        if allFields.contains(where: { $0.isEmptyOrWhitespace() }) {
            self.errorText = GaryPortalConstants.Errors.SignupFieldsNotCompleted
            self.isShowingError = true
            return
        }
        
        if !viewModel.hasChosenImage {
            self.errorText = GaryPortalConstants.Errors.SignupNoImage
            self.isShowingError = true
            return
        }
        
        if viewModel.passwordText != viewModel.confirmPasswordText {
            self.errorText = GaryPortalConstants.Errors.PasswordsDoNotMatch
            self.isShowingError = true
            return
        }
        
        if !viewModel.emailText.isValidEmail {
            self.errorText = GaryPortalConstants.Errors.InvalidEmail
            self.isShowingError = true
            return
        }
        
        if !viewModel.passwordText.isValidPassword {
            self.errorText = GaryPortalConstants.Errors.InvalidPassword
            self.isShowingError = true
            return
        }
        
        let userRegistration = UserRegistration(userEmail: viewModel.emailText.trim(), userName: viewModel.usernameText.trim(), userFullName: viewModel.fullNameText.trim(), userPassword: viewModel.passwordText.trim(), userGender: viewModel.genders[viewModel.gender], userDOB: viewModel.dateOfBirth)
        
        AuthService.registerUser(userRegistration: userRegistration) { (newUser, error) in
            if let _ = newUser {
                let authUser = AuthenticatingUser(authenticatorString: viewModel.emailText, password: viewModel.passwordText)
                AuthService.authenticate(user: authUser) { (finalUser, error) in
                    if let finalUser = finalUser {
                       
                        GaryPortal.shared.currentUser = finalUser
                        GaryPortal.shared.updateTokens(tokens: finalUser.userAuthTokens ?? UserAuthenticationTokens(authenticationToken: "", refreshToken: ""))
                        
                        let group = DispatchGroup()
                        group.enter()
                        UserService.updateUserProfileImage(userUUID: finalUser.userUUID ?? "", newImage: viewModel.chosenUIImage) { (newURL) in
                            DispatchQueue.main.async {
                                GaryPortal.shared.currentUser?.userProfileImageUrl = newURL
                                group.leave()
                            }
                        }
                        
                        group.notify(queue: .main) {
                            GaryPortal.shared.loginUser(uuid: finalUser.userUUID ?? "", salt: finalUser.userAuthentication?.userPassSalt ?? "")
                        }
                    }
                }
            } else {
                if let _ = error {
                    self.errorText = "An error occurred signing you up"
                    self.isShowingError = true
                    return
                }
            }
        }
    }
}

class SignUpViewModel: ObservableObject {
    @Published var emailText = ""
    @Published var usernameText = ""
    @Published var fullNameText = ""
    @Published var passwordText = ""
    @Published var confirmPasswordText = ""
    @Published var dateOfBirth: Date = Date()
    @Published var gender = 0
    @Published var hasChosenImage = false
    @Published var chosenUIImage = UIImage(named: "upload-glyph") ?? UIImage()
    @Published var chosenImage = Image("upload-glyph")
    @State var genders = ["Female", "Male", "Other"]
    
    
}


struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInNavigationHost()
            .preferredColorScheme(.dark)
        SignUpHost()
            .environment(\.colorScheme, .dark)
        
    }
}
