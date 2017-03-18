class Message_TimeOut extends LocalMessage;

static function string GetString(
    optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	return "TIME OUT!";
}

defaultproperties
{
	bIsUnique=True
	bFadeMessage=True
	StackMode=SM_Down
	PosY=0.5
	FontSize=0
	LifeTime=1
	DrawColor=(B=0,G=255,R=255)
}
