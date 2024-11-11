import SwiftUI

struct SettingsView: View {
    @AppStorage("randomRotation") private var randomRotation: Bool = true
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: CardGameViewModel
    @State private var isShowingAlert: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("札の表示")) {
                    Toggle("カードのランダム上下反転", isOn: $randomRotation)
                        .onChange(of: randomRotation) { _ in
                                            viewModel.loadImages()
                    }
                }
                Section(header: Text("ベストスコアリセット")) {
                    Button(action: {
                        self.isShowingAlert = true
                        
                    }) {
                        Text("ベストスコアをリセット")
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $isShowingAlert) {
                        Alert(
                            title: Text("記録リセット"),
                            message: Text("ベストスコアをリセットしますか？"),
                            primaryButton: .destructive(Text("リセット"), action: {
                                viewModel.resetBestScore()
                            }),
                            secondaryButton: .cancel(Text("キャンセル"))
                        )
                    }
                }
                Section(header: Text("バージョン")) {
                    Text("Version 1.1.1 (2024.11.10)")
                }
            }
            .navigationBarTitle("設定", displayMode: .inline)
            .navigationBarItems(trailing: Button("終了") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: CardGameViewModel())
    }
}
