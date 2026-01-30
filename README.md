# A space shooter game project using the Love 2D Lua framework


## installation
install the Love 2D framework to run the game


## Controls
Control the spaceship with the keys "up", "left" and "right"
Jump wormholes with the key "w"

Avoid crashing into planets.

## Design of the code
there are three lua modules that work in a similar fashion  

- keyboard.lua, here most keyboard interaction is registered. Different game states can have different keys registered. 
- drawer.lua, here all the screen drawing is registered.
- action_runner.lua here all actions are registered and run each game tick. functions run in the action_runner shall return true if they are active, and false if they are spent and shall be discarded. The main game action is discarded when the player dies, and the wormhole action is discarded when the player has traveled the worm hole.  
