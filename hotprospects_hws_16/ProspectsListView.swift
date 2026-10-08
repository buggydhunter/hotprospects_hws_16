import SwiftData
import SwiftUI
import UserNotifications

enum SortType {
    case name
    case recent
}

struct ProspectsListView: View {
    @Environment(\.modelContext) var modelContext
    @Query var prospects: [Prospect]
    @Binding var selectedProspects: Set<Prospect>
    
    let filter: ProspectsView.FilterType
    
    init(filter: ProspectsView.FilterType, sort: SortType, selectedProspects: Binding<Set<Prospect>>) {
        self.filter = filter
        self._selectedProspects = selectedProspects
        
        // 1. Configure the filter
        let showContactedOnly = filter == .contacted
        let predicate = filter == .none ? nil : #Predicate<Prospect> { $0.isContacted == showContactedOnly}
        
        // 2. Configure the sort
        let sortDescriptor: SortDescriptor<Prospect>
        if sort == .name {
            sortDescriptor = SortDescriptor(\Prospect.name)
        } else {
            sortDescriptor = SortDescriptor(\Prospect.dateAdded, order: .reverse)
        }
        
        // 3. Apply to the Query
        if let predicate {
            _prospects = Query(filter: predicate, sort: [sortDescriptor])
        } else {
            _prospects = Query(sort: [sortDescriptor])
        }
    }
    
    var body: some View {
        List(prospects, selection: $selectedProspects) { prospect in
            if filter == .none {
                NavigationLink(destination: EditView(prospect: prospect, name: prospect.name, email: prospect.emailAddress)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            
                            Text(prospect.emailAddress)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: prospect.isContacted ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(prospect.isContacted ? .green : .red)
                            .padding(.horizontal, 20)
                    }
                    .swipeActions {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            modelContext.delete(prospect)
                        }
                        
                        if prospect.isContacted {
                            Button("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark") {
                                prospect.isContacted.toggle()
                            }
                            .tint(.blue)
                        } else {
                            Button("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkMark") {
                                prospect.isContacted.toggle()
                            }
                            .tint(.green)
                            
                            Button("Remind Me", systemImage: "bell") {
                                addNotification(for: prospect)
                            }
                        }
                    }
                }
                .tag(prospect)
            } else {
                NavigationLink(destination: EditView(prospect: prospect, name: prospect.name, email: prospect.emailAddress)) {
                    VStack(alignment: .leading) {
                        Text(prospect.name)
                            .font(.headline)
                        
                        Text(prospect.emailAddress)
                            .foregroundStyle(.secondary)
                    }
                    .swipeActions {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            modelContext.delete(prospect)
                        }
                        
                        if prospect.isContacted {
                            Button("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark") {
                                prospect.isContacted.toggle()
                            }
                            .tint(.blue)
                        } else {
                            Button("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkMark") {
                                prospect.isContacted.toggle()
                            }
                            .tint(.green)
                            
                            Button("Remind Me", systemImage: "bell") {
                                addNotification(for: prospect)
                            }
                        }
                    }
                }
                .tag(prospect)
            }
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else if let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
