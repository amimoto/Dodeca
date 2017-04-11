class DGameReplicationInfo extends KFGameReplicationInfo;

// Key track of the keycard states on this map
// Array is:
// [
//    int, # red keycard (0: not required on this map,
//                        1: required but not possessed,
//                        2: picked up by someone on team)
//    int, # green keycard (same as red)
//    int, # blue keycard (same as blue)
// ]
var int    KeyCardList[3];

// Keep track of the wave specific traders
var array<DTraderTrigger>   DTraderList;

replication
{
    if ( bNetDirty )
        KeyCardList;
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

defaultproperties
{
    TraderDialogManagerClass=class'Dodeca.DTraderDialogManager'
}
