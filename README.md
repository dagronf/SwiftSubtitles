# Swift Subtitles

A Swift package for reading/writing some common subtitle formats.

![tag](https://img.shields.io/github/v/tag/dagronf/SwiftSubtitles)
![Swift](https://img.shields.io/badge/Swift-5.4-orange.svg)
[![License MIT](https://img.shields.io/badge/license-MIT-magenta.svg)](https://github.com/dagronf/SwiftSubtitles/blob/master/LICENSE) 
![SPM](https://img.shields.io/badge/spm-compatible-maroon.svg)
![Build](https://img.shields.io/github/actions/workflow/status/dagronf/SwiftSubtitles/swift.yml)

![macOS](https://img.shields.io/badge/macOS-10.13+-darkblue)
![iOS](https://img.shields.io/badge/iOS-13+-crimson)
![tvOS](https://img.shields.io/badge/tvOS-13+-forestgreen)
![watchOS](https://img.shields.io/badge/watchOS-4+-indigo)
![macCatalyst](https://img.shields.io/badge/macCatalyst-2+-orangered)
![Linux](https://img.shields.io/badge/Linux-compatible-peru)

## Available coders

| Format           | Coder                  | File extension  |
|:-----------------|:-----------------------|:----------------|
| SBV (SubViewer)  | `Subtitles.Coder.SBV`  | `.sbv`          |
| SUB (MicroDVD)*  | `Subtitles.Coder.SUB`  | `.sub`          |
| SRT (SubRip)     | `Subtitles.Coder.SRT`  | `.srt`          |
| VTT (WebVTT)     | `Subtitles.Coder.VTT`  | `.vtt`          |
| CSV              | `Subtitles.Coder.CSV`  | `.csv`          |

* Read-only

## Basic usage

### Decoding

Basic decoding uses the file extension to determine the coder to use when decoding.

```swift
let subtitles = try Subtitles(fileURL: <some file url>)
subtitles.cues.forEach { cue in
	// Do something with 'cue'
}
```

You can also instantiate a coder object and use that directly if you know the type of subtitles you'll be decoding

```swift
let subtitleContent = ...
let coder = Subtitles.Coder.SBV()
let subtitles = try coder.decode(subtitleContent)
...
let encodedContent = try coder.encode(subtitles: subtitles)
``` 

### Encoding

```swift
let cue1 = Subtitles.Cue(
	position: 1,
	startTime: Subtitles.Time(minute: 10),
	endTime: Subtitles.Time(minute: 11),
	text: "점점 더 많아지는\n시민들의 성난 목소리로..."
)

let cue2 = Subtitles.Cue(
	position: 2,
	startTime: Subtitles.Time(minute: 13, second: 5),
	endTime: Subtitles.Time(minute: 15, second: 10, millisecond: 101),
	text: "Second entry"
)

let subtitles = Subtitles([cue1, cue2])

// Encode based on the subtitle file extension
let content = try Subtitles.encode(subtitles, fileExtension: "srt")

// Encode using an explicit coder
let coder = Subtitles.Coder.VTT()
let content2 = try coder.encode(subtitles: subtitles)
```

## CSV coding/encoding

There appears to be no formal CSV specification for subtitles, so this coder tries to make a generic "enough" encoder/decoder to make it easier for an app to export into a spreadsheet or google docs.

The CSV must conform to [RFC 4180](https://www.rfc-editor.org/rfc/rfc4180.html)

* Text that contains double-quotes must be double-double-quoted (eg. ">> ALICE: My cat is named ""cat"" and is quite arrogant")
* Text containing newlines must be encapsulated in quotes. (eg. ">> ALICE: What about you?\n>> ROB: I don't have an opinion")

This library uses [TinyCSV](https://github.com/dagronf/TinyCSV) for CSV coding/decoding.

During decoding, the coder ignores the header if it exists, and assumes a particular ordering for the columns

### Row format

The header text for the CSV is not important, the ordering of the fields determine what type of data to expect

Detected row formats :-

* `<position>, <start-time>, <end-time>, <text>`

* position: The position of the cue (subtitle text) within the subtitles
* start-time: The time where the text appears on the screen
* end-time: The time where the text is removed from the screen
* The text to display

#### Time formats supported for decoding

* SBV style: `00:00:00.000`
* SRT style: `00:00:00,000`
* Common style: `00:00:00:000`
* milliseconds: `102727`

#### Examples using common style text formats

```
No.,Timecode In,Timecode Out,Subtitle
1, 00:00:00:599, 00:00:04.160, ">> ALICE: Hi, my name is Alice Miller and this is John Brown"
2, 00:00:04:160, 00:00:06.770, ">> JOHN: and we're the owners of ""Miller Bakery""."
```

```
Position,Start time,End Time,Text
51,00:00:00:599,00:00:04.160,">> ALICE: Hi, my name is Alice Miller and this is John Brown"
52,00:00:04:160,00:00:06.770,">> JOHN: and we're the owners of ""Miller Bakery""."
```

#### An example using millisecond durations and containing line feeds within the text

```
1, 91216, 93093, "РегалВю ТЕЛЕМАРКЕТИНГ
АНДЕРСЪН - МЕНИДЖЪР"
2, 102727, 104562, "Тук пише, че 5 години сте бил"
3, 104646, 107232, "мениджър на ресторант ""Ръсти Скапър""."
```

## Limitations

* Some VTT functionality is not supported (NOTE, STYLE, REGION). These will be discarded on import. 

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
