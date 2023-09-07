import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(\.dismiss) private var dismiss
    @GestureState private var isInteracting: Bool = false
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 0
    @State private var offset: CGSize = .zero
    @State private var lastStoredOffset: CGSize = .zero
    var circleMaskWidth: CGFloat = 0

    var drag: some Gesture {
        return DragGesture()
            .updating($isInteracting) { _, out, _ in
                out = true
            } .onChanged { value in
                let translation = value.translation
                offset = CGSize(
                    width: translation.width + lastStoredOffset.width,
                    height: translation.height + lastStoredOffset.height
                )
            }
        
    }

    var magnification: some Gesture {
        return MagnificationGesture()
            .updating($isInteracting) { _, out, _ in
                out = true
            }
            .onChanged { value in
                withAnimation {
                    let updatedScale = value + lastScale
                    scale = updatedScale < 1 ? 1 : updatedScale // limit scale
                }
            }
            .onEnded { value in
                withAnimation(.easeInOut(duration: 0.2)) {
                    if scale < 1 {
                        scale = 1
                        lastScale = 0
                    } else if scale > 2 {
                        scale = 2
                        lastScale = scale - 1
                    } else {
                        lastScale = scale - 1
                    }
                }
            }
    }

    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ZStack {
                    Image("piglet")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .accessibilityLabel("Selected Profile Image")
                        .overlay(content: {
                            GeometryReader { proxy in
                                let rect = proxy.frame(in: .named("CROPVIEW"))
                                Color.clear
                                    .onChange(of: isInteracting) { newValue in
                                        withAnimation(.easeInOut(duration: 0.4)) {
                                            if rect.minX > 20 {
                                                offset.width = offset.width - rect.minX + 20
                                                print("""
                                                if rect.minX > 20
                                                minX = \(rect.minX)
                                                offset width = \(offset.width)
                                                """)
                                            }
                                            if rect.minY > 20 {
                                                offset.height = offset.height - rect.minY + 20
                                                print("""
                                                if rect.minY > 20
                                                minY = \(rect.minY)
                                                offset height = \(offset.height)
                                                """)
                                            }
                                            if rect.maxX < proxy.size.width - 20 {
                                                offset.width = rect.minX - offset.width - 20
                                                print(
                                                """
                                                if rect.minX < proxy.size.width - 20
                                                maxX = \(rect.minX)
                                                width = \(proxy.size.width - 20)
                                                """)
                                            }
                                            if rect.maxY < proxy.size.height - 20 {
                                                offset.height = rect.minY - offset.height - 20
                                                print(
                                                """
                                                if rect.maxY < proxy.size.height - 20
                                                minY = \(rect.minY)
                                                height = \(proxy.size.height - 20)
                                                offset height = \(rect.minY - offset.height - 20)
                                                """)
                                            }
                                        }
                                        if !newValue {
                                            lastStoredOffset = offset
                                        }
                                    }
                            }
                        })
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(drag)
                        .gesture(magnification)
                        .onTapGesture(count: 2) {
                            resetOriginalImageState()
                        }
                        .coordinateSpace(name: "CROPVIEW")

                    Color.black.ignoresSafeArea()
                        .opacity(0.5)
                        .reverseMask {
                            Circle()
                                .padding(20)
                        }
            }
            .ignoresSafeArea()
            
            VStack() {
                Text("Move and Scale")
                    .foregroundColor(.white)
                    .padding(.top, 60)
                Spacer()
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button {
                        // need to convert view to image
                    } label: {
                        Text("Choose")
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            Text("width: \(offset.width)  height: \(offset.height)")
        }
    }
    
    func resetOriginalImageState() {
        scale = 1.0
        lastScale = 0
        offset = .zero
        lastStoredOffset = .zero
    }
}

extension View {
  func reverseMask<Mask: View>(
    alignment: Alignment = .center,
    @ViewBuilder _ mask: () -> Mask
  ) -> some View {
    self.mask {
      Rectangle()
        .overlay(alignment: alignment) {
          mask()
            .blendMode(.destinationOut)
        }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


