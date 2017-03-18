class WeaponFire_Flak extends FlakFire;

event ModeDoFire()
{
    Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Flak.Primary.Fired += 9;
    Super.ModeDoFire();
}

defaultproperties
{
}
