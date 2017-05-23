class DGameReplicationInfo extends KFGameReplicationInfo;

// Keep track of the collectable "key" items on this map
// Array is:
// [
//    int, # red key item (0: not required on this map,
//                        1: required but not possessed,
//                        2: picked up by someone on team)
//    int, # green key item (same as red)
//    int, # blue key item (same as blue)
// ]
var int    KeysList[3];

// Keep track of the wave specific traders
var array<DTraderTrigger>   DTraderList;

// Keep track of the status of the spawns
var bool SpawningActive;
var string SpawnSquads;

replication
{
    if ( bNetDirty )
        KeysList, SpawningActive, SpawnSquads;
}

simulated function RequiredKeyItem(int KeyIndex)
{
    bNetDirty = True;
    KeysList[KeyIndex] = 2;
}

simulated function PickupKeyItem(int KeyIndex)
{
    bNetDirty = True;
    KeysList[KeyIndex] = 2;
}

simulated function OpenTrader(optional int time)
{
    `log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> OPEN TRADER");
    super.OpenTrader(time);
}

simulated function OpenWaveTraders()
{
    local DTraderTrigger Trader;
    local int i;

    `log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Opening Wave Traders. There are "@DTraderList.Length@" Traders in list");

    // Open up All traders that should be open right now
    for (i=0; i < DTraderList.Length; i++ )
    {
        Trader = DTraderList[i];
        if ( Trader.OpenDuringWave(WaveNum,WaveMax) )
        {
            if ( !Trader.bOpened ) Trader.OpenTrader();
        }
        else {
            if ( Trader.bOpened ) Trader.CloseTrader();
        }
    }
}

simulated function CloseWaveTraders()
{
    `log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Closing Wave Traders");
}

simulated event bool CanChangePerks()
{
    `log("CAN CHANG EPRKS??????????????????????????????????????????????????????????????????????");
    return false;
}


simulated function StopZedSpawning()
{
    bNetDirty = True;
    SpawningActive = False;
}

simulated function StartZedSpawning()
{
    bNetDirty = True;
    SpawningActive = True;
}

defaultproperties
{
    TraderDialogManagerClass=class'Dodeca.DTraderDialogManager'
}

