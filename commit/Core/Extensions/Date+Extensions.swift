import Foundation

extension Date {
    /// Start of day for this date - test number 3
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// Check if this date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    /// Check if this date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Days between two dates
    func daysBetween(_ otherDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self.startOfDay, to: otherDate.startOfDay)
        return abs(components.day ?? 0)
    }
}
