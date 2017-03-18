class Message_Thaw_GodOfThaw extends LocalMessage;

#exec AUDIO IMPORT FILE=Sounds\GodOfThaw.wav GROUP=Sounds

var Sound GodOfThawSound;
var localized string YouAreGodOfThaw;
var localized string PlayerIsGodOfThaw;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    if(SwitchNum == 1)
	    return default.YouAreGodOfThaw;
    else
        return RelatedPRI_1.PlayerName@default.PlayerIsGodOfThaw;
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
		P.ClientPlaySound(default.GodOfThawSound);
}

defaultproperties
{
	YouAreGodOfThaw="GOD OF THAW!"
	PlayerIsGodOfThaw="IS THE GOD OF THAW!"
	GodOfThawSound=Sound'3SPNv32232.Sounds.GodOfThaw'
	bIsUnique=True
	bFadeMessage=True
	Lifetime=5
	DrawColor=(B=0,G=0,R=255)
	StackMode=SM_Down
	PosY=0.10
}
