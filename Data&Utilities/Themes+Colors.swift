//
//  TajikColors.swift
//  TajikKeyboard
//
//  Created by Aminjoni Abdullozoda on 4/22/19.
//  Copyright © 2019 Aminjoni Abdullozoda. All rights reserved.
//

import UIKit

enum TajikColorScheme {
    case dark
    case light
}

struct TajikColors {
    let buttonTextColor: UIColor
    let buttonBackgroundColor: UIColor
    let buttonHighlightColor: UIColor
    let backgroundColor: UIColor
    let previewTextColor: UIColor
    let previewBackgroundColor: UIColor
    
    init(colorScheme: TajikColorScheme) {
        switch colorScheme {
        case .light:
            buttonTextColor = .black
            buttonBackgroundColor = .white
            buttonHighlightColor = UIColor(red: 174/255, green: 179/255, blue: 190/255, alpha: 1.0)
            backgroundColor = UIColor(red: 210/255, green: 213/255, blue: 219/255, alpha: 1.0)
            previewTextColor = .white
            previewBackgroundColor = UIColor(red: 186/255, green: 191/255, blue: 200/255, alpha: 1.0)
        case .dark:
            buttonTextColor = .white
            buttonBackgroundColor = UIColor(white: 138/255, alpha: 1.0)
            buttonHighlightColor = UIColor(white: 104/255, alpha: 1.0)
            backgroundColor = UIColor(white:89/255, alpha: 1.0)
            previewTextColor = .white
            previewBackgroundColor = UIColor(white: 80/255, alpha: 1.0)
        }
    }
}
