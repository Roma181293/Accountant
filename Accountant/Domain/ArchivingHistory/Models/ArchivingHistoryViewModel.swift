//
//  ArchivingHistoryViewModel.swift
//  Accountant
//
//  Created by Roman Topchii on 04.07.2022.
//

import Foundation

struct ArchivingHistoryViewModel {

    let id: UUID
    let date: Date
    let status: ArchivingHistory.Status
    let comment: String?
    let initiarot: Bool

    init(archivingHistory: ArchivingHistory) {
        self.id = archivingHistory.id
        self.date = archivingHistory.date
        self.status = archivingHistory.status
        self.comment = archivingHistory.comment
        self.initiarot = archivingHistory.createdByUser
    }
}
