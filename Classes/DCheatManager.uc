class DCheatManager extends KFCheatManager;

// Actual Uber Ammo.
// Note that we the ammocount and magazine capacities
// are bytes so we set to the size maximum 255
exec function UberAmmo()
{
    local KFWeapon KFW;

    if (Pawn == None)
        return;

    ForEach Pawn.InvManager.InventoryActors(class'KFWeapon', KFW)
    {
        KFW.SpareAmmoCount[0] = 10000;
        KFW.AmmoCount[0] = 255;
        KFW.AmmoCount[1] = 255;
        KFW.MagazineCapacity[0] = 255;
        KFW.MagazineCapacity[1] = 255;
        KFW.bInfiniteAmmo = true;
    }

    if( KFInventoryManager(Pawn.InvManager) != none )
    {
       KFInventoryManager(Pawn.InvManager).GrenadeCount = 255;
    }
}

