class Message_Thaw_Scorcher extends LocalMessage;

#exec AUDIO IMPORT FILE=Sounds\scorcher.wav GROUP=Sounds

var Sound ScorcherSound;
var localized string YouAreScorcher;
var localized string PlayerIsScorcher;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    if(SwitchNum == 1)
	    return default.YouAreScorcher;
    else
        return RelatedPRI_1.PlayerName@default.PlayerIsScorcher;
	
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
		P.ClientPlaySound(default.ScorcherSound);
}

defaultproperties
{
     ScorcherSound=Sound'3SPNv32232.Sounds.scorcher'
     YouAreScorcher="YOU ARE A SCORCHER!"
     PlayerIsScorcher="IS A SCORCHER!"
     bIsUnique=True
     bFadeMessage=True
     Lifetime=5
     DrawColor=(B=0,G=150,R=255)
     StackMode=SM_Down
     PosY=0.100000
}
