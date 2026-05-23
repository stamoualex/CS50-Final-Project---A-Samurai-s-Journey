# YOUR PROJECT TITLE

A Samurai’s Journey

## Video explaining my project:  https://www.youtube.com/watch?v=RjWfelu9tKM

### Description:

This is my final project for the CS50x course on edX, which was created using the Lua programming language and the love engine/framework. The goal of my project was to create a fun and functional game using the lessons I learned while taking the CS50x course. My game is a 2D platformer with multiple levels and obstacles (just like games in Scratch!) using Lua with Love. You play as a samurai who starts in a mountain terrain and explores a volcano and an ancient tomb to reach a treasure room containing the “Samurai’s Secret”. I chose a game with lua because I’ve always loved games, and creating my own would be a very fun project to do for a final project/conclusion to this course.
x
### MyPlatformer folder

Inside the folder titled “MyPlatformer” shown in the video above, there is:
-A main.lua file
This contains all of my code and is the most important part of the folder

-A folder titled “Sprites” containing my character sheet for the samurai(credit to this at the bottom)
I use a sprite sheet to animate my character, so the game would look smoother while playing

-Another folder titled “Fonts” containing a font called Pirata-One, which I used on the first level to explain the controls

### Code explanation/walkthrough

My code starts with constants like player gravity, spike height, colors, etc. It also contains two constants called WindowHeight and WindowWidth that set a baseline height so it’s much easier later to write the height for platforms and the roof/floor(similar to a function). After that large 100-line chunk of code, I used the line of code “local Level_Data =” to create the levels and decide where to place the platforms through trial and error and various tweaks, due to the new x and y-axis system that Lua uses. After this, some level background colors are defined and the spike/platform collision mechanics. It then creates the character through the “Sprites” folder and the Samurai sprite sheet inside, and some “if else” loops to help bug fix, which were very useful during the game’s creation. It then extracts the font from the “Fonts” folder, writes the message that explains the controls at the start of the game and sets the color, and makes it so that the text only shows on the furst level. After that, the controls are set, like space to jump and WASD or arrow keys to move(you can also use the arrow keys “up arrow” to jump, which isn’t listed in the text on level 1 because it coudn’t fit on the screen). Finally, animations are programmed in the code(credits to this below), attempts are programmed and placed at the top left, text is added on the last level, and touching the altar on the last level puts you on the end screen, which says your final attempts(also, you can press esc to exit the game).

### Gameplay and controls

In my game, you use WASD/arrow keys to move and the up arrow or space to jump. You jump on different platforms just like in every other 2d platformer, and when you touch an obstacle, which in my game are spikes and lava, you reset to the start of the level. To get to the next level, you simply have to go from the left side which you start at to the right side and touch the end. Y  ou start in a mountain area where you are ascending to the peak through different platforms. At the bottom of the mountain levels, there are spikes that reset you to the start if you touch them. Once you reach the peak, you jump into a volcano, which in my game appears as lava which doesn’t actually kill you; it progresses you to the next level, which is inside the volcano. Once inside the volcano, you once again jump through platforms, but this time the ground is lava that, if you touch, restarts you to the beginning. After that, you enter an ancient tomb where you have to jump over spikes instead of simply avoiding falling off a platform and hitting them. Finally, you reach the treasure room, and once you touch the altar, an end screen pops up that says “You have found the secret…” and displays your final attempt count.

### Design challenges

The hardest part of making this game was figuring out how to add the spike/platform collision. I watched an endless number of YouTube tutorials, but couldn’t find one that applied to my code. I made a crude template and then used Google Gemini to help bug fix and make the collision work smoothly. Another challenge was making it so you don’t die when you touch the lava on the level where you jump into the level. This one was much simpler tho and after changing a few lines of code and adding a seperate chunk of code for this specific level, it worked.

### Credits

Google Gemini Flash was used for the spike and platform collision
I downloaded the samurai sprite sheet from a website called CraftPix.net titled Samurai Pack, which is licensed as free to download and free to use in projects
This is the URL: https://craftpix.net/freebies/free-samurai-pixel-art-sprite-sheets/