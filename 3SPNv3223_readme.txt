
3220h (14th May 2016) Changes from 3210CW
-----------------------------------------

* New 3SPN Config options

Thaw Points Award - amount of points to award per thaw
Damage Score Award (per 10 damage) - set to 0.1 for old behaviour
Scoreboard Community Name - changes text top right scoreboard
Scoreboard Red Team Name - changes name of Red team on scoreboard
Scoreboard Blue Team Name - changes name of Blue team on scoreboard

* general notes

bio bukkake award at 8 bio kills
flakman award at 8 flak kills
rocket award at 8 rocket kills
new thaw levels in Freon.uc
added Message_Thaw_Scorcher.uc Message_Thaw_Flamer.uc Message_Thaw_Incinerator.uc
update version numbers and details


3221hl (3rd June 2016) Changes from 3220h
-----------------------------------------

* New 3SPN Config Options

ServerLinkStatus - can be SL_DISABLED SL_READONLY SL_ENABLED
(ServerLinkEnabled no longer used)

SecsPerRound - defaults to 120 seconds
(MinsPerRound no longer used)

* general notes

bio and shock combo kill award messages go to all players
wedadmin tidying for 3SPN
allow seconds per round instead of whole minutes per round
server link off/readonly/on balancer has avg ppr more available
hud radar when frozen and viewing another player improved
try to fix frozen player right click return to frozen body
admin can always trigger auto balance by typing/saying ‘teams’
enlarged hud radar with z axis shows above / below allies
stop bots from being able to use disabled adren combos


3222hl (4th June 2016) Changes from 3221hl
------------------------------------------

mod: when spec-ing a player (especially when frozen) show player in HUD
mod: add z axis data to non-extended info HUD radar


3223hl (19th June 2016) Changes from 3222hl
-------------------------------------------

fix: check for PRI None in draw player code to stop warnings in the log
fix: allow turning off HUD on TAM and reducing HUD on freon
mod: change the z axis plus / minus tga image


