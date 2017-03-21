class Message_Thaw_Thawsome extends LocalMessage;

#exec AUDIO IMPORT FILE=Sounds\Thawsome.wav GROUP=Sounds

var Sound ThawsomeSound;
var localized string YouAreThawsome;
var localized string PlayerIsThawsome;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    if(SwitchNum == 1)
	    return default.YouAreThawsome;
    else
        return RelatedPRI_1.PlayerName@default.PlayerIsThawsome;
	
}

static simulated function ClientReceive(
	PlayerController P,
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, SwitchNum, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if(SwitchNum==1)
		P.ClientPlaySound(default.ThawsomeSound);
}

defaultproperties
{
	YouAreThawsome="YOU ARE THAWSOME!"
	PlayerIsThawsome="IS THAWSOME!"
	ThawsomeSound=Sound'3SPN_Enhanced_A.Sounds.Thawsome'
	bIsUnique=True
	bFadeMessage=True
	Lifetime=5
	DrawColor=(B=0,G=100,R=255)
	StackMode=SM_Down
	PosY=0.10
}
