# SwiftSRT

Decode and encode `.srt` (SubRip subtitle) files. 

<p align="center">
    <img src="https://img.shields.io/github/v/tag/dagronf/SwiftSRT" />
    <img src="https://img.shields.io/badge/Swift-5.4-orange.svg" />
    <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
</p>

<p align="center">
    <img src="https://img.shields.io/badge/macOS-10.13+-red" />
    <img src="https://img.shields.io/badge/macCatalyst-2+-purple" />
    <img src="https://img.shields.io/badge/iOS-13+-blue" />
    <img src="https://img.shields.io/badge/tvOS-13+-orange" />
    <img src="https://img.shields.io/badge/watchOS-4+-yellow" />
    <img src="https://img.shields.io/badge/Linux-compatible-orange" />
</p>

## Basic usage

### Decoding
 
```swift
let srt = try SRT(fileURL: <some file url>)
srt.entries.forEach { entry in
	// Do something with 'entry'
}
```

### Encoding

```swift
let entry1 = SRT.Entry(
   position: 1,
   startTime: SRT.Time(minute: 10),
   endTime: SRT.Time(minute: 11),
   text: "점점 더 많아지는\n시민들의 성난 목소리로..."
)

let entry2 = SRT.Entry(
   position: 2,
   startTime: SRT.Time(minute: 13, second: 5),
   endTime: SRT.Time(minute: 15, second: 10, millisecond: 101),
   text: "Second entry"
)

let srt = try SRT(entries: [entry1, entry2])
let content = srt.encode()
```

## License

MIT. Use it for anything you want, just attribute my work if you do. Let me know if you do use it somewhere, I'd love to hear about it!

```
MIT License

Copyright (c) 2023 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
