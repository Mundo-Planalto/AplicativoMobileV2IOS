//
//  RegisterView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct RegisterView: View {
    var body: some View {
        ZStack {
            AppColors.backgroundPrimary
                .ignoresSafeArea()
            
            VStack {
                Text("Primeiro Acesso")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Text("Tela de cadastro em desenvolvimento")
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    RegisterView()
}
