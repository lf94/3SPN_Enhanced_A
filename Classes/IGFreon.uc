class IGFreon extends Freon;

defaultproperties
{
     AutoThawTime=30.000000
     ThawSpeed=2.000000
     MinHealthOnThaw=50
     bTeamHeal=True
     bDisableTeamCombos=False
     AssaultAmmo=0
     AssaultGrenades=0
     BioAmmo=0
     ShockAmmo=0
     LinkAmmo=0
     MiniAmmo=0
     FlakAmmo=0
     RocketAmmo=0
     LightningAmmo=0
     ScoreboardRedTeamName="!nSta Killas"
     ScoreboardBlueTeamName="!nSta Assasins"
     TeamAIType(0)=Class'3SPN_Enhanced_A.Freon_TeamAI'
     TeamAIType(1)=Class'3SPN_Enhanced_A.Freon_TeamAI'
     DefaultPlayerClassName="3SPN_Enhanced_A.Freon_Pawn"
     ScoreBoardType="3SPN_Enhanced_A.Freon_Scoreboard"
     HUDType="3SPN_Enhanced_A.Freon_HUD"
     PlayerControllerClassName="3SPN_Enhanced_A.Freon_Player"
     GameReplicationInfoClass=Class'3SPN_Enhanced_A.Freon_GRI'
     GameName="IG Freon En_A"
     Description="Freeze the other team, score a point. Chill well and serve."
     Acronym="IGFreon"
     MapPrefix="IFR"
     NextRoundDelayFreon=1
     TeleportOnThaw=True
     bSpawnProtectionOnThaw=True
     TeleportSound=Sound'Teleport'
     KillGitters=True
     MaxGitsAllowed=2
     KillGitterMsg="You will die on Gits from now on."
     KillGitterMsgColour=(R=226,G=2,B=232,A=0)
     MapListType="3SPN_Enhanced_A.MapListIGFreon"
     ThawPointScale=2.5
     SecsPerRound=120
     OTDamage=5
     OTInterval=3
     CampThreshold=50.000000
}
