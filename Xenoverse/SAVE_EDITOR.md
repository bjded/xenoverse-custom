# Xenoverse in-game save editor

The source now exposes the game's existing debug editor from the pause menu.
The editor changes the live game objects, so it remains compatible with the
game's normal `Game.rxdata` save format.

## Use

1. Start the game and stand on a normal map where the player can move.
2. Press **F9**. This is a separate map hotkey and does not depend on the
   radial pause menu.
3. Choose `Party Pokemon` or `PC Boxes`.
4. Select a Pokemon and choose `Debug`.
5. Use the existing debug options:
   - `Nature`: choose a nature or remove the nature override.
   - `Shininess`: force shiny, force normal, or remove the shiny override.
   - `EV/IV/pID`: edit each EV or IV. EVs accept 0-255 per stat; IVs accept 0-31.
6. In `PC Boxes`, use the normal Move/Shift/Place controls to change the
   Pokemon's party/box and slot.
7. Return to the pause menu and use the normal `Save` command.

Make a copy of the existing `Game.rxdata` before editing. The game enforces
the per-stat EV input range, but the debug screen does not prevent a total EV
sum above the usual 510 limit, so keep the total at or below 510.

The feature is controlled by `XENOVERSE_SAVE_EDITOR_ENABLED` in
`Data/Scripts/255_XenoverseSaveEditor.rb`; set it to `false` to hide the pause
menu fallback and disable the F9 hotkey.
