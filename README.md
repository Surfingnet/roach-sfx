# Description: Roach SFX, the coward detector

- If a player in your group (party or raid) leaves the group or starts using a teleportation spell while at least one group member is in combat, you will be notified that they are roaching out, via a funny sound, a raid warning-style message, or both.
- You can choose whether to detect roaches everywhere or only in PvE instances (dungeons and raids).

# Limitations: The WoW API and some technical constraints

- There is no heuristic detection of a player's intent when using a spell. Therefore, spells such as Stealth or Feign Death are not taken into account.
- The API does not allow the code to differentiate between a player who leaves the group voluntarily and a player who is kicked, so both will trigger the roach detector.
- For hardcore players, anyone who disconnects while dead will not trigger detection, unless it is an exceptional case where the Blizzard API fails to properly report the death to the client.

# Note: Tell me what you think

- If you have a good idea for a funny message or sound, leave a comment on CurseForge.
- If something is not working correctly, open an issue on GitHub.

# Known issues

- When the party is disbanded, the leader name isn't remembered yet, and a placeholder is used instead.

# Planned

- Bug fixes if needed.
