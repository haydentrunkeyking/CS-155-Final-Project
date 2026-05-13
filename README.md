# CS-155 Final Project

## Hangman

This is an LC-3 hangman game for my CS-155 final project.

The program chooses one hardcoded word using a keyboard-loop random number idea. It gets a typed letter from the user, echoes it, and checks it against the known hangman word in memory. A comparison is then done between the character pushed by the user and every character in the hardcoded word.

That comparison determines whether a character in the display word changes or whether the player gets a strike.

The program accounts for uppercase letters by converting them to lowercase before checking the guess. Each loop prints a new hangman graphic based on a strike counter. The strike counter increments the hangman graphic pointer address, and each subsequent address has a full hangman image with the image gaining a limb after each wrong guess.

The program checks for win and lose conditions toward the end of every loop. The win condition is based on whether the display word still contains underscores. The lose condition is based on whether the strike counter has reached the maximum number of strikes.

After the player wins or loses, the program loops and picks a new random word.

## LC-3 Simulator

This project was built and tested using LC3Tools, a cross-platform set of tools used to write, assemble, and simulate LC-3 programs.

LC3Tools can be downloaded here:

https://github.com/chiragsakhuja/lc3tools/releases

### Installation Instructions

Download the version for your operating system from the LC3Tools releases page.

- **Windows:** Download `LC3Tools-Setup-VERSION.exe`, then double-click the file to install LC3Tools.
- **macOS:** Download `LC3Tools-VERSION.dmg`, double-click the DMG file, then drag `LC3Tools.app` into the Applications folder.
- **Linux:** Download `LC3Tools-VERSION.AppImage`, mark it as executable with `chmod +x`, then run the AppImage. Linux requires GLIBC version 2.19 or newer.

Additional LC3Tools documentation and command line instructions can be found here:

https://github.com/chiragsakhuja/lc3tools.git
