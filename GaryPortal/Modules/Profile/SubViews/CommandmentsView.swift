//
//  CommandmentsView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 29/03/2021.
//

import Foundation
import SwiftUI
import Introspect

class CommandmentsDataSource: ObservableObject {
    
    @Published var commandments: [Commandment]?
    
    func loadCommandments() {
        AppService.GetCommandments { (results) in
            DispatchQueue.main.async {
                self.commandments = results ?? []
            }
        }
    }
}

struct CommandmentsView: View {
    
    @ObservedObject var datasource = CommandmentsDataSource()
    
    var body: some View {
        ZStack {
            GradientBackground()
            ScrollView {
                Spacer().frame(height: 16)
                HStack {
                    Spacer().frame(width: 16)
                    Text(self.datasource.commandments?.isEmpty == true ? "The Commandments" : "The \(self.datasource.commandments?.count ?? 10) Commandments")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color(UIColor.systemBackground))
                    Spacer()
                }
                ForEach(self.datasource.commandments ?? [], id: \.commandmentId) { commandment in
                    CommandmentCard(commandment: commandment)
                        .padding()
                }
                Spacer()
            }
        }
        .onAppear {
            self.datasource.loadCommandments()
        }

        
    }
}

struct CommandmentCard: View {
    
    @State var commandment: Commandment
    var body: some View {
        VStack {
            HStack {
                Spacer().frame(width: 8)
                Text(commandment.commandmentName ?? "")
                    .font(.custom("Montserrat-SemiBold", size: 18))
                    .multilineTextAlignment(.center)
                Spacer().frame(width: 8)
            }
            
            if let desc = commandment.commandmentDescription {
                HStack {
                    Text(desc)
                        .font(.custom("Montserrat-Regular", size: 16))
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                }
            }
            
            Spacer().frame(height: 8)
        }
        .padding()
        .background(Color("Section"))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
