import SwiftUI


struct NoteDetail: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(Theme.display(34))
                .foregroundStyle(Theme.textStrong)
            
            Text("4 open · 2 done · edited 2m ago")
                .font(Theme.ui(13))
                .foregroundStyle(Theme.textFaint)
                .padding(.top, 6)
            
            Divider()
                .padding(.top, 16)
            
            GlideTextView(text: $text)
                .frame(maxWidth: 680, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
            
            
            HStack{
                Text("\(wordCount) words")
                    .font(Theme.ui(12))
                    .foregroundStyle(Theme.textFaint)
                Spacer()
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 28)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.surfaceCard)
    }
    
    private var wordCount: Int {
        text.split(whereSeparator: { $0.isWhitespace }).count
    }

}
