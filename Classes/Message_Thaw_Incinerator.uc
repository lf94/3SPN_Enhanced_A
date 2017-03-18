
class Message_Thaw_Incinerator extends LocalMessage;

#exec AUDIO IMPORT FILE=Sounds\Incinerator.wav GROUP=Sounds

var Sound IncineratorSound;
var localized string YouAreIncinerator;
var localized string PlayerIsIncinerator;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    if(SwitchNum == 1)
	    return default.YouAreIncinerator;
    else
        return RelatedPRI_1.PlayerName@default.PlayerIsIncinerator;
	
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
		P.ClientPlaySound(default.IncineratorSound);
}

defaultproperties
{
     IncineratorSound=Sound'3SPNv32232.Sounds.Incinerator'
     YouAreIncinerator="YOU ARE AN INCINERATOR!"
     PlayerIsIncinerator="IS AN INCINERATOR!"
     bIsUnique=True
     bFadeMessage=True
     Lifetime=5
     DrawColor=(B=0,G=50,R=255)
     StackMode=SM_Down
     PosY=0.100000
}
