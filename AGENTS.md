# Xenoverse: Per Aspera Ad Astra - Project Context

## Project layout

- The runnable game is under `Xenoverse/`.
- `Xenoverse/Game.ini` loads `Data/Scripts.rxdata`.
- In this source release, `Data/Scripts.rxdata` is a small loader that loads
  the extracted `Data/Scripts/*.rb` files. The extracted Ruby files are the
  active source and are loaded in filename order.
- `Game.exe` and `Game_n.exe` are byte-for-byte identical in the current
  snapshot and use the same `Game.ini`, DLLs, graphics, and script directory.
- `CodeAndModsGuidelines.md` is part of the upstream repository and must be
  followed for any mod distribution or publication.

## Important script locations

- `Data/Scripts/001_Settings.rb`: global settings, including
  `SHINYPOKEMONCHANCE = 512` (exactly 1/128 because the shiny threshold is
  out of 65536).
- `Data/Scripts/048_Scene_Map.rb`: map input and the F9 save-editor hotkey.
- `Data/Scripts/084_PField_Field.rb`: wild-Pokemon generation and the extra
  Shiny Charm retry.
- `Data/Scripts/102_PokeBattle_Pokemon.rb`: Pokémon fields and natural shiny
  calculation (`shinyflag`, `natureflag`, `iv`, and `ev`).
- `Data/Scripts/122_PScreen_Storage.rb`: storage model and legacy storage
  debug editor.
- `Data/Scripts/194_Menu_Screen.rb` and `195_NewMenu_Scene.rb`: custom radial
  and new menu implementations. These override the older pause-menu path.
- `Data/Scripts/223_NewParty.rb`: active party screen and Pokémon debug UI.
- `Data/Scripts/246_AlolaForms.rb`: later active daycare egg generator.
  Eggs use the natural PID shiny check and receive one extra retry with the
  Shiny Charm.
- `Data/Scripts/255_XenoverseSaveEditor.rb`: in-game save editor entry point.

## Current save-editor behavior

- On a normal map, press F9 to open the editor chooser.
- `Party Pokemon` opens the existing party debug screen.
- `PC Boxes` opens the storage move screen, allowing boxed Pokémon, party
  Pokémon, and their locations to be edited.
- The editor temporarily sets `$DEBUG = true` only while those existing debug
  screens are open, then restores the prior value with `ensure`.
- The existing debug UI can change shiny override, nature override, EVs, IVs,
  and many other fields. Use destructive options such as Delete carefully.
- Changes are written using the normal in-game Save command. Back up the
  user's `Game.rxdata` before editing.
- The game uses Ruby Marshal save data. Prefer the in-game editor over an
  external binary save editor unless a real save has been validated against
  the exact runtime classes.

## Development workflow

- Preserve unrelated and pre-existing worktree changes.
- Use `apply_patch` for source edits and inspect the affected files before
  changing them.
- Validate source wiring and calculations statically before claiming success.
- Do not launch either game executable automatically. Runtime GUI checks need
  explicit user authorization.
- Do not commit, push, deploy, or publish unless explicitly requested. The
  planned commit is intentionally deferred until after the user renames the
  project folder and restarts the session.
- Do not rebuild or replace `Data/Scripts.rxdata` unless the loader mechanism
  changes; the current loader reads the extracted script folder directly.
