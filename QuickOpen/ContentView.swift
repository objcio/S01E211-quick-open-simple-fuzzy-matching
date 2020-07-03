import SwiftUI
import Cocoa
import OSLog

let log = OSLog(subsystem: "objc.io", category: "FuzzyMatch")

extension String {
    func fuzzyMatch(_ needle: String) -> [String.Index]? {
        var ixs: [Index] = []
        if needle.isEmpty { return [] }
        var remainder = needle[...].utf8
        for idx in utf8.indices {
            let char = utf8[idx]
            if char == remainder[remainder.startIndex] {
                ixs.append(idx)
                remainder.removeFirst()
                if remainder.isEmpty { return ixs }
            }
        }
        return nil
    }
}

struct ContentView: View {
    @State var needle: String = ""
    
    var filtered: [(string: String, indices: [String.Index])] {
        os_signpost(.begin, log: log, name: "Search", "%@", needle)
        defer { os_signpost(.end, log: log, name: "Search", "%@", needle) }
        return files.compactMap {
            guard let match = $0.fuzzyMatch(needle) else { return nil }
            return ($0, match)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(nsImage: search)
                    .padding(.leading, 10)
                TextField("", text: $needle).textFieldStyle(PlainTextFieldStyle())
                    .padding(10)
                    .font(.subheadline)
                Button(action: {
                    self.needle = ""
                }, label: {
                    Image(nsImage: close)
                        .padding()
                }).disabled(needle.isEmpty)
                .buttonStyle(BorderlessButtonStyle())
            }
            List(filtered.prefix(30), id: \.string) { result in
                highlight(string: result.string, indices: result.indices)
            }
        }
    }
}

func highlight(string: String, indices: [String.Index]) -> Text {
    var result = Text("")
    for i in string.indices {
        let char = Text(String(string[i]))
        if indices.contains(i) {
            result = result + char.bold()
        } else {
            result = result + char.foregroundColor(.secondary)
        }
    }
    return result
}


// Hack to disable the focus ring
extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}

let close: NSImage = NSImage(named: "NSStopProgressFreestandingTemplate")!
let search: NSImage = NSImage(named: "NSTouchBarSearchTemplate")!
