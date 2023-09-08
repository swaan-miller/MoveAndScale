import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(\.dismiss) private var dismiss
    @GestureState private var isInteracting: Bool = false
    @ObservedObject private var viewModel = ContentViewModel()

    var drag: some Gesture {
        return DragGesture()
            .updating($isInteracting) { _, out, _ in
                out = true
            } .onChanged { value in
                /// TODO: Move this to the view model
                let translation = value.translation
                viewModel.offset = CGSize(
                    width: translation.width + viewModel.lastStoredOffset.width,
                    height: translation.height + viewModel.lastStoredOffset.height
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
                    let updatedScale = value + viewModel.lastScale
                    viewModel.scale = updatedScale < 1 ? 1 : updatedScale // limit scale
                }
            }
            .onEnded { value in
                withAnimation(.easeInOut(duration: 0.2)) {
                    /// TODO: Move this to the view model
                    if viewModel.scale < 1 {
                        viewModel.scale = 1
                        viewModel.lastScale = 0
                    } else if viewModel.scale > 2 {
                        viewModel.scale = 2
                        viewModel.lastScale = viewModel.scale - 1
                    } else {
                        viewModel.lastScale = viewModel.scale - 1
                    }
                }
            }
    }

    
    var body: some View {
        
            ZStack {
                Color.black.ignoresSafeArea()

                ZStack {
                    imageView
                    Circle()
                        .foregroundColor(.clear)
                        .overlay {
                            GeometryReader { proxy in
                                updateCircleRect(using: proxy)
                            }
                        }
                        .padding(20)
                    Color.black.ignoresSafeArea()
                        .opacity(0.5)
                        .reverseMask {
                            Circle()
                                .padding(20)
                        }
                }
                .coordinateSpace(name: "CONTAINER")
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
        }
    }

    func updateCircleRect(using proxy: GeometryProxy) -> some View {
        let rect = proxy.frame(in: .named("CONTAINER"))
        viewModel.circleRect = rect
        return Color.clear
    }

    var imageView: some View {
        Image("swaan_cup")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .accessibilityLabel("Selected Profile Image")
            .overlay(content: {
                GeometryReader { proxy in
                    let rect = proxy.frame(in: .named("CONTAINER"))
                    let _ = print("Image rect: \(rect) circle rect: \(viewModel.circleRect)")
                    Color.clear
                        .onChange(of: isInteracting) { isInteracting in
                            viewModel.interactionDidChange(isInteracting: isInteracting, imageRect: rect)
                        }
                }
            })
            .scaleEffect(viewModel.scale)
            .offset(viewModel.offset)
            .gesture(drag)
            .gesture(magnification)
            .onTapGesture(count: 2) {
                viewModel.resetOriginalImageState()
            }
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


