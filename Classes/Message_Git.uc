class Message_Git extends LocalMessage;

#exec AUDIO IMPORT FILE=Sounds\Git.wav GROUP=Sounds

var Sound GitSound;
var localized string YouAreGit;
var localized string PlayerIsGit;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    if(SwitchNum == 1)
	    return default.YouAreGit;
    else
        return RelatedPRI_1.PlayerName@default.PlayerIsGit;
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
		P.ClientPlaySound(default.GitSound);
}

defaultproperties
{
	YouAreGit="YOU GIT!"
	PlayerIsGit="IS A GIT!"
	GitSound=Sound'3SPN_Enhanced_A.Sounds.Git'
	bIsUnique=True
	bFadeMessage=True
	Lifetime=5
	DrawColor=(B=0,G=0,R=255)
	StackMode=SM_Down
    PosY=0.10
}