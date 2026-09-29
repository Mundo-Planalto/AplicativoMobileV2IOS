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
    @State private var showHistory = false
    @State private var selectedHistorySessionId: UUID?

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

                        Button {
                            selectedHistorySessionId = nil
                            showHistory = true
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
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
                            .onChange(of: viewModel.messages.count) { _, _ in
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
                            .disabled(viewModel.isLoading)

                        Button(action: {
                            let messageToSend = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !messageToSend.isEmpty, !viewModel.isLoading else { return }
                            // Limpa o input imediatamente após enviar.
                            newMessage = ""
                            Task {
                                await viewModel.sendMessage(messageToSend)
                            }
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(AppColors.accentCyan)
                                .font(.title2)
                                .padding(8)
                        }
                        .disabled(viewModel.isLoading || newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
        .sheet(isPresented: $showHistory) {
            ChatHistorySheet(
                sessions: viewModel.allSessionsForHistory(),
                selectedSessionId: $selectedHistorySessionId,
                messagesProvider: { id in viewModel.loadSessionMessages(sessionId: id) }
            )
        }
    }
}

private struct ChatHistorySheet: View {
    let sessions: [ChatSession]
    @Binding var selectedSessionId: UUID?
    let messagesProvider: (UUID) -> [ChatMessage]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let baseView = NavigationView {
            Group {
                if let selected = selectedSessionId {
                    ChatHistoryDetail(messages: messagesProvider(selected))
                } else {
                    List {
                        ForEach(sessions) { session in
                            Button {
                                selectedSessionId = session.id
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(session.title)
                                        .font(.headline)
                                    Text("\(session.messages.count) mensagens")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Histórico")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
        if #available(iOS 16.0, *) {
            baseView
                .presentationDetents([.medium, .large])
        } else {
            baseView
        }
    }
}

private struct ChatHistoryDetail: View {
    let messages: [ChatMessage]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(messages, id: \.id) { message in
                    ChatBubble(message: message)
                }
            }
            .padding(.vertical)
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
