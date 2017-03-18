class WeaponFire_Assault extends AssaultFire;

event ModeDoFire()
{
    Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Assault.Primary.Fired += load;
    Super.ModeDoFire();
}

defaultproperties
{
}
