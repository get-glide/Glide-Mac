import SwiftUI

struct NoteDetail: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.largeTitle.bold())
                .foregroundStyle(Theme.textStrong)
            
            Text("4 open · 2 done · edited 2m ago")
                .font(.system(size: 13))
                .foregroundStyle(Theme.textFaint)
                .padding(.top, 6)
            
            Divider()
                .padding(.top, 16)
            
            GlideTextView(text: $text)
                .frame(maxWidth: 680, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.surfaceCard)
    }
}
