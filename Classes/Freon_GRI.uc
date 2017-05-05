class Freon_GRI extends TAM_GRI;

var float AutoThawTime;
var float ThawSpeed;
var float ThawRadius;
var bool  bTeamHeal;
var float ThawPointScale;
var bool bRoundOTCuddling;

replication
{
    reliable if(bNetInitial && Role == ROLE_Authority)
        bRoundOTCuddling, AutoThawTime, ThawSpeed, ThawRadius, bTeamHeal, ThawPointScale;
}

defaultproperties
{
}
