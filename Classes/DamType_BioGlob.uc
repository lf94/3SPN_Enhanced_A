class DamType_BioGlob extends DamTypeBioGlob;

var int AwardLevel;

static function IncrementKills(Controller Killer)
{
    local Misc_PRI xPRI;

    xPRI = Misc_PRI(Killer.PlayerReplicationInfo);
    if ( xPRI != None )
    {
        xPRI.ranovercount++; // use ranovercount to count bio kills
        if ((xPRI.ranovercount == default.AwardLevel) && (Misc_Player(Killer) != None))
            Misc_Player(Killer).BroadcastAnnouncement(class'Message_Bukkake');
    }
}

defaultproperties
{
    AwardLevel = 8
}

