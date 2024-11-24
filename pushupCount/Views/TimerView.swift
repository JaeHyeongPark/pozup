import Foundation

class TimerViewModel: ObservableObject {
    enum TimerState {
        case active
        case paused
        case resumed
        case cancelled
    }
    
    @Published var selectedMinutesAmount = 0
    @Published var selectedSecondsAmount = 0
    @Published var state: TimerState = .cancelled {
        didSet {
            switch state {
            case .cancelled:
                timer.invalidate()
                secondsToCompletion = 0
                progress = 0
                
            case .active:
                startTimer()
                secondsToCompletion = totalTimeForCurrentSelection
                progress = 1.0
                updateCompletionDate()
                
            case .paused:
                timer.invalidate()
                
            case .resumed:
                startTimer()
                updateCompletionDate()
            }
        }
    }
    
    @Published var secondsToCompletion = 0
    @Published var progress: Float = 0.0
    @Published var completionDate = Date.now
    
    let minutesRange = 0...59
    let secondsRange = 0...59
    
    private var timer = Timer()
    private var totalTimeForCurrentSelection: Int {
        (selectedMinutesAmount * 60) + selectedSecondsAmount
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            self.secondsToCompletion -= 1
            self.progress = Float(self.secondsToCompletion) / Float(self.totalTimeForCurrentSelection)
            
            if self.secondsToCompletion < 0 {
                self.state = .cancelled
            }
        }
    }
    
    private func updateCompletionDate() {
        completionDate = Date.now.addingTimeInterval(Double(secondsToCompletion))
    }
}

extension Int {
    var asTimestamp: String {
        let minute = self / 60 % 60
        let second = self % 60
        return String(format: "%02i:%02i", minute, second)
    }
}