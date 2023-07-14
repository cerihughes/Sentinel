[![Build Status](https://api.travis-ci.com/cerihughes/Sentinel.png?branch=master)](https://www.travis-ci.com/cerihughes/Sentinel/) [![codecov.io](https://codecov.io/gh/cerihughes/Sentinel/branch/master/graphs/badge.svg)](https://codecov.io/gh/cerihughes/Sentinel/branch/master)

# Sentinel

_Sentinel_ is an iOS version of the classic 1980s game [_The Sentinel_](https://en.wikipedia.org/wiki/The_Sentinel_(video_game)) 

The project was primarily started to get a better understanding of how _SceneKit_ works, and also to serve as a working example for anyone else looking to understand more about _SceneKit_.

It's very much a work in progress and doesn't (currently) accurately reflect the rules and gameplay of the original. The original 8-bit version used standard left-right-up-down keyboard controls to move a pointer on screen which resulted in a much slower way of moving around than current touch screen UIs allow. As such, the intention isn't to fully replicate the original rules, but to provide a harder gameplay engine to compensate for the speedier control mechanism.

## Project Setup
The repository doesn't host the Xcode project file - this is generated using [_XcodeGen_](https://github.com/yonaskolb/XcodeGen). The easiest way to install this is with [_Homebrew_](https://brew.sh/).

The project also relies on [_SwiftLint_](https://github.com/realm/SwiftLint). The project file assumes that the `swiftlint` executable is installed in the default _Homebrew_ directory: `/opt/homebrew/bin/` (on Apple Silicon-based machines)

Assuming you're using Homebrew, the following steps will get you up and running in _Xcode_:
- install _XcodeGen_ with `brew install xcodegen`
- open the `project.yml` file
  - update the `DEVELOPMENT_TEAM` variable to use your own (if you have one)
  - if you haven't installed _SwiftLint_ using _Homebrew_ (or you use a different _Homebrew_ directory), update the `script` entry under `postCompileScripts` to reflect this
- generate project file with `xcodegen`
- open the project with `open Sentinel.xcodeproj`

## Architectural Overview 
The game uses the following self-contained screens, each based on the MVVM pattern. Using an MVVM-like architecture with _SceneKit_ may not be the best way forward, but I wanted to try it out as a learning exercise.

The following "screens" currently exist:

### Intro
An animation / soundtrack to introduce the game

### Lobby
Allows the player to select any level in the game. The finished version will either get rid of this screen, or only allow entry into the next playable level.

### Game Preview
Shows the player the whole terrain and the locations of all objects. This may be redundant as this behaviour is also in the Game screen. The original intention of this screen was to also show the "detection distance" of all opponents (i.e. how "far" they can see) but this concept has currently been removed.

### Game
Allows playback of a single level. 

### Game Summary
Presents a summary of the level once complete.

### Staging Area

The "main" source tree also contains a number of `TestScenarios`. These are real terrains with pre-defined data in them that I use as high level system tests. They set up a terrain, add players and opponents and make sure that the gameplay engine behaves properly with the given items.

"Running" a test scenario is as simple as updating the `AppDelegate` to replace the default "screen token" (`Navigation.intro`) with a test scenario-specific one (e.g. `Navigation.multipleOpponentAbsorbScenario`)

### MultipleOpponentAbsorb
Sets up a terrain with 1 sentinel, 3 sentries and a lot of rocks. Ensures that the gameplay absorption rules are adhered to.

## Playing the Game

Navigate from the Intro to the Lobby by tapping the screen.
In the Lobby, choose a level by scrolling left and right and tapping the selection.
The Game Preview will show the level. Tap to proceed.
The Game screen will also show the overview. Tap again to "enter" the terrain.

An explanation of the rules is out of scope for this document - it's assumed that you already know the concepts of the game. The [_Wikipedia_ page](https://en.wikipedia.org/wiki/The_Sentinel_(video_game)) is a good resource if you don't know how to play.

Once in the terrain, the following controls can be used (note that different control mechanisms may replace these in future):
- Look around by "dragging" the screen to move the camera.
- Long press on a square to build or absorb (you need to be able to see the ground to do either). With your finger still held down:
  - drag down to absorb
  - drag up to build a rock
  - drag left to build a tree
  - drag right to build a synthoid
- Double tap on a synthoid to teleport into it
