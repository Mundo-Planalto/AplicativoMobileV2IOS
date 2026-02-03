//
//  ChatAIScreen.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct ChatAIScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ChatIAViewModel()
    @State private var newMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundPrimary
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(.title2)
                        }

                        Spacer()

                        Text("Atendimento IA")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding()
                    .background(AppColors.cardBackground)

                    // Messages
                    ScrollView {
                        ScrollViewReader { scrollView in
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.messages, id: \.id) { message in
                                    ChatBubble(message: message)
                                }

                                if viewModel.isLoading {
                                    HStack {
                                        TypingIndicator()
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .id("typing")
                                }
                            }
                            .padding(.vertical)
                            .onChange(of: viewModel.messages.count) { _ in
                                withAnimation {
                                    if let lastMessageId = viewModel.messages.last?.id {
                                        scrollView.scrollTo(lastMessageId, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }

                    // Message Input
                    HStack(spacing: 12) {
                        TextField("Digite sua mensagem...", text: $newMessage)
                            .padding(12)
                            .background(AppColors.cardBackground)
                            .cornerRadius(20)
                            .foregroundColor(.white)

                        Button(action: {
                            Task {
                                await viewModel.sendMessage(newMessage)
                                newMessage = ""
                            }
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(AppColors.accentCyan)
                                .font(.title2)
                                .padding(8)
                        }
                        .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(AppColors.backgroundPrimary)
                }
            }
        }
        .alert("Erro", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            Text(viewModel.error ?? "")
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.content)
                    .padding(12)
                    .background(AppColors.accentCyan)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .frame(maxWidth: 280, alignment: .trailing)
            } else {
                Text(message.content)
                    .padding(12)
                    .background(AppColors.cardBackground)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .frame(maxWidth: 280, alignment: .leading)
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

struct TypingIndicator: View {
    @State private var showDots = false

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(AppColors.accentCyan.opacity(0.5))
                .frame(width: 8, height: 8)
            Circle()
                .fill(AppColors.accentCyan.opacity(0.5))
                .frame(width: 8, height: 8)
                .opacity(showDots ? 1 : 0.3)
            Circle()
                .fill(AppColors.accentCyan.opacity(0.5))
                .frame(width: 8, height: 8)
                .opacity(showDots ? 0.3 : 1)
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.6).repeatForever()) {
                showDots.toggle()
            }
        }
    }
}

#Preview {
    ChatAIScreen()
}
