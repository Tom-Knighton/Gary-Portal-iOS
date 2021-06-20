//
//  GPReportView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 16/06/2021.
//

import Foundation
import SwiftUI

struct GPReportView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var reportOptions: [ReportOption] = [
        ReportOption(reportName: "Illegal Content", reportDescription: "Child pornography, solicitations of minors, threats of school shootings or criminal activity."),
        ReportOption(reportName: "Violates Gary Portal Policy", reportDescription: "Content which violates a specific clause of the Gary Portal Policy."),
        ReportOption(reportName: "Harasssment", reportDescription: "Threats, stalking, bullying, sharing of personal information, impersonation etc."),
        ReportOption(reportName: "Spam or Phishing Links", reportDescription: "Fake, malicious or illegal links or attachments, including links to external locations designed to share such links or attachments."),
        ReportOption(reportName: "NSFW Content", reportDescription: "Unwanted pornography or other adult content, or such content in a public feed or chat."),
        ReportOption(reportName: "Breaks Gary Portal", reportDescription: "Content which interferes with or breaks the correct functions of Gary Portal. (Please note specific bug reports can be submitted from the Profile Page)")]
    @State private var selectedReportOption = ""
    
    private var ReportType: ReportType
    private var toReportId: String
    public enum ReportType {
       case Feed, FeedComment, Profile, ChatMessage
    }
    
    init(reportType: ReportType, toReportId: String) {
        self.toReportId = toReportId
        self.ReportType = reportType
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("What is it you're reporting?").bold().font(.headline), footer: Text("Reports are sent directly to administrators of Gary Portal - the user responsible for the content you are reporting can not see that you have made a report. Creating false reports may result in a suspension of reporting abilities or a temporary ban. Thanks for keeping things safe and sound!")) {
                    ForEach(self.reportOptions, id: \.reportName) { report in
                        HStack {
                            Image(systemName: self.selectedReportOption == report.reportName ? "checkmark.circle.fill" : "circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(self.selectedReportOption == report.reportName ? .green : .gray)
                                .animation(.spring())
                                .transition(.opacity)
                            VStack {
                                Text(report.reportName)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 8)
                                    .padding(.bottom, 1)
                                Text(report.reportDescription)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .font(.caption)
                                    .padding(.bottom, 8)
                            }
                        }
                        .onTapGesture {
                            if self.selectedReportOption == report.reportName {
                                self.selectedReportOption = ""
                            } else {
                                self.selectedReportOption = report.reportName
                            }
                        }
                    }
                }
                
                Button(action: { self.makeReport() }) {
                    Text("Report")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(self.selectedReportOption == "")
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Report")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                        Text("Close")
                    }
                }
            })
        }
    }
    
    func makeReport() {
        switch self.ReportType {
        case .Profile:
            UserService.reportUser(uuid: self.toReportId, reportedBy: GaryPortal.shared.currentUser?.userUUID ?? "", reason: self.selectedReportOption)
            GaryPortal.shared.showNotification(data: GPNotificationData(title: "Success", subtitle: "Your report was submitted", image: "checkmark.circle.fill", imageColor: .green, onTap: {}))
        case .ChatMessage:
            ChatService.reportMessage(self.toReportId, from: GaryPortal.shared.currentUser?.userUUID ?? "", for: self.selectedReportOption)
            GaryPortal.shared.showNotification(data: GPNotificationData(title: "Success", subtitle: "Your report was submitted", image: "checkmark.circle.fill", imageColor: .green, onTap: {}))
        case .Feed:
            FeedService.reportPost(Int(self.toReportId) ?? 0, from: GaryPortal.shared.currentUser?.userUUID ?? "", for: self.selectedReportOption)
            GaryPortal.shared.showNotification(data: GPNotificationData(title: "Success", subtitle: "Your report was submitted", image: "checkmark.circle.fill", imageColor: .green, onTap: {}))
        default:
            GaryPortal.shared.showNotification(data: GPNotificationData(title: "Error", subtitle: "An error occurred submitting the report", image: "xmark.octagon", imageColor: .red, onTap: {}))
        }
        
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct ReportOption {
    
    let reportName: String
    let reportDescription: String
}

struct GPReportViewPReview: PreviewProvider {
    static var previews: some View {
        GPReportView(reportType: .ChatMessage, toReportId: "")
    }
}
