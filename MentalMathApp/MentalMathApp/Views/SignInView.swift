//
//  SignInView.swift
//  MentalMathApp
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

                // Hero: a mini board motif + title
                boardMotif
                    .padding(.bottom, 8)

                VStack(spacing: 8) {
                    Text("Mental Math")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Learn the tricks. Race the Arena.")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                }

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

    /// A small 2x2 board of orange tiles echoing the Grid Arena.
    private var boardMotif: some View {
        let values = ["f", "(", "x", ")"]
        return VStack(spacing: 8) {
            ForEach(0..<2, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(0..<2, id: \.self) { col in
                        Text(values[row * 2 + col])
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 64, height: 64)
                            .background(RoundedRectangle(cornerRadius: 12).fill(.accentGradient))
                            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                    }
                }
            }
        }
    }
}
