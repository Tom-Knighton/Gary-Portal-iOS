//
//  ProfilePointsView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 31/03/2021.
//

import SwiftUI

struct ProfileStatisticsView: View {
    
    @ObservedObject var datasource: ProfileViewDataSource
    
    var body: some View {
        VStack {
            Spacer().frame(width: 16)
            Group {
                HStack {
                    Spacer()
                    VStack {
                        Text("\(self.datasource.user?.userPoints?.amigoPoints ?? 0)")
                            .font(Font.custom("Montserrat-SemiBold", size: 26))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .minimumScaleFactor(0.8)
                        Text("Amigo Points")
                            .font(Font.custom("Montserrat-Regular", size: 22))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .minimumScaleFactor(0.8)
                    }
                    
                    Spacer()
                    VStack {
                        Text("\(self.datasource.user?.userPoints?.positivityPoints ?? 0)")
                            .font(Font.custom("Montserrat-SemiBold", size: 26))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .minimumScaleFactor(0.8)
                        Text("Positive Points")
                            .font(Font.custom("Montserrat-Regular", size: 22))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .minimumScaleFactor(0.8)
                    }
                    Spacer()
                }
                Spacer().frame(height: 16)
                HStack {
                    Spacer()
                    VStack {
                        Text("\(self.datasource.user?.userPoints?.prayers ?? 0)")
                            .font(Font.custom("Montserrat-SemiBold", size: 26))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .minimumScaleFactor(0.8)
                        Text("Prayers")
                            .font(Font.custom("Montserrat-Regular", size: 22))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .minimumScaleFactor(0.8)
                    }
                    Spacer()
                    VStack {
                        Text("\(self.datasource.user?.userPoints?.meaningfulPrayers ?? 0)")
                            .font(Font.custom("Montserrat-SemiBold", size: 26))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .minimumScaleFactor(0.8)
                        Text("Meaningful")
                            .font(Font.custom("Montserrat-Regular", size: 22))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .minimumScaleFactor(0.8)
                    }
                    Spacer()
                }
            }
           
            Divider().padding(.horizontal)
            
            Group {
                Group {
                    Text("Amigo Rank:")
                        .font(Font.custom("Montserrat-Regular", size: 22))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                    Text(self.datasource.user?.userRanks?.amigoRank?.rankName ?? "")
                        .font(Font.custom("Montserrat-SemiBold", size: 26))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                        .padding(.top, 0)
                }
                                    
                Spacer().frame(height: 8)
                Group {
                    Text("Positivity Rank:")
                        .font(Font.custom("Montserrat-Regular", size: 22))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                    Text(self.datasource.user?.userRanks?.positivityRank?.rankName ?? "")
                        .font(Font.custom("Montserrat-SemiBold", size: 26))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                        .padding(.top, 0)
                }
                Spacer().frame(height: 8)
                Group {
                    Text("Team:")
                        .font(Font.custom("Montserrat-Regular", size: 22))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                    Text(self.datasource.user?.userTeam?.team?.teamName ?? "")
                        .font(Font.custom("Montserrat-SemiBold", size: 26))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                        .padding(.top, 0)
                }
            }
            
            Spacer().frame(width: 16)

            
        }
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(radius: 15)
        
    }
}

