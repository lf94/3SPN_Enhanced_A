class WeaponFire_MiniAlt extends MinigunAltFire;

event ModeDoFire()
{
    Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Mini.Secondary.Fired += load;
    Super.ModeDoFire();
}

defaultproperties
{
}
