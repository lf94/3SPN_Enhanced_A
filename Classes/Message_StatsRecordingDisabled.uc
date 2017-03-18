class Message_StatsRecordingDisabled extends LocalMessage;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	return "Stats Recording Has Been Disabled For This Match!";
}

static simulated function ClientReceive( 
	PlayerController P,
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	default.DrawColor.G = 0;
	default.DrawColor.B = 0;
	
	Super.ClientReceive(P, SwitchNum, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
     bIsUnique=True
     bIsConsoleMessage=True
     bFadeMessage=True
     Lifetime=3
     StackMode=SM_Down
     PosY=0.875000
}
