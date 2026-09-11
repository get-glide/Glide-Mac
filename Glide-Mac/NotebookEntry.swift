//
//  NotebookEntry.swift
//  Glide-Mac
//
//  Created by Aarnav on 9/8/26.
//

import Foundation

struct NotebookEntry: Identifiable {
    let id: String
    let name: String
    let open: Int
    let done: Int
}

protocol NotebookSummaryProviding {
    func summaries() -> [NotebookEntry]
}

struct MockNotebookSummaries: NotebookSummaryProviding {
    func summaries() -> [NotebookEntry] {
        [
            NotebookEntry(id: "CS 2110", name: "CS 2110", open: 6, done: 2),
            NotebookEntry(id: "Physics", name: "Physics", open: 3, done: 1),
            NotebookEntry(id: "Chem", name: "Chem", open: 3, done: 3),
            NotebookEntry(id: "Projects", name: "Projects", open: 5, done: 5),
            NotebookEntry(id: "Inbox", name: "Inbox", open: 4, done: 0),
        ]
    }
}
