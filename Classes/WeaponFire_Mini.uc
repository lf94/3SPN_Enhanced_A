class WeaponFire_Mini extends MinigunFire;

event ModeDoFire()
{
    Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Mini.Primary.Fired += load;
    Super.ModeDoFire();
}

defaultproperties
{
}
