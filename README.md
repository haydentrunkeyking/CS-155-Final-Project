# CS-155 Final Project

## Hangman

This is an LC-3 hangman game for my CS-155 final project.

The program chooses one hardcoded word using a keyboard-loop random number idea. It gets a typed letter from the user, echoes it, and checks it against the known hangman word in memory. A comparison is then done between the character pushed by the user and every character in the hardcoded word.

That comparison determines whether a character in the display word changes or whether the player gets a strike.

The program accounts for uppercase letters by converting them to lowercase before checking the guess. Each loop prints a new hangman graphic based on a strike counter. The strike counter increments the hangman graphic pointer address, and each subsequent address has a full hangman image with the image gaining a limb after each wrong guess.

The program checks for win and lose conditions toward the end of every loop. The win condition is based on whether the display word still contains underscores. The lose condition is based on whether the strike counter has reached the maximum number of strikes.

After the player wins or loses, the program loops and picks a new random word.
