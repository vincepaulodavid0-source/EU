import SwiftUI


struct StaffControlView: View {
    @State private var staff: [StaffAccount] = []
    @State private var showCreate = false
    @State private var isLoading = false
    @State private var errorText: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 10) {
                        if isLoading && staff.isEmpty {
                            ProgressView().padding(.top, 40)
                        } else if staff.isEmpty {
                            Text("No staff accounts yet.")
                                .font(.subheadline).foregroundColor(.secondary)
                                .padding(.top, 40)
                        }

                        ForEach(staff) { member in
                            HStack(spacing: 12) {
                                Text(member.code).font(.caption2).fontWeight(.bold)
                                    .frame(width: 34, height: 34)
                                    .background(Color(.systemGray5)).clipShape(Circle())
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(member.name).font(.subheadline).fontWeight(.semibold)
                                    Text(member.email).font(.caption2).foregroundColor(.secondary)
                                }
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { member.isActive },
                                    set: { setActive(member.id, $0) }
                                ))
                                .labelsHidden().tint(.brandRed)
                            }
                            .padding(12).background(Color(.systemBackground)).cornerRadius(10)
                            .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
                        }
                    }.padding()
                }

                Button { showCreate = true } label: {
                    Label("Add Employee", systemImage: "plus")
                        .fontWeight(.bold).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding()
                        .background(Color.brandRed).cornerRadius(8)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Staff Control")
            .navigationBarTitleDisplayMode(.inline)
            .task { await reload() }
            .sheet(isPresented: $showCreate) {
                CreateAccountView { Task { await reload() } }
            }
            .alert("Couldn't update staff",
                   isPresented: Binding(get: { errorText != nil },
                                        set: { if !$0 { errorText = nil } })) {
                Button("OK", role: .cancel) {}
            } message: { Text(errorText ?? "") }
        }
    }

    @MainActor
    private func reload() async {
        isLoading = true
        do { staff = try await StaffService.shared.loadStaff() }
        catch { errorText = AuthService.message(for: error) }
        isLoading = false
    }

    @MainActor
    private func setActive(_ id: String, _ value: Bool) {
        update(id, value)                       // instant UI feedback
        Task {
            do { try await StaffService.shared.setActive(uid: id, value) }
            catch {
                update(id, !value)              // revert if the write failed
                errorText = AuthService.message(for: error)
            }
        }
    }

    private func update(_ id: String, _ value: Bool) {
        if let i = staff.firstIndex(where: { $0.id == id }) { staff[i].isActive = value }
    }
}

struct CreateAccountView: View {
    var onCreated: () -> Void
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isSaving = false
    @State private var errorText: String?

    var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
        && email.contains("@")
        && password.count >= 6
        && !isSaving
    }

    private func field<Content: View>(_ label: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.caption2).foregroundColor(.secondary)
            content()
                .padding().background(Color(.systemBackground)).cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
        }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                field("NAME / STATION") {
                    TextField("e.g. Guard Station 1 (Gate 1)", text: $name)
                }
                field("EMAIL (used to log in)") {
                    TextField("station1@school.edu", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                field("PASSWORD (min 6 characters)") {
                    SecureField("", text: $password)
                }

                if let errorText {
                    Text(errorText).font(.caption).foregroundColor(.red)
                }

                Button(action: create) {
                    ZStack {
                        if isSaving { ProgressView().tint(.white) }
                        else { Text("Create Account").fontWeight(.bold) }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding()
                    .background(canCreate ? Color.brandRed : Color.gray).cornerRadius(8)
                }
                .disabled(!canCreate)
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left").foregroundColor(.brandRed)
                    }
                }
            }
        }
    }

    @MainActor
    private func create() {
        isSaving = true
        errorText = nil
        Task {
            do {
                try await StaffService.shared.createStaff(
                    name: name.trimmingCharacters(in: .whitespaces),
                    email: email.trimmingCharacters(in: .whitespaces).lowercased(),
                    password: password
                )
                onCreated()
                dismiss()
            } catch {
                errorText = AuthService.message(for: error)
            }
            isSaving = false
        }
    }
}
