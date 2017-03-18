class Message_Camper extends LocalMessage;

var	localized string 	YouAreCampingDefault;
var localized string    YouAreCampingWarning;
var localized string    YouAreCampingFirst;
var localized string    YouAreCampingSecond;
var localized string    YouAreCampingThird;
var localized string 	PlayerIsCampingOpen;
var localized string 	PlayerIsCamping;

var Sound bastard;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	switch(SwitchNum)
	{
	    case 0: // You are a camper
            if(Misc_PRI(RelatedPRI_1) != None)
            {
                if(!Misc_PRI(RelatedPRI_1).bWarned)
                    return default.YouAreCampingWarning;
                else if(Misc_PRI(RelatedPRI_1).CampCount == 0)
                    return default.YouAreCampingFirst;
                else if(Misc_PRI(RelatedPRI_1).CampCount == 1)
                    return default.YouAreCampingSecond;
                else if(Misc_PRI(RelatedPRI_1).CampCount >= 2)
                    return default.YouAreCampingThird;
            }
		    return default.YouAreCampingDefault;

	    case 1: // Someone is a camper
		    if (RelatedPRI_1 == None)
			    return "";

		return default.PlayerIsCampingOpen@RelatedPRI_1.PlayerName@default.PlayerIsCamping@"("$RelatedPRI_1.GetLocationName()$")";
	}
}

static simulated function ClientReceive( 
	PlayerController P,
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    if(SwitchNum == 0)
        P.ClientPlaySound(Sound'AssaultSounds.HnShipFireReadyl01');

	Super.ClientReceive(P, SwitchNum, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
     YouAreCampingDefault="YOU ARE CAMPING!"
     YouAreCampingWarning="CAMPER WARNING"
     YouAreCampingFirst="FIRST OFFENSE!"
     YouAreCampingSecond="SECOND OFFENSE!"
     YouAreCampingThird="THIRD OFFENSE!"
     PlayerIsCamping="IS CAMPING!"
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=5
     DrawColor=(B=0,G=160)
     StackMode=SM_Down
     PosY=0.130000
}
