# Contributing

Keep changes compatible with WoW's Lua runtime and avoid dependencies unless the addon needs them. Run the existing checks before submitting a change:

```sh
python3 tools/check.py
```

The checks require Python 3 and Lua, including `luac`. To rebuild artwork, install ImageMagick and DejaVu Serif, then run:

```sh
python3 tools/build_art.py
python3 tools/build_previews.py
```

The tests use mocked WoW APIs. They do not verify the live game's rendering, sound mixing, protected-frame behavior, or interactions with other addons. Include the client build and manual verification results for changes to those behaviors.

Use the README's preview commands for manual tests. Avoid committing account data, chat logs, personal configuration, or uncropped desktop captures. Keep the provenance of new assets in `THIRD_PARTY_NOTICES.md`.
