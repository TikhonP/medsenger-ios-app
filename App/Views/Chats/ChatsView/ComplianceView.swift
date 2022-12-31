//
//  ComplianceView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 20.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

@MainActor
final class ComplianceViewModel: ObservableObject {
    let contracts: Array<Contract>
    
    init(contracts: Array<Contract>) {
        self.contracts = contracts
    }
    
    let progressLevelEmojies = [
        0: "⛳️",
        1: "🎯",
        2: "🎳",
        100: "💯"
    ]
    
    let levelEmojies = [
        0: "🤨",
        1: "☹️",
        2: "🙁",
        3: "😊",
        4: "😊",
        5: "😄",
        6: "🥳"
    ]
    
    var tasksTotalToday: Int {
        var total = 0
        for contract in contracts {
            for agentTask in contract.agentTasksArray {
                total += Int(agentTask.targetNumber)
            }
        }
        return total
    }
    
    var tasksCompletedToday: Int {
        var total = 0
        for contract in contracts {
            for agentTask in contract.agentTasksArray {
                total += Int(agentTask.number)
            }
        }
        return total
    }
    
    var tasksTotalThisWeek: Int {
        var total = 0
        for contract in contracts {
            total += Int(contract.complianceAvailible)
        }
        return total
    }
    
    var tasksCompletedThisWeek: Int {
        var total = 0
        for contract in contracts {
            total += Int(contract.complianceDone)
        }
        return total
    }
    
    var percentage: Int? {
        tasksTotalThisWeek == 0 ? nil : tasksCompletedThisWeek / tasksTotalThisWeek * 100
    }
    
    var level: Int? {
        guard let percentage = percentage else {
            return nil
        }
        if percentage == 0 {
            return percentage
        }
        return min(1 + Int(percentage / 20), 6)
    }
    
    var progress: Int {
        (tasksTotalToday == 0) ? 0 : 100 * tasksCompletedToday / tasksTotalToday
    }
    
    var progressLevel: Int? {
        (tasksCompletedToday == 0) ? nil : (tasksToDoToday == 0) ? 100 : tasksCompletedToday % 3
    }
    
    var tasksToDoToday: Int {
        tasksTotalToday - tasksCompletedToday
    }
    
    var emojiPrefix: String {
        if let progressLevel = progressLevel {
            return progressLevelEmojies[progressLevel, default: ""]
        } else if let level = level {
            return levelEmojies[level, default: ""]
        } else {
            return ""
        }
    }
    
    var shadowColor: Color {
        if let progressLevel = progressLevel {
            return progressLevel == 100 ? .systemBackground : .blue
        } else {
            if let level = level {
                return level <= 1 ? .pink : level <= 4 ? .systemBackground : .blue
            } else {
                return .systemBackground
            }
        }
    }
}

struct ComplianceView: View {
    @ObservedObject private var user: User
    @StateObject private var complianceViewModel: ComplianceViewModel
    
    init(contracts: Array<Contract>, user: User) {
        self.user = user
        _complianceViewModel = StateObject(wrappedValue: ComplianceViewModel(contracts: contracts))
    }
    
    var body: some View {
        if complianceViewModel.tasksTotalToday != 0 || complianceViewModel.tasksTotalThisWeek != 0 {
            Section {
                VStack(alignment: .leading) {
                    Text("ComplianceView.complianceHeader", comment: "Compliance")
                        .font(.headline)
                    if (complianceViewModel.tasksCompletedToday != 0), (complianceViewModel.tasksToDoToday == 0) {
                        Text("\(complianceViewModel.emojiPrefix) ComplianceView.Amazing \(user.firstName)!", comment: "%@ Amazing, %@!")
                    } else if (complianceViewModel.tasksCompletedToday != 0), (complianceViewModel.tasksToDoToday != 0) {
                        Text("\(complianceViewModel.emojiPrefix) ComplianceView.GoOn \(user.firstName)!", comment: "%@ Go on, %@!")
                    } else if complianceViewModel.level ?? 100 <= 2 {
                        Text("\(complianceViewModel.emojiPrefix) ComplianceView.Subpress \(user.firstName)!", comment: "%@ Subpress, %@!")
                    } else if complianceViewModel.level ?? 100 <= 4 {
                        Text("\(complianceViewModel.emojiPrefix) ComplianceView.GoodJob, \(user.firstName)!", comment: "%@ Good job, %@!")
                    } else if complianceViewModel.level ?? 100 <= 6 {
                        Text("\(complianceViewModel.emojiPrefix) ComplianceView.Wow, \(user.firstName)!", comment: "%@ Wow, %@!")
                    } else {
                        Text("\(complianceViewModel.emojiPrefix) ComplianceView.Great, \(user.firstName)!", comment: "%@ Great, %@!")
                    }
                    
                    if (complianceViewModel.tasksCompletedToday == 0), (complianceViewModel.tasksToDoToday == 0) {
                        Text("ComplianceView.youDontHaveAnyAppointmentsToday", comment: "You don't have any appointments from the doctor today.")
                    } else if (complianceViewModel.tasksCompletedToday == 0), (complianceViewModel.tasksToDoToday != 0) {
                        Text("ComplianceView.tasksForToday \(complianceViewModel.tasksToDoToday)", comment: "Tasks for today: %lld")
                    } else if (complianceViewModel.tasksCompletedToday != 0), (complianceViewModel.tasksToDoToday != 0) {
                        Text("ComplianceView.todayYouDidTasks \(complianceViewModel.tasksCompletedToday)/\(complianceViewModel.tasksTotalToday)", comment: "Сегодня Вы выполнили %lld/%lld заданий")
                    } else if (complianceViewModel.tasksCompletedToday != 0), (complianceViewModel.tasksToDoToday == 0) {
                        Text("ComplianceView.allAssignmentsToday", comment: "All assignments for today completed!")
                    }
                    
                    ProgressView(value: Float(complianceViewModel.progress) / 100)
                }
                .shadow(color: complianceViewModel.shadowColor, radius: 30)
            }
        }
    }
}

#if DEBUG
struct ComplianceView_Previews: PreviewProvider {
    static var previews: some View {
        ComplianceView(contracts: [], user: UserPreview.userForChatsViewPreview)
    }
}
#endif
