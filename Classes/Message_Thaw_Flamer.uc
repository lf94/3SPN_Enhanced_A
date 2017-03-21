class Message_Thaw_Flamer extends LocalMessage;

#exec AUDIO IMPORT FILE=Sounds\flamer.wav GROUP=Sounds

var Sound FlamerSound;
var localized string YouAreFlamer;
var localized string PlayerIsFlamer;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    if(SwitchNum == 1)
	    return default.YouAreFlamer;
    else
        return RelatedPRI_1.PlayerName@default.PlayerIsFlamer;
	
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
		P.ClientPlaySound(default.FlamerSound);
}

defaultproperties
{
     FlamerSound=Sound'3SPN_Enhanced_A.Sounds.flamer'
     YouAreFlamer="YOU ARE A FLAMER!"
     PlayerIsFlamer="IS A FLAMER!"
     bIsUnique=True
     bFadeMessage=True
     Lifetime=5
     //DrawColor=(B=0,G=200,R=255)
     DrawColor=(R=255,G=90,B=167)
     StackMode=SM_Down
     PosY=0.100000
}
