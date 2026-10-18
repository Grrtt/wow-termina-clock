# Termina Clock

A just-for-fun Majora's Mask–style countdown to the end of the WoW Forever Beta.

## Install from GitHub on Windows

1. On [the repository page](https://github.com/Grrtt/wow-termina-clock), select **Code**, then **Download ZIP**.
2. In File Explorer, right-click the downloaded ZIP and select **Extract All**. Open the extracted `wow-termina-clock-main` folder.
3. Copy the **`TerminaClock` folder inside it** into the beta client's `Interface\AddOns` folder. For example:

   ```text
   C:\Program Files (x86)\World of Warcraft\_classic_beta_\Interface\AddOns
   ```

   If WoW is installed on another drive or in another folder, use that installation's `_classic_beta_\Interface\AddOns` folder instead.

4. Check that the addon file ends up at the following path inside your WoW installation. Copy the inner addon folder, not the entire `wow-termina-clock-main` folder.

   ```text
   _classic_beta_\Interface\AddOns\TerminaClock\TerminaClock.toc
   ```

5. In WoW, type `/reload`. Open **AddOns** from the game menu and enable **Termina Clock** if needed. If WoW marks it as outdated, enable **Load out of date AddOns**, then `/reload` again.
6. Type `/termina` to see the commands. Drag the clock to move it.

No Git or build tools are required. If you also use the separate stress-test client, repeat the folder-copy step in that client's `Interface\AddOns` folder.

![The clock running in WoW, with a white arch, green day diamond, sun, and orbiting light.](docs/images/clock-in-game.png)

The clock follows your computer's local time: dawn is **6:00 a.m.**, and dusk is **6:00 p.m.** The diamond shows `1st`, `2nd`, and `Final` on the last three local days leading into the deadline. The sun or moon marks the local hour; the small orbiting light shows progress through that hour. Everyone's countdown ends at the same moment, so the final day can be shorter than 24 hours.

Warning bells lead into local dawn and dusk. Before the second and final dawns, the render area becomes smaller in four steps, with black borders moving inward. The camera and UI stay unchanged. The previous render area returns as the dawn animation starts.

> [!IMPORTANT]
> **Render-area behavior during combat:** The render area does not scale down during combat, but the outer black bars still move inward. Once you leave combat, the render area starts shrinking.

> [!TIP]
> **If the render area stays reduced:** After installing the latest update, run `/reload`, then `/termina screen restore`. This resets the render area to full screen and disables the effect. The addon verifies restoration and retries if WoW delays applying it. Use `/termina screen` to enable the effect again before testing.

At dawn, a black screen announces the day and actual rounded hours remaining. Other game audio is muted during the dawn screen and restored afterward. Dusk shows a translucent night title without muting game audio. Bells become more frequent during the final six hours.

> [!IMPORTANT]
> **Gameplay continues during the dawn cutscene:** You can still be attacked and interact with the world while the black screen covers your view.

The clock ends at the **estimated stress-test finish: October 21, 2026, at 5:00 p.m. PDT** (October 22 at 00:00 UTC). That's a guess of three hours after the announced 2:00 p.m. PDT start. [Blizzard says the test lasts a few hours](https://us.forums.blizzard.com/en/wow/t/wow-forever-stress-test-october-21/2383617), but hasn't announced an exact end time. Custom deadlines stay unchanged.

## Change the countdown deadline

The stress-test end time is not known. The default is an estimate, so you may want to change it when Blizzard announces a time, if the test runs longer, or if you prefer a different estimate.

The command is `/termina deadline <Unix timestamp in seconds>`. You can get that number inside WoW:

1. Choose the date and time **in your computer's local time zone**. For example, this prints the timestamp for October 21, 2026, at 8:00 p.m. locally. Change the numbers to your chosen time; `hour` uses the 24-hour clock.

   ```text
   /run print(time({year=2026,month=10,day=21,hour=20,min=0,sec=0}))
   ```

2. Enter `/termina deadline` followed by the number printed in chat. Replace `<number>` below with that number, without the angle brackets:

   ```text
   /termina deadline <number>
   ```

3. Hover over the clock to check the new target in local time. The change takes effect immediately and is saved across reloads; the local day labels and transitions adjust to it.

To restore the current default estimate—October 21 at 5:00 p.m. PDT—use:

```text
/termina deadline 1792627200
```

The three day labels, shown here as generated artwork previews:

| First day | Second day | Final day |
| --- | --- | --- |
| ![Clock artwork showing 1st.](docs/images/clock-first-preview.png) | ![Clock artwork showing 2nd.](docs/images/clock-second-preview.png) | ![Clock artwork showing Final.](docs/images/clock-final-preview.png) |

The black dawn transition announces the day and hours remaining for your time zone. This is a generated preview of its title screen:

![Generated dawn title showing Dawn of The First Day and a placeholder for the locally calculated hours remaining.](docs/images/dawn-preview.png)

Drag the clock to move it, and hover over it to see the countdown and target time. Use `/termina` for commands.

- `/termina test dayend` previews the bells and dawn sequence without changing the deadline.
- `/termina test 1st`, `/termina test 2nd`, and `/termina test final` preview the day labels.
- `/termina dawn first`, `/termina dawn second`, and `/termina dawn final` preview the black dawn screens.
- `/termina dusk first`, `/termina dusk second`, and `/termina dusk final` preview the evening titles.
- `/termina test stop` cancels a preview and restores the view and audio.
- `/termina screen restore` resets the render area to full screen and disables the render-area effect. Restoration retries automatically if WoW delays applying it.
- `/termina sound`, `/termina screen`, and `/termina transitions` toggle the effects.
