class WeaponFire_FlakAlt extends FlakAltFire;

event ModeDoFire()
{
    Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Flak.Secondary.Fired += load;
    Super.ModeDoFire();
}

defaultproperties
{
}
