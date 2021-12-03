<h1 align="center">SoundScape_  </h1>  
<p align="center">
<img src="https://github.com/Astrid-sudo/SoundScape/blob/main/SoundScape/Screenshots/SoundScape__Icon.png?raw=true" width="200" height="200"/>
</p>
<h2 align="center">Capture landscape by sound.<br>An audio focused social media. </h2>			
<h4 align="center">With SoundScape_, users can upload audio files, share the story of the audio, and mark the location where the audio recorded.</p>
<br>

<p align="center"><a href="https://apps.apple.com/tw/app/soundscape/id1591896646">
<img src="https://i.imgur.com/X9tPvTS.png" width="120" height="40"/>
</a></p>

## Table of Contents
* [Features](#Features)
* [TechnicalHighlights](#TechnicalHighlights)
* [Libraries](#Libraries)
* [Requirement](#Requirement)
* [ReleaseNotes](#ReleaseNotes)
* [Contact](#contact)
## Features
- Record and Upload Audio: Grab your iPhone and share the unique soundscape anytime, anywhere.
- SoundScape_  Map: Roaming on Google Map to explore soundscape from different area in the world.
- Community: Share and leave comment to pieces of soundscpae.
- Audio trimmer: Tailor-made a view for trimming off audio, enable users uploading the exact piece of audio they wish to share.

##### SoundScape Wall
 >Display all soundscape by category.
  <p>
<img src="https://github.com/Astrid-sudo/SoundScape/blob/main/SoundScape/Screenshots/soundscape%20wall.png?raw=true" width="200" height="400"/>
</p>

##### Search page
 >Search soundscape by title, author, or content. Allow filtering results by categories. 
  <p>
<img src="https://github.com/Astrid-sudo/SoundScape/blob/main/SoundScape/Screenshots/search.png?raw=true"width="200" height="400"/>
</p>
 
##### Upload audio
 >Enable record or select audio file for uploading to SoundScape_.
  <p>
<img src="https://github.com/Astrid-sudo/SoundScape/blob/main/SoundScape/Screenshots/record.png?raw=true" width="200" height="400"/>
<img src="https://github.com/Astrid-sudo/SoundScape/blob/main/SoundScape/Screenshots/upload.png?raw=true" width="200" height="400"/>
</p>

##### SoundScape_ Map
 >Roaming on map to feel what does it 'hear like' to be there.
 <p>
<img src="https://github.com/Astrid-sudo/SoundScape/blob/main/SoundScape/Screenshots/soundscape.png?raw=true" width="200" height="400"/>
</p>
 
##### Profile
 >A place can view all soundscape you've uploaded, your favorite soundscape, and the soundscape upload by your following users.
 <p>
<img src="https://github.com/Astrid-sudo/SoundScape/blob/main/SoundScape/Screenshots/profile.png?raw=true" width="200" height="400"/>
</p>
 
## TechnicalHighlights
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
## Requirement
- Xcode 13.0
- Swift 5.0
- iOS 14.0

## ReleaseNotes
| Version | Date | Description                                                                                     |
| :-------| :----|:------------------------------------------------------------------------------------------------|
| 1.0.2   | 2021.11.22 | Improved performance. |
| 1.0.1   | 2021.11.19 | Release in App Store|
## Contact
Astrid tingan.l1216@gmail.com 
