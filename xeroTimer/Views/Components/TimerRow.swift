import SwiftUI

struct TimerRow: View {
    @ObservedObject var timer: XeroTimeEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(timer.description)
                    .font(.headline)
                Text(timeString(from: timer.duration))
                    .font(.subheadline)
            }
            
            Spacer()
            
            if timer.isActive {
                Button(action: {
                    if timer.isPaused {
                        timer.resume()
                    } else {
                        timer.pause()
                    }
                }) {
                    Image(systemName: timer.isPaused ? "play.circle" : "pause.circle")
                }
                
                Button(action: {
                    timer.stop()
                }) {
                    Image(systemName: "stop.circle")
                }
            }
        }
        .padding()
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
} 