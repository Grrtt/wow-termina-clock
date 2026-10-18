# Termina Clock

A just-for-fun Majora's Mask–style clock for the final days of the WoW Forever beta before the wipe.

![The clock running in WoW, with a white arch, green day diamond, sun, and orbiting light.](docs/images/clock-in-game.png)

The clock counts down in real time. The diamond shows `1st`, `2nd`, or `Final` during the last 72, 48, and 24 hours. The sun or moon marks the hour; the small orbiting light shows progress through that hour.

Five bells warn before dawn and dusk. Before a new day, the world view shrinks inward, then returns as a black dawn screen announces the day and hours remaining. Other game audio is muted during that animation and restored afterward. The UI stays at its normal size. Bells become more frequent during the final six hours.

The intended target is the beta wipe. October 21, 2026 is the announced last full testing day, but an exact wipe hour has not been confirmed. The current default is a placeholder at the end of October 21 Pacific time, **October 22 at 07:00 UTC**. The stress test's 2:00 p.m. PDT start is not a confirmed wipe time.

Drag the clock to move it, and hover over it to see the countdown and target time. Use `/termina` for commands.

- `/termina test dayend` previews the bells and dawn sequence without changing the deadline.
- `/termina test 1st`, `/termina test 2nd`, and `/termina test final` preview the day labels.
- `/termina dawn first`, `/termina dawn second`, and `/termina dawn final` preview the black dawn screens.
- `/termina test stop` cancels a preview and restores the view and audio.
- `/termina sound`, `/termina screen`, and `/termina transitions` toggle the effects.
