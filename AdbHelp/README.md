# adb Help Reference for PowerAdb

This folder contains collected adb help output from different Android and adb versions. It serves as a reference when adding new PowerAdb commands, updating existing ones, or checking how adb behavior changed across API levels.

## What this folder contains

- Help text for adb commands and subcommands
- Version-specific examples grouped by command family such as shell, emu, logcat, and more
- Notes that focus on meaningful changes rather than minor wording edits or typo fixes

## Why it exists

adb help output is not always consistent across versions. Some changes are cosmetic, but others can affect syntax, available flags, or behavior. This collection helps avoid guessing and makes it easier to keep PowerAdb aligned with real adb behavior.

## How to use it

1. Find the command family you need, such as shell, pm, settings, or logcat.
2. Open the matching help file for the relevant API level or version range.
3. Compare versions when implementing a new function or verifying whether an existing command should be updated.

## Notes

- This is not intended to be a complete reference for every adb release.
- The focus is on significant changes that matter for PowerAdb development.
- If you add new help files, try to preserve the existing naming and grouping conventions so the folder remains easy to navigate.
