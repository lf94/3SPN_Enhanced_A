class Misc_ComboBerserk extends ComboBerserk;

function StartEffect(xPawn P)
{
    Super.StartEffect(P);

    SetTimer(0.9, true);
    Timer();
}

function Timer()
{
    local Weapon heldWeapon;
    local int ammo;
    local float add;

    if(Pawn(Owner).Role == ROLE_Authority)
    {
        heldWeapon = Pawn(Owner).Weapon;
        if(heldWeapon == None)
            return;

        ammo = heldWeapon.AmmoAmount(0);

        if(heldWeapon.GetAmmoClass(0) != None)
        {
            if(heldWeapon.GetAmmoClass(0).default.InitialAmount > 0)
                add = Max((heldWeapon.GetAmmoClass(0).default.InitialAmount * 0.1), 1);
            else
                add = Max((heldWeapon.MaxAmmo(0) / 2.5 * 0.1), 1); 
        }

        heldWeapon.AmmoCharge[0] = Min(heldWeapon.MaxAmmo(0), heldWeapon.AmmoCharge[0] + add);

        if(heldWeapon.GetAmmoClass(1) == None || heldWeapon.GetAmmoClass(0) == heldWeapon.GetAmmoClass(1))
            return;

        ammo = heldWeapon.AmmoAmount(1);

        if(heldWeapon.GetAmmoClass(1).default.InitialAmount > 0)
            add = Max((heldWeapon.GetAmmoClass(1).default.InitialAmount * 0.1), 1);
        else
            add = Max((heldWeapon.MaxAmmo(1) / 2.5 * 0.1), 1);

        heldWeapon.AmmoCharge[1] = Min(heldWeapon.MaxAmmo(1), heldWeapon.AmmoCharge[1] + add);
    }
}

defaultproperties
{
}
