# Xenoverse: Per Aspera Ad Astra - Source Code Repository

## Custom changes

This custom build retains the original game, creator credits, branding, and usage guidelines. The changes made here are:

- The shiny rate is set to **1/128**.
- An in-game save editor is enabled through **F9** while on a normal map. It uses the game's debug screens to edit party and PC Pokémon data; use the normal in-game Save command to write changes.

Please back up `Game.rxdata` before using the save editor.

## Update check

The game reads [`Xenoverse/UpdateManifest.txt`](Xenoverse/UpdateManifest.txt) once at startup. If its version is newer than the local `GAME_VERSION`, the title screen shows an update command. Selecting it asks for confirmation, downloads the configured update package, and hands the installation to [`UpdateGame.ps1`](Xenoverse/UpdateGame.ps1) after the game exits. Network failures are ignored so the game remains usable offline.

Published update packages should use the stable asset name `Xenoverse-update.zip`. The archive may contain the runnable `Xenoverse` folder, a single named folder containing it, or the game files directly. Saves and local settings are preserved during the merge.

To test the title-screen update command locally, temporarily set `XENOVERSE_UPDATE_TEST_MODE` to `true` in `256_UpdateChecker.rb`. This uses version `1.5.6` without contacting GitHub; set it back to `false` before publishing.

## Mystery gifts

The offline Mystery Gift catalog is stored in [`Xenoverse/Data/MysteryGifts.csv`](Xenoverse/Data/MysteryGifts.csv) and is handled by [`249_LocalMysteryGifts.rb`](Xenoverse/Data/Scripts/249_LocalMysteryGifts.rb). Published codes are checked locally before the original remote request. Every catalog entry uses `9999-12-31` as its expiration date, so these local gifts do not expire.

Cards shown without a published code use a local `TW1TCH_...` alias. All catalog gifts are level 5, use a Cherish Ball, receive random IVs and a normal randomly generated nature, have zero EVs, use their default level-up moves, have no custom nickname, and use the current trainer as OT.

### Published codes

| Code | Gift |
| --- | --- |
| `BeehiveworldTotodileShinyPartner` | Shiny Totodile |
| `MasgotHappyGlobalLaunch2021` | Masgot Sound-Style |
| `IGGLYLOVE14` | Retro Igglybuff |
| `B33FL3ADRIVE2021` | Shiny Beefle |
| `EEVEE2XENOVERSE` | Retro Eevee |
| `EXEGGEASTER2021` | Retro Exeggcute |
| `LITTENORANGE2021` | Shiny Litten |
| `MIURATRIBUT3` | Shiny Absol |
| `HUNTAIL2003` | Shiny Huntail |
| `WEEDLE7ANNIVERS4RY` | Beta Weedle |
| `BRILLIANTL34F3ON` | Shiny Brilliant Leafeon |
| `SHININGGL4C3ON` | Shiny Shining Glaceon |
| `V1NT4G3CYNDA4U` | Retro Shiny Cyndaquil |
| `H4PPY29ST4RK` | Shiny Sharpedo |

### Generated local aliases

| Code | Gift |
| --- | --- |
| `TW1TCH_RETRO_STARYU` | Retro Staryu |
| `TW1TCH_SHINY_RETRO_TOTODILE` | Shiny Retro Totodile |
| `TW1TCH_SHINY_RETRO_EEVEE` | Shiny Retro Eevee |
| `TW1TCH_SHINY_RETRO_EXEGGCUTE` | Retro Shiny Exeggcute |
| `TW1TCH_SHINY_LEAFEON` | Shiny Leafeon |
| `TW1TCH_SHINY_PIPLUP` | Shiny Piplup |
| `TW1TCH_SHINY_CHIMCHAR` | Shiny Chimchar |
| `TW1TCH_SHINY_TURTWIG` | Shiny Turtwig |
| `TW1TCH_RETRO_GASTLY` | Retro Gastly |
| `TW1TCH_RETRO_WEEDLE` | Retro Weedle |
| `TW1TCH_SHINY_PAWNIARD` | Shiny Pawniard |
| `TW1TCH_SHINY_SQUIRTLE` | Shiny Squirtle |
| `TW1TCH_SHINY_BULBASAUR` | Shiny Bulbasaur |
| `TW1TCH_SHINY_CHARMANDER` | Shiny Charmander |
| `TW1TCH_SHINY_BRILLIANT_LEAFEON` | Shiny Brilliant Leafeon |
| `TW1TCH_SHINY_SHINING_GLACEON` | Shiny Shining Glaceon |
| `TW1TCH_SHINY_DITTO` | Shiny Ditto |
| `TW1TCH_SHINY_HISUIAN_GROWLITHE` | Shiny Hisuian Growlithe |
| `TW1TCH_RETRO_SHINY_BULBASAUR` | Retro Shiny Bulbasaur |
| `TW1TCH_RETRO_SHINY_CHARMANDER` | Retro Shiny Charmander |
| `TW1TCH_RETRO_SHINY_LARVITAR` | Retro Shiny Larvitar |
| `TW1TCH_RETRO_SHINY_DRATINI` | Retro Shiny Dratini |
| `TW1TCH_RETRO_SHINY_HOPPIP` | Retro Shiny Hoppip |
| `TW1TCH_RETRO_SHINY_SQUIRTLE` | Retro Shiny Squirtle |
| `TW1TCH_RETRO_SHINY_NOCTOWL` | Retro Shiny Noctowl |
| `TW1TCH_RETRO_SHINY_UNOWN` | Retro Shiny Unown |
| `TW1TCH_SHINY_PLATINUM_LUCARIO` | Shiny Platinum Lucario |

## Disclaimer
Hello everyone and welcome to Xenoverse: Per Aspera Ad Astra's source code repository. 
Please understand that this repository is not meant to be maintained and you should not expect to find documentation on the contents of this repository.
Moreover, by using or referring to this repository you're acknowledging and agreeing to the guidelines at this link:
[Xenoverse: Per Aspera Ad Astra Code Access and Mods Guidelines](https://gitlab.com/weedleteam/Xenoverse-Source/-/blob/main/CodeAndModsGuidelines.md)

Useful links:
[Beehive Studios' Discord Server](https://gitlab.com/weedleteam/Xenoverse-Source/-/blob/main/CodeAndModsGuidelines.md) - (**Please do not discuss mods development there, as it's a general-purpose server**. If you do, you will be banned.)
