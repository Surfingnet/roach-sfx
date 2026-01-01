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


## License
 <p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://github.com/Surfingnet/roach-sfx">Roacher SFX</a> by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://github.com/Surfingnet">Maxime Ghazarian</a> is licensed under <a href="https://creativecommons.org/licenses/by-nc-sa/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY-NC-SA 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/nc.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/sa.svg?ref=chooser-v1" alt=""></a></p> 