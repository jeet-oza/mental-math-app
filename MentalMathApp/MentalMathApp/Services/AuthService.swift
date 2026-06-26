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
import FirebaseFirestore

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
            let result: AuthDataResult
            if let current = Auth.auth().currentUser, current.isAnonymous {
                // Upgrade the guest in place so progress/stats keep the same uid.
                result = try await linkOrSignIn(current: current, credential: credential)
            } else {
                result = try await Auth.auth().signIn(with: credential)
            }

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

    /// Links the Apple credential to the anonymous account (keeping its uid and
    /// data). If that Apple account already exists, signs in to it instead —
    /// the guest's local data is left behind in that case.
    private func linkOrSignIn(
        current: FirebaseAuth.User,
        credential: AuthCredential
    ) async throws -> AuthDataResult {
        do {
            return try await current.link(with: credential)
        } catch let error as NSError
            where error.code == AuthErrorCode.credentialAlreadyInUse.rawValue {
            let updated = error.userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? AuthCredential
            return try await Auth.auth().signIn(with: updated ?? credential)
        }
    }

    /// Guest sign-in via Firebase Anonymous Auth. Firebase persists the
    /// anonymous session in the keychain, so the same device keeps the same
    /// `uid` (and therefore the same derived guest name) across relaunches.
    /// Requires the Anonymous provider to be enabled in the Firebase console.
    func signInAsGuest() async {
        // Reuse any existing session rather than minting a new identity.
        if let existing = Auth.auth().currentUser {
            user = Self.makeUser(from: existing)
            return
        }
        do {
            _ = try await Auth.auth().signInAnonymously()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Permanently deletes the signed-in user's account and personal data
    /// (their `users/{uid}` document with progress and stats), then the Firebase
    /// Auth user. The auth-state listener returns the app to the sign-in screen.
    /// Required by the App Store for apps offering account creation.
    func deleteAccount() async {
        guard let firebaseUser = Auth.auth().currentUser else { return }
        let uid = firebaseUser.uid
        do {
            // Remove personal data first so nothing is orphaned.
            try? await Firestore.firestore().collection("users").document(uid).delete()
            try await firebaseUser.delete()
        } catch {
            // Re-auth may be required for non-anonymous accounts that signed in
            // a while ago; surface the reason so the user can sign in again.
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Helpers

    private static func makeUser(from firebaseUser: FirebaseAuth.User?) -> AppUser? {
        guard let firebaseUser else { return nil }
        if firebaseUser.isAnonymous {
            // Guests have no Apple name — derive a stable one from the uid.
            return AppUser(uid: firebaseUser.uid, displayName: guestName(for: firebaseUser.uid))
        }
        let name = firebaseUser.displayName?.isEmpty == false
            ? firebaseUser.displayName!
            : "Player"
        return AppUser(uid: firebaseUser.uid, displayName: name)
    }

    /// Deterministic, friendly guest name derived from the uid, so the same
    /// device (same uid) always shows the same name.
    private static func guestName(for uid: String) -> String {
        var rng = SeededRandomNumberGenerator(seed: uid)
        let adjectives = ["Swift", "Clever", "Brave", "Sharp", "Quick", "Cosmic", "Mighty", "Lucky"]
        let animals = ["Fox", "Otter", "Falcon", "Tiger", "Panda", "Hawk", "Lynx", "Whale"]
        let adjective = adjectives[Int.random(in: 0..<adjectives.count, using: &rng)]
        let animal = animals[Int.random(in: 0..<animals.count, using: &rng)]
        let number = Int.random(in: 10...99, using: &rng)
        return "\(adjective) \(animal) \(number)"
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
