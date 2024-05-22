//
//  Extensions.swift
//  monset
//
//  Created by faisal haddad on 14/11/1445 AH.
//

import Foundation
import SwiftUI


public extension Color {
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255
        )
    }
}

public extension Int {
    var hour: TimeInterval {
        return TimeInterval(self * 3600)
    }

    var day: TimeInterval {
        return TimeInterval(self * 86400)
    }

    var week: TimeInterval {
        return TimeInterval(self * 604800)
    }

    var month: TimeInterval {
        return TimeInterval(self * 2629743)
    }
}



public extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

public extension String {
    subscript(_ n: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: n)]
    }
}


// MARK: - View extensions

struct Backport<Content> {
    let content: Content
}


struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


public extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

extension View {
    var backport: Backport<Self> { Backport(content: self) }
    
}


extension Backport where Content: View {
    
    @ViewBuilder func scrollDisabled(_ disabled: Bool) -> some View {
        if #available(iOS 16, *), #available(watchOS 9,*) {
            content.scrollDisabled(disabled)
        } else {
            content
        }
        
    }
    
}
