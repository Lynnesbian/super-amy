# Super Amy
**By Lynnear Software!**

![Super Amy's logo!](https://raw.githubusercontent.com/deleeciousCheeps/super-amy/master/res/img/logo.png "Super Amy's logo!")

**[Available on itch.io!](https://deleeciouscheeps.itch.io/super-amy?password=super-amy)**

Super Amy is a 2D platformer game written in LÖVE. You play as Amy on a quest to meet up with your girlfriend!

![A screenshot of the game](https://raw.githubusercontent.com/deleeciousCheeps/super-amy/master/res/img/screenshot.png "A screenshot of the game")

This game is **still in early alpha**, so don't expect much from it in the way of playability just yet.

## Getting the game
### Cloning this repository
Install git, and use this command:
`git clone --recursive -j4 https://github.com/deleeciousCheeps/super-amy`
Don't forget the `--recursive`! Otherwise, the game will fail to run. This is because the game relies on [several libraries](#libraries-used) which are externally hosted as Git projects.
### Just running the game
The easiest way to get the game straight away is by [downloading it from itch.io](https://deleeciouscheeps.itch.io/super-amy?password=super-amy). However, the itch version is not always the latest available version.

If you want to get Super Amy from GitHub instead (and ensure you have the latest available version), click "Clone or download" at the top of the page, and then "Download ZIP". Extract the zip file, and run "love ." in the resulting directory. You'll need to have [LÖVE](https://love2d.org/) version 11.1 installed.

## Necessary software
To run this game, you'll need [LÖVE](https://love2d.org/) version 11.1. Versions below 11 won't work, and later versions might introduce breaking changes. 11.0 *should* be fine, but I haven't tested it.

To edit the provided files, you'll need the following:
- [GIMP](https://www.gimp.org/) v2.10 or later for the .xcf files in `res/img`
- [DefleMask](http://www.deflemask.com/) for the .dmf files in `res/mus/deflemask`

All of this software is available for Windows, Mac, and Linux, free of charge.

## Running the game
After installing LÖVE, there are two ways to run the game.
- Compress the entire directory as a zip and rename it to "super-amy.love", then run `love super-amy.love`
- Open the directory in your terminal/command prompt and type `love .`

## Licence
### Libraries used
This project makes use of the following libraries:
- vrld's [Moonshine](https://github.com/vrld/moonshine) ([MIT Licence](https://github.com/vrld/moonshine#license))
- kikito's [Middleclass](https://github.com/kikito/middleclass) ([MIT Licence](https://github.com/kikito/middleclass/blob/master/MIT-LICENSE.txt))
- rxi's [json.lua](https://github.com/rxi/json.lua) ([MIT Licence](https://github.com/rxi/json.lua/blob/master/LICENSE))
- itraykov's [profile.lua](https://bitbucket.org/itraykov/profile.lua/) (No licence provided)

### Super Amy
This project, including all music and graphics, but *not the included libraries*, is licenced under the [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) licence. The text of this licence is available in the "COPYING" file in the root directory of this project.

![CC BY 4.0](https://licensebuttons.net/l/by/4.0/88x31.png "CC BY 4.0")