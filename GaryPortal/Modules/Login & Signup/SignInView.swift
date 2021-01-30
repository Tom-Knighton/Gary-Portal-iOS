//
//  SignInView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 14/01/2021.
//

import SwiftUI

let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)

struct GradientBackground: View {
    
    var body: some View {
        GeometryReader { geometry in
           Image("BackgroundGradient")
               .resizable()
               .aspectRatio(contentMode: .fill)
               .edgesIgnoringSafeArea(.all)
               .frame(width: geometry.size.width)
       }
    }
}

struct SignInNavigationHost: View {
    
    var body: some View {
        NavigationView {
            GradientBackground()
                .overlay(SignInView().padding())
                .navigationTitle("Gary Portal")
        }
    }
}

struct SignUpHost: View {
    
    var body: some View {
        GradientBackground()
            .overlay(SignUpView().padding())
            .navigationTitle("Sign Up")
    }
}

struct SignInView: View {
    @State var emailText: String = ""
    @State var passwordText: String = ""
    
    @State var showingAlert = false
    @State var alertMessage = ""
    
    let emailCharacterSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_@-."
    let passCharacterSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-.&!%$£*"
    
    var body: some View {
        VStack {
            
            GPTextField(text: $emailText, isSystemImage: false, imageName: "user-glyph", isSecure: false, placeHolder: "Email", textContentType: .emailAddress, characterSet: emailCharacterSet)
            
            GPTextField(text: $passwordText, isSystemImage: false, imageName: "password-glyph", isSecure: true, placeHolder: "Password", characterSet: passCharacterSet)
            
            Spacer()
           
            Text("Forgot Your Password? ->")
                .foregroundColor( Color(UIColor.secondarySystemBackground))

            Button(action: { login() }, label: {
                Text("LOGIN")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(15)
            })
            .shadow(radius: 15)
            
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(lineWidth: 3)
                            .shadow(radius: 15)
                    )
            }
        }
        .alert(isPresented: $showingAlert, content: {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
        })
       
    }
    
    func login() {
        let authUser = AuthenticatingUser(authenticatorString: self.emailText, password: self.passwordText)
        AuthService.authenticate(user: authUser) { (user, error) in
            if let error = error {
                if error == APIError.invalidUserDetails {
                    self.alertMessage = "Email or password is incorrect"
                    self.showingAlert = true
                    return
                }
                return
            }
            GaryPortal.shared.currentUser = user
            GaryPortal.shared.updateTokens(tokens: user?.userAuthTokens ?? UserAuthenticationTokens(authenticationToken: "", refreshToken: ""))
            GaryPortal.shared.loginUser(uuid: user?.userUUID ?? "")
        }
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
    let usernameCharacterSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"
    
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
                    GPTextField(text: $viewModel.emailText, isSystemImage: true, imageName: "envelope", isSecure: false, placeHolder: "Your email address", characterSet: emailCharacterSet)
                    GPTextField(text: $viewModel.emailText, isSystemImage: true, imageName: "person.crop.circle", isSecure: false, placeHolder: "Your new username", characterLimit: 32, characterSet: usernameCharacterSet)
                    GPTextField(text: $viewModel.emailText, isSystemImage: true, imageName: "person", isSecure: false, placeHolder: "Your full name", characterSet: nameCharacterSet)
                    GPTextField(text: $viewModel.emailText, isSystemImage: true, imageName: "lock", isSecure: false, placeHolder: "Your new password", characterSet: passCharacterSet)
                    GPTextField(text: $viewModel.emailText, isSystemImage: true, imageName: "lock.fill", isSecure: false, placeHolder: "Confirm your password", characterSet: passCharacterSet)
                    
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
        .sheet(isPresented: $isShowingImagePicker, onDismiss: loadImage) {
        ImagePicker(image: $viewModel.chosenUIImage)
        }
        .alert(isPresented: $isShowingError, content: {
            Alert(title: Text("Error"), message: Text(errorText), dismissButton: .default(Text("Ok")))
        })
        
    }
    
    func loadImage() {
        self.isShowingImageCropper = true
       
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
            if let _ = error {
                self.errorText = "An error occurred signing you up"
                self.isShowingError = true
                return
            }
            GaryPortal.shared.currentUser = newUser
            GaryPortal.shared.updateTokens(tokens: newUser?.userAuthTokens ?? UserAuthenticationTokens(authenticationToken: "", refreshToken: ""))
            GaryPortal.shared.loginUser(uuid: newUser?.userUUID ?? "")
            UserService.updateUserProfileImage(userUUID: newUser?.userUUID ?? "", newImage: viewModel.chosenUIImage) { (newURL) in
                GaryPortal.shared.currentUser?.userProfileImageUrl = newURL
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
        SignUpHost()
            .environment(\.colorScheme, .dark)
        
    }
}
