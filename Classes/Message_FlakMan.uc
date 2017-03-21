class Message_FlakMan extends LocalMessage;

#exec AUDIO IMPORT FILE=Sounds\FlakMan.wav GROUP=Sounds

var Sound FlakManSound;
var localized string YouAreFlakMan;
var localized string PlayerIsFlakMan;

static function string GetString(
    optional int SwitchNum,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject 
    )
{
    if(SwitchNum == 1)
        return default.YouAreFlakMan;
    else
        return RelatedPRI_1.PlayerName@default.PlayerIsFlakMan;
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
        P.ClientPlaySound(default.FlakManSound);
}

defaultproperties
{
    YouAreFlakMan="YOU ARE A FLAKMAN!"
    PlayerIsFlakMan="IS A FLAKMAN!"
    FlakManSound=Sound'3SPN_Enhanced_A.Sounds.FlakMan'
    bIsUnique=True
    bFadeMessage=True
    Lifetime=5
    DrawColor=(B=0,G=0,R=255)
    StackMode=SM_Down
    PosY=0.10
}

