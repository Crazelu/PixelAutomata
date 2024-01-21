# Pixel Automata Image Effects

In this experiment, I apply [Wolfram's Elementary Cellular Automaton](https://mathworld.wolfram.com/ElementaryCellularAutomaton.html) rules to generate effects on images. This was inspired by Daniel Shiffman's [Coding Challenge 179: Elementary Cellular Automata](https://youtu.be/Ggxt06qSAe4?si=hNo6Gik9pA86_iNg).

Applying this concept to images, the pixels become the cells. A state of 0 indicates that the pixel's color is reset to white/clear. And a state of 1 indicates that the pixel retains its color.

Isolates are used here to preprocess every selected image and to apply the cellular automaton rules to each row of pixel resulting in generations of cells which equal the height of the image.

## Demo 📷

<img src="https://raw.githubusercontent.com/Crazelu/pixelautomata/main/assets/demo.gif" width="280" alt="Example demo"> 