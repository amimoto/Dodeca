class ObjKFDoorActor extends KFDoorActor;

event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
    // Don't take any damage :D
    `log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Door is taking Damage!");
}



