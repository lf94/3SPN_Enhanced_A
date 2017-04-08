class Freon_GRI extends TAM_GRI;

var float AutoThawTime;
var float ThawSpeed;
var bool  bTeamHeal;
var float ThawPointScale;
var bool bRoundOTCuddling;

replication
{
    reliable if(bNetInitial && Role == ROLE_Authority)
        bRoundOTCuddling, AutoThawTime, ThawSpeed, bTeamHeal, ThawPointScale;
}

defaultproperties
{
}
