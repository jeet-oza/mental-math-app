//
//  AuthService.swift
//  MentalMathApp
//
//  Identity layer: Sign in with Apple backed by Firebase Auth.
//
//  Exposes a small `AppUser` so views and other view models never depend on
//  Firebase types directly. The stable `uid` is what A3 (progress sync) and
//  A1 (leaderboard) key off of.
//

import Foundation
import Combine
import AuthenticationServices
import CryptoKit
import FirebaseAuth

/// A minimal, Firebase-free representation of the signed-in user.
struct AppUser: Equatable, Sendable {
    let uid: String
    let displayName: String
}

/// Observable authentication state for the app.
@MainActor
final class AuthService: ObservableObject {

    @Published private(set) var user: AppUser?
    @Published private(set) var errorMessage: String?

    var isSignedIn: Bool { user != nil }

    /// Raw nonce for the in-flight Sign in with Apple request.
    private var currentNonce: String?
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        // Reflect any already-signed-in user and keep in sync thereafter.
        user = Self.makeUser(from: Auth.auth().currentUser)
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor in
                self?.user = Self.makeUser(from: firebaseUser)
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Sign in with Apple

    /// Configures the Apple authorization request with a hashed nonce.
    /// Call from `SignInWithAppleButton`'s `onRequest`.
    func prepareRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = Self.randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(nonce)
        errorMessage = nil
    }

    /// Completes sign-in with the Apple authorization result.
    /// Call from `SignInWithAppleButton`'s `onCompletion`.
    func handleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case let .failure(error):
            // User cancellation is not an error worth surfacing.
            if (error as? ASAuthorizationError)?.code == .canceled { return }
            errorMessage = error.localizedDescription

        case let .success(authorization):
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let nonce = currentNonce,
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8)
            else {
                errorMessage = "Could not read Apple credentials."
                return
            }

            let firebaseCredential = OAuthProvider.appleCredential(
                withIDToken: idToken,
                rawNonce: nonce,
                fullName: credential.fullName
            )

            Task { await signIn(with: firebaseCredential, appleName: credential.fullName) }
        }
    }

    private func signIn(with credential: AuthCredential, appleName: PersonNameComponents?) async {
        do {
            let result = try await Auth.auth().signIn(with: credential)
            // Apple only returns the name on first sign-in; persist it if present.
            if let appleName, let formatted = Self.formattedName(appleName) {
                let change = result.user.createProfileChangeRequest()
                change.displayName = formatted
                try? await change.commitChanges()
                user = AppUser(uid: result.user.uid, displayName: formatted)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    #if DEBUG
    /// Debug-only guest sign-in via Firebase Anonymous Auth. Lets the app be
    /// exercised in the simulator where Sign in with Apple is unreliable.
    /// Requires the Anonymous provider to be enabled in the Firebase console.
    func signInAsGuest() async {
        do {
            _ = try await Auth.auth().signInAnonymously()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    #endif

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Helpers

    private static func makeUser(from firebaseUser: FirebaseAuth.User?) -> AppUser? {
        guard let firebaseUser else { return nil }
        let name = firebaseUser.displayName?.isEmpty == false
            ? firebaseUser.displayName!
            : "Player"
        return AppUser(uid: firebaseUser.uid, displayName: name)
    }

    private static func formattedName(_ components: PersonNameComponents) -> String? {
        let formatter = PersonNameComponentsFormatter()
        let name = formatter.string(from: components)
        return name.isEmpty ? nil : name
    }

    private static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }

    private static func randomNonceString(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            var random: UInt8 = 0
            let status = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if status == errSecSuccess, random < charset.count {
                result.append(charset[Int(random)])
                remaining -= 1
            }
        }
        return result
    }
}
