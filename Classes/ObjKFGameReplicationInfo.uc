class ObjKFGameReplicationInfo extends KFGameReplicationInfo;

// Keep track of the wave specific traders
var array<ObjKFTraderTrigger>   ObjTraderList;

simulated function OpenTrader(optional int time)
{
    `log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> OPEN TRADER");
    super.OpenTrader(time);
}

simulated function OpenWaveTraders()
{
    local ObjKFTraderTrigger Trader;
    local int i;

    `log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Opening Wave Traders. There are "@ObjTraderList.Length@" Traders in list");

    // Open up All traders that should be open right now
    for (i=0; i < ObjTraderList.Length; i++ )
    {
        Trader = ObjTraderList[i];
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
    TraderDialogManagerClass=class'Objectives.ObjKFTraderDialogManager'
}
