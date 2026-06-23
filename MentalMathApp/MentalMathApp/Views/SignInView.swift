//
//  SignInView.swift
//  MentalMathApp
//
//  Sign-in gate shown when no user is authenticated.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var auth: AuthService
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.brandPrimary, Color.brandSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                Image(systemName: "function")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(.white)

                VStack(spacing: 8) {
                    Text("Mental Math")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                    Text("Learn the tricks. Race the Arena.\nSign in to save your progress.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }

                Spacer()

                if let error = auth.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }

                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in auth.prepareRequest(request) },
                    onCompletion: { result in auth.handleCompletion(result) }
                )
                .signInWithAppleButtonStyle(.white)
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}
