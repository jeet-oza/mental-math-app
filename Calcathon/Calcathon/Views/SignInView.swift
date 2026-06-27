//
//  SignInView.swift
//  Calcathon
//
//  Wordament-style login/splash: the app's first screen. A big PLAY button
//  (guest) gets you in instantly; Sign in with Apple saves progress across
//  devices.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var auth: AuthService

    var body: some View {
        ZStack {
            BrandBackground()

            VStack(spacing: 24) {
                Spacer()

                // Hero: the app-icon logo (carries the name) + tagline
                BrandMark(size: 160)
                    .padding(.bottom, 12)

                Text("Learn the tricks. Race the Arena.")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)

                Spacer()

                if let error = auth.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(Color.brandAccent)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }

                // Primary CTA: Play (guest)
                Button {
                    Task { await auth.signInAsGuest() }
                } label: {
                    Text("PLAY")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundStyle(.white)
                        .background(RoundedRectangle(cornerRadius: 28).fill(.accentGradient))
                        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                }
                .padding(.horizontal, 40)

                // Secondary: Sign in with Apple (saves progress across devices)
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in auth.prepareRequest(request) },
                    onCompletion: { result in auth.handleCompletion(result) }
                )
                .signInWithAppleButtonStyle(.white)
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .padding(.horizontal, 40)

                Text("Sign in to save your progress across devices.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.bottom, 40)
            }
        }
    }

}
