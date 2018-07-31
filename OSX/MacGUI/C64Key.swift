//
//  C64Key.swift
//  VirtualC64
//
//  Created by Dirk Hoffmann on 18.02.18.
//

import Foundation

/// The C64Key structure represents a physical keys on the C64 keyboard.
/// Each of the 66 keys is specified uniquely by it's number ranging from
/// 0 to 64. When a key is pressed, a row bit and a column bit is set in the
/// keyboard matrix that can be read by the CIA chip. Note that the CapsLock
/// and the Restore key behave differently. Caps lock is a switch that holds
/// down the left shift key until it is released and restore has no key matrix
/// representation at all. Instead, it is directly connected to the NMI line.

struct C64Key : Codable {
    
    // A number that identifies this key uniquely
    var nr = -1
    
    // Row index
    var row = -1
    
    // Column index
    var col = -1
    
    // Textual description of this key
    // DEPRECATED
    var description: String = ""
    
    init(_ nr: Int, characters: String) {
        
        precondition(nr >= 0 && nr <= 65)
        
        let rowcol = [
            // First physical key row
            (7,1), (7,0), (7,3), (1,0), (1,3), (2,0), (2,3), (3,0),
            (3,3), (4,0), (4,3), (5,0), (5,3), (6,0), (6,3), (0,0), (0,4) /* f1 */,
            
            // Second physical key row
            (7,2), (7,6), (1,1), (1,6), (2,1), (2,6), (3,1), (3,6),
            (4,1), (4,6), (5,1), (5,6), (6,1), (6,6), (9,9), (0,5) /* f3 */,

            // Third physical key row
            (7,7), (9,9), (1,2), (1,5), (2,2), (2,5), (3,2), (3,5),
            (4,2), (4,5), (5,2), (5,5), (6,2), (6,5), (0,1), (0,6) /* f5 */,
            
            // Fourth physical key row
            (7,5), (1,7), (1,4), (2,7), (2,4), (3,7), (3,4), (4,7),
            (4,4), (5,7), (5,4), (6,7), (6,4), (0,7), (0,2), (0,3) /* f7 */,
            
            // Fifth physical key row
            (7,4) /* space */
        ]
        
        precondition(rowcol.count == 66)
        
        self.nr = nr
        if (nr != 31 /* RESTORE */ && nr != 34 /* SHIFT LOCK */) {
            self.row = rowcol[nr].0
            self.col = rowcol[nr].1
        } else {
            precondition(rowcol[nr].0 == 9 && rowcol[nr].1 == 9)
        }
        self.description = characters
    }

    init(_ nr: Int) {
            self.init(nr, characters: "")
    }
    
    init(_ rowcol : (Int, Int) ) {
        
        precondition(rowcol.0 >= 0 && rowcol.0 <= 8)
        precondition(rowcol.1 >= 0 && rowcol.1 <= 8)
        
        let nr = [ 15, 47, 63, 64, 16, 32, 48, 62,
                    3, 19, 35,  4, 51, 36, 20, 50,
                    5, 21, 37,  6, 53, 38, 22, 52,
                    7, 23, 39,  8, 55, 40, 24, 54,
                    9, 25, 41, 10, 57, 42, 26, 56,
                   11, 27, 43, 12, 59, 44, 28, 58,
                   13, 29, 45, 14, 61, 46, 30, 60,
                    1,  0, 17,  2, 65, 49, 18, 33
        ]
        
        precondition(nr.count == 64)
        
        self.row = rowcol.0
        self.col = rowcol.1
        self.nr = nr[8 * row + col]
    }
    
    init(_ nr: Int, row: Int, col: Int, characters: String) {
        
        precondition(nr >= 0 && nr <= 65)
        precondition(row >= 0 && row <= 8)
        precondition(col >= 0 && col <= 8)
        
        self.init( (row,col) )
        if nr != 31 {
            precondition(self.nr == nr)
        }
    }
    
    init(_ nr: Int, row: Int, col: Int) {
    
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

        self.init(nr, row: row, col: col, characters: name[row][col])
    }
    
   
    /// Returns an image representation for this key that is used in the
    /// virtual keyboard.
    
    /// Returns an image representation for this key that is used in the
    /// user dialog for configuring the key mapping.
    func image(auxiliaryText: NSString = "") -> NSImage {
        
        let background = NSImage(named: NSImage.Name(rawValue: "key"))!
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
    static let delete       = C64Key.init(31, row: 0, col: 0)
    static let ret          = C64Key.init(47, row: 0, col: 1)
    static let curLeftRight = C64Key.init(63, row: 0, col: 2)
    static let F7F8         = C64Key.init(64, row: 0, col: 3)
    static let F1F2         = C64Key.init(16, row: 0, col: 4)
    static let F3F4         = C64Key.init(32, row: 0, col: 5)
    static let F5F6         = C64Key.init(48, row: 0, col: 6)
    static let curUpDown    = C64Key.init(62, row: 0, col: 7)
    
    // Second row
    static let digit3       = C64Key.init(3, row: 1, col: 0)
    static let W            = C64Key.init(19, row: 1, col: 1)
    static let A            = C64Key.init(35, row: 1, col: 2)
    static let digit4       = C64Key.init(4, row: 1, col: 3)
    static let Z            = C64Key.init(51, row: 1, col: 4)
    static let S            = C64Key.init(36, row: 1, col: 5)
    static let E            = C64Key.init(20, row: 1, col: 6)
    static let shift        = C64Key.init(50, row: 1, col: 7)
    
    // Third row
    static let digit5       = C64Key.init(5, row: 2, col: 0)
    static let R            = C64Key.init(21, row: 2, col: 1)
    static let D            = C64Key.init(37, row: 2, col: 2)
    static let digit6       = C64Key.init(6, row: 2, col: 3)
    static let C            = C64Key.init(53, row: 2, col: 4)
    static let F            = C64Key.init(38, row: 2, col: 5)
    static let T            = C64Key.init(22, row: 2, col: 6)
    static let X            = C64Key.init(52, row: 2, col: 7)
    
    // Fourth row
    static let digit7       = C64Key.init(7, row: 3, col: 0)
    static let Y            = C64Key.init(23, row: 3, col: 1)
    static let G            = C64Key.init(39, row: 3, col: 2)
    static let digit8       = C64Key.init(8, row: 3, col: 3)
    static let B            = C64Key.init(55, row: 3, col: 4)
    static let H            = C64Key.init(40, row: 3, col: 5)
    static let U            = C64Key.init(24, row: 3, col: 6)
    static let V            = C64Key.init(54, row: 3, col: 7)
    
    // Fifth row
    static let digit9       = C64Key.init(9, row: 4, col: 0)
    static let I            = C64Key.init(25, row: 4, col: 1)
    static let J            = C64Key.init(41, row: 4, col: 2)
    static let digit0       = C64Key.init(10, row: 4, col: 3)
    static let M            = C64Key.init(57, row: 4, col: 4)
    static let K            = C64Key.init(42, row: 4, col: 5)
    static let O            = C64Key.init(26, row: 4, col: 6)
    static let N            = C64Key.init(56, row: 4, col: 7)
    
    // Sixth row
    static let plus         = C64Key.init(11, row: 5, col: 0)
    static let P            = C64Key.init(27, row: 5, col: 1)
    static let L            = C64Key.init(43, row: 5, col: 2)
    static let minus        = C64Key.init(12, row: 5, col: 3)
    static let period       = C64Key.init(59, row: 5, col: 4)
    static let colon        = C64Key.init(44, row: 5, col: 5)
    static let at           = C64Key.init(28, row: 5, col: 6)
    static let comma        = C64Key.init(58, row: 5, col: 7)
    
    // Seventh row
    static let pound        = C64Key.init(14, row: 6, col: 0)
    static let asterisk     = C64Key.init(29, row: 6, col: 1)
    static let semicolon    = C64Key.init(45, row: 6, col: 2)
    static let home         = C64Key.init(15, row: 6, col: 3)
    static let rightShift   = C64Key.init(61, row: 6, col: 4)
    static let equal        = C64Key.init(46, row: 6, col: 5)
    static let upArrow      = C64Key.init(30, row: 6, col: 6)
    static let slash        = C64Key.init(60, row: 6, col: 7)
    
    
    // Eights row
    static let digit1       = C64Key.init(1, row: 7, col: 0)
    static let leftArrow    = C64Key.init(0, row: 7, col: 1)
    static let control      = C64Key.init(17, row: 7, col: 2)
    static let digit2       = C64Key.init(2, row: 7, col: 3)
    static let space        = C64Key.init(65, row: 7, col: 4)
    static let commodore    = C64Key.init(49, row: 7, col: 5)
    static let Q            = C64Key.init(18, row: 7, col: 6)
    static let runStop      = C64Key.init(33, row: 7, col: 7)
    
    // Restore key
    static let restore      = C64Key.init(31)

    
    // Translates a character to a list of corresponding C64 keys
    // This function is used for symbolically mapping Mac keys to C64 keys
    static func translate(char: String?) -> [C64Key] {
        
        if char == nil { return [] }
        
        switch (char!) {
            
        // First row of C64 keyboard
        case "ü": return [C64Key.leftArrow]
        case "1": return [C64Key.digit1]
        case "!": return [C64Key.digit1, C64Key.shift]
        case "2": return [C64Key.digit2]
        case "\"": return [C64Key.digit2, C64Key.shift]
        case "3": return [C64Key.digit3]
        case "#": return [C64Key.digit3, C64Key.shift]
        case "4": return [C64Key.digit4]
        case "$": return [C64Key.digit4, C64Key.shift]
        case "5": return [C64Key.digit5]
        case "%": return [C64Key.digit5, C64Key.shift]
        case "6": return [C64Key.digit6]
        case "&": return [C64Key.digit6, C64Key.shift]
        case "7": return [C64Key.digit7]
        case "'": return [C64Key.digit7, C64Key.shift]
        case "8": return [C64Key.digit8]
        case "(": return [C64Key.digit8, C64Key.shift]
        case "9": return [C64Key.digit9]
        case ")": return [C64Key.digit9, C64Key.shift]
        case "0": return [C64Key.digit0]
        case "+": return [C64Key.plus]
        case "-": return [C64Key.minus]
        case "§": return [C64Key.pound]
            
        // Second row of C64 keyboard
        case "q": return [C64Key.Q]
        case "Q": return [C64Key.Q, C64Key.shift]
        case "w": return [C64Key.W]
        case "W": return [C64Key.W, C64Key.shift]
        case "e": return [C64Key.E]
        case "E": return [C64Key.E, C64Key.shift]
        case "r": return [C64Key.R]
        case "R": return [C64Key.R, C64Key.shift]
        case "t": return [C64Key.T]
        case "T": return [C64Key.T, C64Key.shift]
        case "y": return [C64Key.Y]
        case "Y": return [C64Key.Y, C64Key.shift]
        case "u": return [C64Key.U]
        case "U": return [C64Key.U, C64Key.shift]
        case "i": return [C64Key.I]
        case "I": return [C64Key.I, C64Key.shift]
        case "o": return [C64Key.O]
        case "O": return [C64Key.O, C64Key.shift]
        case "p": return [C64Key.P]
        case "P": return [C64Key.P, C64Key.shift]
        case "@": return [C64Key.at]
        case "ö": return [C64Key.at]
        case "*": return [C64Key.asterisk]
        case "ä": return [C64Key.upArrow]
            
        // Third row of C64 keyboard
        case "a": return [C64Key.A]
        case "A": return [C64Key.A, C64Key.shift]
        case "s": return [C64Key.S]
        case "S": return [C64Key.S, C64Key.shift]
        case "d": return [C64Key.D]
        case "D": return [C64Key.D, C64Key.shift]
        case "f": return [C64Key.F]
        case "F": return [C64Key.F, C64Key.shift]
        case "g": return [C64Key.G]
        case "G": return [C64Key.G, C64Key.shift]
        case "h": return [C64Key.H]
        case "H": return [C64Key.H, C64Key.shift]
        case "j": return [C64Key.J]
        case "J": return [C64Key.J, C64Key.shift]
        case "k": return [C64Key.K]
        case "K": return [C64Key.K, C64Key.shift]
        case "l": return [C64Key.L]
        case "L": return [C64Key.L, C64Key.shift]
        case ":": return [C64Key.colon]
        case "[": return [C64Key.colon, C64Key.shift]
        case ";": return [C64Key.semicolon]
        case "]": return [C64Key.semicolon, C64Key.shift]
        case "=": return [C64Key.equal]
        case "\n": return [C64Key.ret]

        // Fourth row of C64 keyboard
        case "z": return [C64Key.Z]
        case "Z": return [C64Key.Z, C64Key.shift]
        case "x": return [C64Key.X]
        case "X": return [C64Key.X, C64Key.shift]
        case "c": return [C64Key.C]
        case "C": return [C64Key.C, C64Key.shift]
        case "v": return [C64Key.V]
        case "V": return [C64Key.V, C64Key.shift]
        case "b": return [C64Key.B]
        case "B": return [C64Key.B, C64Key.shift]
        case "n": return [C64Key.N]
        case "N": return [C64Key.N, C64Key.shift]
        case "m": return [C64Key.M]
        case "M": return [C64Key.M, C64Key.shift]
        case ",": return [C64Key.comma]
        case "<": return [C64Key.comma, C64Key.shift]
        case ".": return [C64Key.period]
        case ">": return [C64Key.period, C64Key.shift]
        case "/": return [C64Key.slash]
        case "?": return [C64Key.slash, C64Key.shift]
           
        // Fifth row of C64 keyboard
        case " ": return [C64Key.space]
            
        default: return []
        }
    }
}
