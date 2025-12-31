Description: Roach SFX, the coward detector.

-If a player of the group (party/raid) leaves the group or starts using a teleportation spell, when at least one player from the group is in combat, then you will be notified of them roaching out with a funny sound or raid warning style message, or both.
-You choose weither to look for roaches everywhere or only in PVE instances. (dungeons/raid)

Limitations: The WoW API and some code can't do everything.

-There is no heuristic detection regarding the intention behind the use of a spell. Therefor, Stealth or Fein Death and such spells are not taken into account.
-The API does not allow the code to differenciate a player who leaves the group from a player who's been kicked out or disconnected, so they all trigger the roach detector.
-For hardcore players, anyone who disconnects while dead will not trigger detection.

Note: Tell me what you think.

-If you have a good idea for a funny message or sound, leave a message on Curseforge.
-If something isn't right, open an issue on Github.