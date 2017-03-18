class Misc_PawnReplicationInfo extends ReplicationInfo;

var vector Position;

var byte Health;
var byte Shield;
var byte Adrenaline;

var bool bInvis;

var xPawn MyPawn;

replication
{
    unreliable if(bNetDirty && Role == ROLE_Authority)
        Position, Health, Shield, Adrenaline, bInvis;
}

function SetMyPawn(xPawn P)
{
    if(P == None)
    {
        Health = 0;
        Shield = 0;
        Adrenaline = 0;
        Position = vect(0,0,0);
        bInvis = false;

        NetUpdateFrequency = default.NetUpdateFrequency * 0.1;
        NetPriority = default.NetPriority * 0.1;

        MyPawn = None;
        SetTimer(0.0, false);
    }
    else
    {
        MyPawn = P;

        Health = MyPawn.Health;
        Shield = MyPawn.ShieldStrength;
        Adrenaline = MyPawn.Controller.Adrenaline;
        Position = MyPawn.Location;
        bInvis = MyPawn.bInvis;

        NetUpdateFrequency = default.NetUpdateFrequency;
        NetPriority = default.NetPriority;

        NetUpdateTime = Level.TimeSeconds - 5;

        SetTimer(0.2, true);
    }
}

event Timer()
{
    if(MyPawn == None || MyPawn.Controller == None)
    {
        SetMyPawn(None);
        return;
    }

    Position = MyPawn.Location;
    Health = Min(255, MyPawn.Health);
    Shield = Min(255, MyPawn.ShieldStrength);
    Adrenaline = Min(255, MyPawn.Controller.Adrenaline);
    bInvis = MyPawn.bInvis;
}

defaultproperties
{
     NetUpdateFrequency=3.000000
     NetPriority=0.500000
}
