# Termina Clock

A WoW addon that recreates the N64 Majora's Mask clock: pixelated ivory arch, gold spokes, green day diamond, day lettering, sun/moon hour markers, and an orbiting minute light. Includes bell, dawn, and tick audio from [ZeldaSounds](https://noproblo.dayjo.org/zeldasounds/mm/). The audio belongs to its original rights holders.

## Screenshots and previews

The clock running in the WoW beta, cropped to exclude chat and account details. The `--` label appears before the countdown enters its final 72 hours.

![Termina Clock running over the WoW game world, with the ivory arch, green day diamond, red sun, and orbiting minute light.](docs/images/clock-in-game.png)

The following images are generated artwork previews, not in-game captures:

| First day | Second day | Final day |
| --- | --- | --- |
| ![Clock artwork preview showing the 1st label.](docs/images/clock-first-preview.png) | ![Clock artwork preview showing the 2nd label.](docs/images/clock-second-preview.png) | ![Clock artwork preview showing the Final label.](docs/images/clock-final-preview.png) |

![Generated dawn title preview, with Dawn of The First Day and 72 Hours Remain on a black background.](docs/images/dawn-preview.png)

## Install

1. Download or clone this repository, then copy `TerminaClock` into your beta client's `Interface/AddOns` directory.
2. Restart WoW after installing new textures or sounds. Enable **Termina Clock** under **AddOns**. If needed, enable **Load out of date AddOns**.
3. Drag the clock into position. Hover over it to see the countdown and target in your computer's local time.

The manifest targets Forever interface `16001` and Classic Era `11509`. In-game appearance, viewport behavior, and sound mixing still need verification in the beta client.

## Countdown

The default target is **October 22, 2026, at 07:00 UTC**, the end of October 21 in US Pacific daylight time. This is an estimate based on the announced last full testing day, not a confirmed shutdown time. The addon does not detect server shutdown.

The countdown uses real hours. At 72 hours remaining, the virtual Termina clock reads 6:00 a.m. on the first day. The second and final dawns occur at 48 and 24 hours remaining. Before the final 72 hours, the diamond displays `--`. The hour marker advances in discrete steps, and the minute light circles once per real hour.

## Bells and screen transitions

Before each ordinary dawn and dusk, five bells toll at 30, 24, 18, 12, and six minutes remaining until the boundary. These match the N64 game's 5:30, 5:36, 5:42, 5:48, and 5:54 times, expressed in real minutes for this countdown.

Before the second and final dawns, the rendered WoW world shrinks to 95%, 90%, 85%, and 80% of its original width and height at the last four tolls. Black borders fill the margins. The interface stays at its normal size and position. The effect does not scale or animate `UIParent`. The effect holds each step until the next one and restores the original world-frame anchors at the start of the dawn transition or on cancellation. If the native world frame has no explicit anchors, restoration explicitly fills the screen. It does not move the camera or change camera settings. Viewport changes are skipped during combat; a pending restoration runs when combat ends. Other addons that control the world viewport may conflict with this effect.

At 72, 48, and 24 hours remaining, a 5.2-second full-screen dawn transition fades to black, displays the day and hours remaining, plays the dawn effect, and fades back. These screens are always used when enabled; the original game's location-specific choices between title cards and full transitions are not mapped to WoW locations.

During the final six hours, bells toll every 10 real minutes, increasing to every five minutes in the final hour and every three minutes in the final half hour. The endpoint gets a final bell. The final hours do not shrink the viewport. This version includes sound effects, not the Final Hours background music. Automatic hourly ticks are an addon adaptation.

The schedule and screen-shrink steps follow the [reconstructed N64 event code](https://github.com/zeldaret/mm/blob/main/src/overlays/actors/ovl_En_Test4/z_en_test4.c). The original game runs its clock much faster than real time.

## Audio

The dawn screen temporarily sets WoW's effects, music, ambience, and dialogue volumes to zero. Its own sound plays through Master, so master sound must be enabled. Other addons that play directly through Master can still be heard.

Previous volumes are restored when the transition ends, is canceled, or you leave the world. Changes you make during the transition take priority. Saved recovery settings restore muted channels after a reload or interrupted session. The overlay does not capture mouse or keyboard input.

Hiding the clock does not disable automatic sounds or dawn transitions. Use the corresponding toggles below. Logging in, changing the deadline, or returning after a pause does not replay missed cues.

## Commands

| Command | Action |
| --- | --- |
| `/termina show` or `/termina hide` | Show or hide the clock. |
| `/termina lock` | Toggle position locking. |
| `/termina scale 1.2` | Set scale from 0.5 to 3. |
| `/termina deadline 1792652400` | Set the target Unix timestamp in seconds. |
| `/termina sound` | Toggle automatic sounds. |
| `/termina screen` | Toggle the pre-dawn screen-shrink effect. |
| `/termina screen test` | Preview the full corrected end-of-day sequence. |
| `/termina transitions` | Toggle automatic black dawn screens. |
| `/termina test 1st` | Show the first-day clock label for 15 seconds. |
| `/termina test 2nd` | Show the second-day clock label for 15 seconds. |
| `/termina test final` | Show the final-day clock label for 15 seconds. |
| `/termina test bell` | Play only the bell; it no longer moves the camera. |
| `/termina test tick` | Play the ticking effect. |
| `/termina test dawn` | Preview the first-day dawn screen and audio muting. |
| `/termina dawn first` | Preview dawn of the first day. |
| `/termina dawn second` | Preview dawn of the second day. |
| `/termina dawn final` | Preview dawn of the final day. |
| `/termina test dayend` | Preview five bells, four screen-shrink steps, and the second dawn. |
| `/termina test dayend final` | Preview the sequence leading into the final dawn. |
| `/termina test stop` or `/termina dawn stop` | Cancel the preview and restore viewport and audio. |
| `/termina reset` | Restore the default target, position, scale, visibility, and effect settings. |

`/termina camera` and `/termina camera test` remain aliases for the screen-effect commands. An explicit opt-out from the old camera effect carries over to the screen-effect setting.

## End-of-day preview

The preview rings five bells at 0, 6, 12, 18, and 24 seconds. The gameplay view shrinks at the final four bells. The dawn transition begins at 30 seconds, and the sequence finishes after about 35 seconds. No deadline or clock-time setting changes. Preview audio plays even when automatic sounds are muted; the screen effect respects its toggle. Automatic countdown cues are suppressed during the preview.

## Verify

Run these commands from this directory:

```sh
lua tests/clock.lua
lua tests/sounds.lua
lua tests/viewport.lua
lua tests/dawn.lua
lua tests/preview.lua
lua tests/ui.lua
```

In WoW, run `/termina test dayend` outside combat. Check five tolls, four held screen-shrink steps, the dawn screen, and restoration of the viewport, UI, and audio. Repeat with `/termina test stop` halfway through, check the screen toggle, and check that the deadline remains unchanged. Verify settings after `/reload`.

## Artwork

The visual reference is the [N64 gameplay screenshot published by Famitsu](https://www.famitsu.com/article/202404/3273). These are recreated assets, not textures extracted from the game. Low-resolution textures use a limited palette and nearest-neighbor filtering. Run `python3 tools/build_art.py` with ImageMagick installed to rebuild the uncompressed 32-bit TGA textures and `preview.png` from the artwork in `art/`.

Day-label previews change only the diamond text, leaving the countdown, deadline, sun/moon, and sound schedule intact. `/termina test stop` restores the live label immediately; it also returns automatically after 15 seconds. `first` and `second` are aliases for `1st` and `2nd`.

## License and third-party assets

Source code and documentation use the [MIT license](LICENSE). See [third-party notices](THIRD_PARTY_NOTICES.md) for audio provenance, font attribution, and game imagery. Redistribution permission for the bundled game audio has not been established; resolve this before making the repository public or distributing a release.

See [Contributing](CONTRIBUTING.md) for development checks and asset-generation instructions.
