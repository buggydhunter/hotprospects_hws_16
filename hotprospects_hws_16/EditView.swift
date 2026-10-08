//
//  EditView.swift
//  hotprospects_hws_16
//
//  Created by Onur Ay on 08.10.26.
//

import SwiftUI

struct EditView: View {
    // Do i need the dismiss environment object here? -> it seems like i need this but alright it does work without me needing to make prospects @Binding -> is there a way to solve this where the prospect is a binding?? Or did i do the right thing
    @Environment(\.dismiss) var dismiss
    var prospect: Prospect
    @State var name: String
    @State var email: String
    
    var body: some View {
       
        VStack {
            TextField(prospect.name, text: $name)
                .font(.headline)
            
            TextField(prospect.emailAddress, text: $email)
                .font(.headline)
            
        }
        .toolbar {
            Button("Save") {
                save()
                dismiss()
            }
        }
        
    }
    
    
    
    func save() {
        prospect.name = name
        prospect.emailAddress = email
    }
}
