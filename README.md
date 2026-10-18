# Termina Clock

A just-for-fun Majora's Mask–style countdown to the end of the WoW Forever Beta.

![The clock running in WoW, with a white arch, green day diamond, sun, and orbiting light.](docs/images/clock-in-game.png)

The clock counts down in real time. The diamond shows `1st`, `2nd`, or `Final` during the last 72, 48, and 24 hours. The sun or moon marks the hour; the small orbiting light shows progress through that hour.

Five bells warn before dawn and dusk. Before a new day, the world view shrinks inward, then returns as a black dawn screen announces the day and hours remaining. Other game audio is muted during that animation and restored afterward. The UI stays at its normal size. Bells become more frequent during the final six hours.

The clock ends at the **estimated stress-test finish: October 21, 2026, at 5:00 p.m. PDT** (October 22 at 00:00 UTC). That's a guess of three hours after the announced 2:00 p.m. PDT start. [Blizzard says the test lasts a few hours](https://us.forums.blizzard.com/en/wow/t/wow-forever-stress-test-october-21/2383617), but hasn't announced an exact end time. Custom deadlines stay unchanged.

The three day labels, shown here as generated artwork previews:

| First day | Second day | Final day |
| --- | --- | --- |
| ![Clock artwork showing 1st.](docs/images/clock-first-preview.png) | ![Clock artwork showing 2nd.](docs/images/clock-second-preview.png) | ![Clock artwork showing Final.](docs/images/clock-final-preview.png) |

The black dawn transition announces the day and hours remaining. This is a generated preview of its title screen:

![Dawn of The First Day, with 72 Hours Remain on a black background.](docs/images/dawn-preview.png)

Drag the clock to move it, and hover over it to see the countdown and target time. Use `/termina` for commands.

- `/termina test dayend` previews the bells and dawn sequence without changing the deadline.
- `/termina test 1st`, `/termina test 2nd`, and `/termina test final` preview the day labels.
- `/termina dawn first`, `/termina dawn second`, and `/termina dawn final` preview the black dawn screens.
- `/termina test stop` cancels a preview and restores the view and audio.
- `/termina sound`, `/termina screen`, and `/termina transitions` toggle the effects.
