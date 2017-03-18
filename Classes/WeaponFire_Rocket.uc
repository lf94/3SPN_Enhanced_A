class WeaponFire_Rocket extends RocketFire;

event ModeDoFire()
{
    Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Rockets.Fired += load;
    Super.ModeDoFire();
}

defaultproperties
{
}
