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
     TeamAIType(0)=Class'3SPNv32232.Freon_TeamAI'
     TeamAIType(1)=Class'3SPNv32232.Freon_TeamAI'
     DefaultPlayerClassName="3SPNv32232.Freon_Pawn"
     ScoreBoardType="3SPNv32232.Freon_Scoreboard"
     HUDType="3SPNv32232.Freon_HUD"
     PlayerControllerClassName="3SPNv32232.Freon_Player"
     GameReplicationInfoClass=Class'3SPNv32232.Freon_GRI'
     GameName="IG Freon"
     Description="Freeze the other team, score a point. Chill well and serve."
     Acronym="IGFreon"
     NextRoundDelayFreon=1
     TeleportOnThaw=True
     bSpawnProtectionOnThaw=True
     TeleportSound=Sound'Teleport'
     KillGitters=True
     MaxGitsAllowed=2
     KillGitterMsg="You will die on Gits from now on."
     KillGitterMsgColour=(R=226,G=2,B=232,A=0)
     MapListType="3SPNv32232.MapListIGFreon"
     ThawPointScale=2.5
     SecsPerRound=120
     OTDamage=5
     OTInterval=3
     CampThreshold=50.000000
}