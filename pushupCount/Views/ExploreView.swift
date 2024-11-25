import SwiftUI

struct ExploreView: View {
    @StateObject private var model = TimerViewModel()
    
    var body: some View {
        VStack {
            if model.state == .cancelled {
                timePickerControl
            } else {
                progressView
            }
            
            timerControls
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .foregroundColor(.black)
    }
    
    private var timePickerControl: some View {
        HStack {
            TimePickerView(title: "분", range: model.minutesRange, binding: $model.selectedMinutesAmount)
            TimePickerView(title: "초", range: model.secondsRange, binding: $model.selectedSecondsAmount)
        }
        .frame(width: 250, height: 255)
        .padding(.all, 20)
    }
    
    private var progressView: some View {
        ZStack {
            CircularProgressView(progress: $model.progress)
            
            VStack {
                Text(model.secondsToCompletion.asTimestamp)
                    .font(.largeTitle)
            }
        }
        .frame(width: 250, height: 255)
        .padding(.all, 20)
    }
    
    private var timerControls: some View {
        HStack(spacing: 8) { // 버튼 간격을 줄이기 위해 spacing을 추가했습니다.
            Button("취소") {
                model.state = .cancelled
            }
            .buttonStyle(CancelButtonStyle())
            
            Spacer()
            
            switch model.state {
            case .cancelled:
                Button("시작") {
                    model.state = .active
                }
                .buttonStyle(StartButtonStyle())
            case .paused:
                Button("재개") {
                    model.state = .resumed
                }
                .buttonStyle(PauseButtonStyle())
            case .active, .resumed:
                Button("일시정지") {
                    model.state = .paused
                }
                .buttonStyle(PauseButtonStyle())
            }
        }
        .padding(.horizontal, 80)
    }
    
    // MARK: - Supporting Views
    struct TimePickerView: View {
        private let pickerViewTitlePadding: CGFloat = 4.0
        
        let title: String
        let range: ClosedRange<Int>
        let binding: Binding<Int>
        
        var body: some View {
            HStack(spacing: -pickerViewTitlePadding) {
                Picker(title, selection: binding) {
                    ForEach(range, id: \.self) { timeIncrement in
                        HStack {
                            Spacer()
                            Text("\(timeIncrement)")
                                .foregroundColor(.black)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                .pickerStyle(InlinePickerStyle())
                .labelsHidden()
                
                Text(title)
                    .fontWeight(.bold)
            }
        }
    }
    
    struct CircularProgressView: View {
        @Binding var progress: Float
        
        var body: some View {
            ZStack {
                Circle()
                    .stroke(lineWidth: 8.0)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 8.0, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.orange)
                    .rotationEffect(Angle(degrees: 270))
            }
            .animation(.linear(duration: 1.0), value: progress)
        }
    }
    
    // MARK: - Button Styles
    struct StartButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(width: 70, height: 70)
                .foregroundColor(.green)
                .background(Color.green.opacity(0.3))
                .clipShape(Circle())
                .padding(.all, 3)
                .overlay(
                    Circle()
                        .stroke(Color.green.opacity(0.3), lineWidth: 2)
                )
        }
    }
    
    struct CancelButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(width: 70, height: 70)
                .foregroundColor(.red)
                .background(Color.red.opacity(0.3))
                .clipShape(Circle())
                .padding(.all, 3)
                .overlay(
                    Circle()
                        .stroke(Color.red.opacity(0.3), lineWidth: 2)
                )
        }
    }
    
    struct PauseButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(width: 70, height: 70)
                .foregroundColor(.orange)
                .background(Color.orange.opacity(0.3))
                .clipShape(Circle())
                .padding(.all, 3)
                .overlay(
                    Circle()
                        .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                )
        }
    }
    
    struct ExploreView_Previews: PreviewProvider {
        static var previews: some View {
            ExploreView()
        }
    }
    
}
