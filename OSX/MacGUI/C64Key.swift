//
//  C64Key.swift
//  VirtualC64
//
//  Created by Dirk Hoffmann on 18.02.18.
//

import Foundation

/// The C64Key structure represents a physical keys on the C64 keyboard.
/// The key is specified by its row and column position in the C64 keyboard matrix.
struct C64Key : Codable {
    
    // Row index
    var row = 0
    
    // Column index
    var col = 0
    
    // Textual description of this key
    var description: String = ""
    
    init(row: Int, col: Int, characters: String) {
        
        self.row = row
        self.col = col
        self.description = characters
    }
    
    init(row: Int, col: Int) {
        
        precondition(row >= 0 && row <= 8 && col >= 0 && col <= 8)
        
        let curUD = "CU \u{21c5}" // "\u{2191}\u{2193}"
        let curLR = "CU \u{21c6}" // "\u{2190}\u{2192}"
        let shiftL = "\u{21e7}"
        let shiftR = "      \u{21e7}"
        var name = [
            ["DEL",      "\u{21b5}", curLR,      "F7",   "F1",       "F3", "F5",      curUD],
            ["3",        "W",        "A",        "4",    "Z",        "S",  "E",       shiftL],
            ["5",        "R",        "D",        "6",    "C",        "F",  "T",       "X"],
            ["7",        "Y",        "G",        "8",    "B",        "H",  "U",       "V"],
            ["9",        "I",        "J",        "0",    "M",        "K",  "O",       "N"],
            ["+",        "P",        "L",        "-",    ".",        ":",  "@",       ","],
            ["\u{00a3}", "*",        ";",        "HOME", shiftR,     "=",  "\u{2191}", "/"],
            ["1",        "\u{2190}", "CTRL",     "2",    "\u{23b5}", "C=", "Q",        "STOP"]]

        self.init(row: row, col: col, characters: name[row][col])
    }
    
    /// Image representation of this key
    func image(auxiliaryText: NSString = "") -> NSImage {
        
        let background = NSImage(named: NSImage.Name(rawValue: "key.png"))!
        let width = 48.0
        let height = 48.0
        let imageRect = CGRect(x: 0, y: 0, width: width, height: height)
        let textRect1 = CGRect(x: 7, y: -2, width: width-7, height: height-2)
        let textRect2 = CGRect(x: 14, y: -10, width: width-14, height: height-10)
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        let font1 = NSFont.systemFont(ofSize: 12)
        let font2 = NSFont.systemFont(ofSize: 16)
        let textFontAttributes1 = [
            NSAttributedStringKey.font: font1,
            NSAttributedStringKey.foregroundColor: NSColor.gray,
            NSAttributedStringKey.paragraphStyle: textStyle
        ]
        let textFontAttributes2 = [
            NSAttributedStringKey.font: font2,
            NSAttributedStringKey.foregroundColor: NSColor.black,
            NSAttributedStringKey.paragraphStyle: textStyle
        ]
        let outImage = NSImage(size: NSSize.init(width: width, height: height))
        let rep:NSBitmapImageRep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                                    pixelsWide: Int(width),
                                                    pixelsHigh: Int(height),
                                                    bitsPerSample: 8,
                                                    samplesPerPixel: 4,
                                                    hasAlpha: true,
                                                    isPlanar: false,
                                                    colorSpaceName: NSColorSpaceName.calibratedRGB,
                                                    bytesPerRow: 0,
                                                    bitsPerPixel: 0)!
        outImage.addRepresentation(rep)
        outImage.lockFocus()
        background.draw(in: imageRect)
        description.draw(in: textRect1, withAttributes: textFontAttributes1)
        auxiliaryText.draw(in: textRect2, withAttributes: textFontAttributes2)
        outImage.unlockFocus()
        return outImage
    }
}

extension C64Key: Equatable {
    static func ==(lhs: C64Key, rhs: C64Key) -> Bool {
        return lhs.row == rhs.row && lhs.col == rhs.col
    }
}

extension C64Key: Hashable {
    var hashValue: Int {
        return col + (8 * row)
    }
}

extension C64Key {
    
    // First row
    static let delete       = C64Key.init(row: 0, col: 0)
    static let ret          = C64Key.init(row: 0, col: 1)
    static let curLeftRight = C64Key.init(row: 0, col: 2)
    static let F7F8         = C64Key.init(row: 0, col: 3)
    static let F1F2         = C64Key.init(row: 0, col: 4)
    static let F3F4         = C64Key.init(row: 0, col: 5)
    static let F5F6         = C64Key.init(row: 0, col: 6)
    static let curUpDown    = C64Key.init(row: 0, col: 7)
    
    // Second row
    static let digit3       = C64Key.init(row: 1, col: 0)
    static let W            = C64Key.init(row: 1, col: 1)
    static let A            = C64Key.init(row: 1, col: 2)
    static let digit4       = C64Key.init(row: 1, col: 3)
    static let Z            = C64Key.init(row: 1, col: 4)
    static let S            = C64Key.init(row: 1, col: 5)
    static let E            = C64Key.init(row: 1, col: 6)
    static let shift        = C64Key.init(row: 1, col: 7)
    
    // Third row
    static let digit5       = C64Key.init(row: 2, col: 0)
    static let R            = C64Key.init(row: 2, col: 1)
    static let D            = C64Key.init(row: 2, col: 2)
    static let digit6       = C64Key.init(row: 2, col: 3)
    static let C            = C64Key.init(row: 2, col: 4)
    static let F            = C64Key.init(row: 2, col: 5)
    static let T            = C64Key.init(row: 2, col: 6)
    static let X            = C64Key.init(row: 2, col: 7)
    
    // Fourth row
    static let digit7       = C64Key.init(row: 3, col: 0)
    static let Y            = C64Key.init(row: 3, col: 1)
    static let G            = C64Key.init(row: 3, col: 2)
    static let digit8       = C64Key.init(row: 3, col: 3)
    static let B            = C64Key.init(row: 3, col: 4)
    static let H            = C64Key.init(row: 3, col: 5)
    static let U            = C64Key.init(row: 3, col: 6)
    static let V            = C64Key.init(row: 3, col: 7)
    
    // Fifth row
    static let digit9       = C64Key.init(row: 4, col: 0)
    static let I            = C64Key.init(row: 4, col: 1)
    static let J            = C64Key.init(row: 4, col: 2)
    static let digit0       = C64Key.init(row: 4, col: 3)
    static let M            = C64Key.init(row: 4, col: 4)
    static let K            = C64Key.init(row: 4, col: 5)
    static let O            = C64Key.init(row: 4, col: 6)
    static let N            = C64Key.init(row: 4, col: 7)
    
    // Sixth row
    static let plus         = C64Key.init(row: 5, col: 0)
    static let P            = C64Key.init(row: 5, col: 1)
    static let L            = C64Key.init(row: 5, col: 2)
    static let minus        = C64Key.init(row: 5, col: 3)
    static let period       = C64Key.init(row: 5, col: 4)
    static let colon        = C64Key.init(row: 5, col: 5)
    static let at           = C64Key.init(row: 5, col: 6)
    static let comma        = C64Key.init(row: 5, col: 7)
    
    // Seventh row
    static let pound        = C64Key.init(row: 6, col: 0)
    static let asterisk     = C64Key.init(row: 6, col: 1)
    static let semicolon    = C64Key.init(row: 6, col: 2)
    static let home         = C64Key.init(row: 6, col: 3)
    static let rightShift   = C64Key.init(row: 6, col: 4)
    static let equal        = C64Key.init(row: 6, col: 5)
    static let upArrow      = C64Key.init(row: 6, col: 6)
    static let slash        = C64Key.init(row: 6, col: 7)
    
    
    // Eights row
    static let digit1       = C64Key.init(row: 7, col: 0)
    static let leftArrow    = C64Key.init(row: 7, col: 1)
    static let control      = C64Key.init(row: 7, col: 2)
    static let digit2       = C64Key.init(row: 7, col: 3)
    static let space        = C64Key.init(row: 7, col: 4) // \u{2423}
    static let commodore    = C64Key.init(row: 7, col: 5)
    static let Q            = C64Key.init(row: 7, col: 6)
    static let runStop      = C64Key.init(row: 7, col: 7)
    
    // Restore key
    static let restore      = C64Key.init(row: 9, col: 9, characters: "")
}
