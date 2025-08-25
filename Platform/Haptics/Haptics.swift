import UIKit

struct Haptics {
    static func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    static func softImpact() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    static func prepare() {
        let lightGenerator = UIImpactFeedbackGenerator(style: .light)
        let softGenerator = UIImpactFeedbackGenerator(style: .soft)
        let selectionGenerator = UISelectionFeedbackGenerator()
        
        lightGenerator.prepare()
        softGenerator.prepare()
        selectionGenerator.prepare()
    }
}