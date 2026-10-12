#if DEBUG
    import DesignSystem
    import SwiftUI
    import UIKit

    /// Stand-in exercise photos for demo data: the exercise's symbol on its color.
    enum DemoPhoto {
        /// Side of the square image, in pixels.
        private static let side: CGFloat = 1200

        /// A square JPEG, like a downscaled library photo; `nil` if it cannot be rendered.
        static func jpeg(symbol: String, tint: RoutineTint) -> Data? {
            let renderer = ImageRenderer(content: Picture(symbol: symbol, tint: tint, side: side))
            renderer.scale = 1
            return renderer.uiImage?.jpegData(compressionQuality: 0.8)
        }

        private struct Picture: View {
            let symbol: String
            let tint: RoutineTint
            let side: CGFloat

            var body: some View {
                Image(systemName: symbol)
                    .resizable()
                    .scaledToFit()
                    .padding(side / 5)
                    .foregroundStyle(Palette.onAccent)
                    .frame(width: side, height: side)
                    .background(tint.token)
            }
        }
    }
#endif
