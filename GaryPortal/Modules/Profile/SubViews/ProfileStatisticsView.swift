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
        
        let user = self.datasource.user
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 16) {
                ProfileStatisticCard(statisticName: "Amigo\nPoints", statistic: String(describing: user?.userPoints?.amigoPoints ?? 0))
                ProfileStatisticCard(statisticName: "Positive\nPoints", statistic: String(describing: user?.userPoints?.positivityPoints ?? 0))
                ProfileStatisticCard(statisticName: "Amigo Rank", statistic: user?.userRanks?.amigoRank?.rankName ?? "")
                ProfileStatisticCard(statisticName: "Positive Rank", statistic: user?.userRanks?.positivityRank?.rankName ?? "")
            }
        }
    }
}

struct ProfileStatisticCard: View {
    
    var statisticName: String
    var statistic: String
    
    var body: some View {
        VStack {
            let statAsNum = Int(statistic) ?? -1
            let title: Text = statAsNum == -1 ? Text(statistic) : Text("\(statAsNum)")
            
            title
                .font(Font.custom("Montserrat-SemiBold", size: 26))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)

            Text(statisticName)
                .font(Font.custom("Montserrat-Regular", size: 22))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}
