import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = CardGameViewModel()
    @State private var showSettings = false
    @State private var showAbout = false
    
    var body: some View {
        NavigationView {
            CardGameView(viewModel: viewModel)
                .navigationBarTitle("百人一首札流し", displayMode: .large)
                .navigationBarHidden(viewModel.startTime != nil && viewModel.endTime == nil)
                .toolbar {
                    // Show settings button only when navigation bar is visible
                    if viewModel.startTime == nil || viewModel.endTime != nil {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                self.showAbout = true
                            }) {
                                Image(systemName: "questionmark.circle")
                                    .imageScale(.large)
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                self.showSettings = true
                            }) {
                                Image(systemName: "gearshape")
                                    .imageScale(.large)
                            }
                        }
                    }
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
    
    }
}
        


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

