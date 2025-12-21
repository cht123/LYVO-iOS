import SwiftUI

struct CommitTextField: View {
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    
    init(
        _ placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) {
        self.placeholder = placeholder
        self._text = text
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(CommitTheme.Typography.body)
            .foregroundColor(CommitTheme.Colors.white)
            .padding(CommitTheme.Spacing.m)
            .commitCardBackground()
            .keyboardType(keyboardType)
    }
}
