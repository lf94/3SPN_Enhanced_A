class Message_RocketMan extends LocalMessage;

#exec AUDIO IMPORT FILE=Sounds\RocketMan.wav GROUP=Sounds

var Sound RocketManSound;
var localized string YouAreRocketMan;
var localized string PlayerIsRocketMan;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    if(SwitchNum == 1)
	    return default.YouAreRocketMan;
    else
        return RelatedPRI_1.PlayerName@default.PlayerIsRocketMan;
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
		P.ClientPlaySound(default.RocketManSound);
}

defaultproperties
{
	YouAreRocketMan="YOU ARE A ROCKETMAN!"
	PlayerIsRocketMan="IS A ROCKETMAN!"
	RocketManSound=Sound'3SPN_Enhanced_A.Sounds.RocketMan'
	bIsUnique=True
	bFadeMessage=True
	Lifetime=5
	DrawColor=(B=0,G=0,R=255)
	StackMode=SM_Down
    PosY=0.10
}

