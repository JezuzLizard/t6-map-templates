# Compiling and Debugging
Run `compile.py` and run this from the in-game console:
```
loadmod ""; loadmod zm_frontend
```

To debug, use this command:
```
exec frontend_debug
```

# Progress
- [x] Load into the map with zm core
- [x] Add spawners
- [x] Add M14 wallbuy
- [ ] Add path nodes
- [ ] Re-add sound effects
	- Should just be weapon, zombie and player move sounds, also the money sound when you buy something
	- The player knifing & mk2 sounds are already in the map
- [ ] Fix spawner angles (currently one allows them fall out of the map)
- [ ] Fix game over screen being under the map (or wherever you die at)
- [ ] Make it so you can't go through the door to the conference room
- [ ] Make it so you can't get on top of the desks or metal fences
- [ ] Make the spawn window impossible to break
- [ ] Add quick revive to the control panel next to M14
- [ ] Add semtex wallbuy on the outside of the conference room wall
- [ ] Add the Ray Gun Mk2 as a reward for getting to 30