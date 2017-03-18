class WeaponFire_Bio extends BioFire;

event ModeDoFire()
{
    Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Bio.Fired += load;
    Super.ModeDoFire();
}

defaultproperties
{
}
