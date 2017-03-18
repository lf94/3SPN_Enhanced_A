class Misc_ComboSpeed extends ComboSpeed;

function StartEffect(xPawn P)
{
    Super.StartEffect(P);

    if(Misc_Player(P.Controller) != None)
        Misc_Player(P.Controller).bSeeInvis = true;
}

function StopEffect(xPawn P)
{
    Super.StopEffect(P);

    if(Misc_Player(P.Controller) != None)
        Misc_Player(P.Controller).bSeeInvis = false;
}

defaultproperties
{
     Duration=30.000000
}
