# 3-DPoleZero
Creates a 3-D Pole Zero Plot and a GIF to show it off. Also generates the magnitude response plot

Creates a pole-zero plot in 3-D and then makes an animated
GIF titled 'AnimatedPoleZero.gif'
	Parameters:
					pole: a vector of poles for the plot
					zero: a vector of zeroes for the plot
  Output:
          f:  The frames generated to be used in the GIF
              They can be played back from MATLAB with
              movie(f);
  Figures Created:
          Fig1 - Used to animate the GIF
          Fig2 - The 2-D heat-map of the pole-zero plot
                 (not too helpful because you can't see zeroes)
          Fig3 - The scaterplot of the resulting Magnitude Response

