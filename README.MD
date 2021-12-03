# SoundScape_ 
![SoundScape_ logo](/assets/img/MarineGEO_logo.png "MarineGEO logo")
##### Capture landscape by sound.
 An audio focused social media. With SoundScape_, users can upload audio files, share the story of the audio, and mark the location where the audio  recorded.

<p align="center"><a href="https://apps.apple.com/tw/app/soundscape/id1591896646">
<img src="https://i.imgur.com/X9tPvTS.png" width="120" height="40"/>
</a></p>

## Table of Contents
* [Features](#Features)
* [Technical Highlights](#TechnicalHighlights)
* [Libraries](#Libraries)
* [ReleaseNotes](#ReleaseNotes)
* [Contact](#contact)
## Features
- Record and Upload Audio: Grab your iPhone and share the unique soundscape anytime, anywhere.
- SoundScape_  Map: Roaming on Google Map to explore soundscape from different area in the world.
- Community: Share and leave comment to pieces of soundscpae.
- Audio trimmer: Tailor-made a view for trimming off audio, enable users uploading the exact piece of audio they wish to share.

##### SoundScape Wall
 >Display all soundscape by category.
 
##### Search page
 >Search soundscape by title, author, or content. Allow filtering results by categories. 
 
##### Upload audio
 >Enable record or select audio file for uploading to SoundScape_.
 
##### SoundScape_ Map
 >Roaming on map to feel what does it 'hear like' to be there.
 
##### Profile
 >A place can view all soundscape you've uploaded, your favorite soundscape, and the soundscape upload by your following users.
 
## Technical Highlights
- Implemented OOP and MVC to keep code maintainable and simple.
- Encapsulated player behavior by protocol in order to follow low coupling principle.
- Customized a player above the tab bar with AVAudioPlayer and CADisplayLink, which can keep playing audio across different tabs to allow users play audio instantly.
- Tailor-made a view for trimming off audio with AVAssetExportSession, enabled users upload the exact piece of audio they wish to share.
- Made use of Firebase Storage to store and manage audio files.
- To reduce the number of API requests, audio files were downloaded from Firebase Storage and were saved in CachesDirectory of App’s sandbox through FileManager.
- Performed Firebase Snapshot Listener to achieve real-time data synchronization and interactions between users.
- Employed MapKit for searching locations and getting access to precise latitude, longitude.
- Used Google Map SDK to display map and add markers, and also provided a map interface which is familiar to most users.
- With the intention of  improving user experience, Crashlytics was integrated so as to track stability issues and do further bug fixing.
## Libraries

- [DSWaveformImage](https://github.com/dmrschmidt/DSWaveformImage)
-  [Google Map](https://developers.google.com/maps/documentation/ios-sdk/overview)
- [SPAlert](https://github.com/ivanvorobei/SPAlert)
- [lottie-ios](https://github.com/airbnb/lottie-ios)
- [IQKeyboardManagerSwift](https://github.com/hackiftekhar/IQKeyboardManager)
- [SwiftLint](https://github.com/realm/SwiftLint)

## Release Notes
| Version | Date | Description                                                                                     |
| :-------| :----|:------------------------------------------------------------------------------------------------|
| 1.0.2   | 2021.11.22 | Improved performance. |
| 1.0.1   | 2021.11.19 | Release in App Store|
## Contact
Astrid tingan.l1216@gmail.com 
