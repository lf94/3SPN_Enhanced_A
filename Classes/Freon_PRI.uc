class Freon_PRI extends Misc_PRI;

var Color FrozenColor;
var localized string FrozenString;

var int Thaws;
var int Git;

simulated function string GetLocationName()
{
    if(bOutOfLives && !bOnlySpectator)
    {
        if(PlayerVolume == None && PlayerZone == None)
            return default.StringDead;
        if(PlayerVolume != None && PlayerVolume.LocationName != class'Volume'.default.LocationName)
            return /*class'DMStatsScreen'.static.MakeColorCode(FrozenColor) $*/ PlayerVolume.LocationName;
        if(PlayerZone != None && PlayerZone.LocationName != "")
            return /*class'DMStatsScreen'.static.MakeColorCode(FrozenColor) $*/ PlayerZone.LocationName;
        return class'DMStatsScreen'.static.MakeColorCode(FrozenColor)$default.FrozenString;
    }

    return Super.GetLocationName();
}

simulated function string GetLocationNameTeam()
{
    local float Percent;
    local string name;

    if(bOutOfLives && !bOnlySpectator)
    {
        if(PlayerVolume == None && PlayerZone == None)
            return default.StringDead;
        else if(PlayerVolume != None && PlayerVolume.LocationName != class'Volume'.default.LocationName)
            name= /*class'DMStatsScreen'.static.MakeColorCode(FrozenColor) $*/ PlayerVolume.LocationName;
        else if(PlayerZone != None && PlayerZone.LocationName != "")
            name= /*class'DMStatsScreen'.static.MakeColorCode(FrozenColor) $*/ PlayerZone.LocationName;
        else
            name = class'DMStatsScreen'.static.MakeColorCode(FrozenColor)$default.FrozenString;

        Percent = PawnReplicationInfo.Health/100.0;
        return name$"["$int(Percent*100)$"%]";
    }

    return Super.GetLocationName();
}

function UpdatePlayerLocation()
{
    local Controller C;
    local Pawn P;
    local Volume V, Best;

    C = Controller(Owner);

    if(C != None)
    {
        if(!bOutOfLives || bOnlySpectator)
            P = C.Pawn;
        else
        {
            if(Freon_Player(C) != None)
                P = Freon_Player(C).FrozenPawn;
            else if(Freon_Bot(C) != None)
                P = Freon_Bot(C).FrozenPawn;
        }
    }

    if(P == None)
    {
        PlayerVolume = None;
        PlayerZone = None;
        return;
    }

    if(PlayerZone != P.Region.Zone)
        PlayerZone = P.Region.Zone;

    ForEach P.TouchingActors(class'Volume', V)
    {
        if(V.LocationName == "")
            continue;

        if(Best != None && V.LocationPriority <= Best.LocationPriority)
            continue;

        if(V.Encompasses(P))
            Best = V;
    }

    if(PlayerVolume != Best)
        PlayerVolume = Best;
}

defaultproperties
{
     FrozenColor=(B=210,G=185,R=170,A=255)
     FrozenString="Frozen"
     PawnInfoClass=Class'3SPNv32232.Freon_PawnReplicationInfo'
}
