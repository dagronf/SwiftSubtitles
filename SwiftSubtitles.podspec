Pod::Spec.new do |s|
  s.name                 = "SwiftSubtitles"
  s.version              = "1.3.0"
  s.summary              = "A Swift package for reading/writing some common subtitle formats."
  s.description          = <<-DESC
    A Swift package for reading/writing subtitle formats (srt, sbv, sub, vtt, csv).
  DESC
  s.homepage             = "https://github.com/dagronf"
  s.license              = { :type => "MIT", :file => "LICENSE" }
  s.author               = { "Darren Ford" => "dford_au-reg@yahoo.com" }
  s.source               = { :git => "https://github.com/dagronf/SwiftSubtitles.git", :tag => s.version.to_s }
  s.source_files         = 'Sources/SwiftSubtitles/**/*.swift'
  s.resources            = [ "Sources/SwiftSubtitles/PrivacyInfo.xcprivacy" ]
  s.platforms            = { :ios => "12.0", :tvos => "12.0", :osx => "10.13", :watchos => "6.0" }
  s.swift_versions       = ['5.4', '5.5', '5.6', '5.7', '5.8', '5.9', '5.10']
  s.dependency           'DSFRegex', '~> 3.4.0'
  s.dependency           'TinyCSV', '~> 1.0.0'
end
