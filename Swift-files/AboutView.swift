import SwiftUI



struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView{
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("プレイ方法")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    Text("""
                        **ようこそ、札流しへ！**
                        
                        <目的>
                        このゲームの目標は百人一首の取り札全てをできるだけ早くスワイプするタイムアタックゲームです。
                        
                        <プレイ方法>
                        - **札をスワイプ**:
                            実際のかるた札とおなじように、札をすきな方向にスワイプすることで次の札に進めます。
                        
                        - **ランダム上下反転**: 
                            設定でこれを有効、無効にすることで、ゲームをよりチャレンジングにすることができます。
                        
                        - **タイマー**: 
                            タイマーはあなたが１００枚のふだ流しにかかる時間を表示します。
                        
                        - **ベストスコア**: 
                            あなたのベストスコアは記録され、ホーム画面に表示されます。
                        
                        ***楽しんでプレイしてみてください!!***
                        """)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding(.all, 20)
                    
                    // Credits
                    Text("デベロッパーとクレジット")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                    
                    Text("""
                    かるた取り札画像:
                    http://100poem.web.fc2.com/
                    
                    開発者： **三森颯太, 大戸暢丈**, 2024.
                                        
                    <<連絡先と公式HP>>
                    - **メール**: sota.mitsumori@gmail.com
                    - **ホームページ**: https://sota-mitsumori.github.io/Karuta-Fudanagashi/
                    """)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .padding(.all, 20)
                    
                    .navigationBarTitle("概要", displayMode: .inline)
                    .navigationBarItems(trailing: Button("終了") {
                        presentationMode.wrappedValue.dismiss()
                        })
                    
                }
            }
        }
    }
    
}
struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

