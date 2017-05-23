class DActor_CountdownTimer extends Actor
  nativereplication
  placeable;

/** Countdown seconds */
var() float countdownSeconds;
var repnotify float currentCountdownSeconds;

/** Countdown active */
var() repnotify bool countdownActive;

/** Countdown ticker interval */
var() float countdownTickerInterval;

replication
{
    if (bNetDirty)
        currentCountdownSeconds, countdownActive;
}

/** Initiate the countdown timer */
simulated function CountdownStart()
{
    local DPlayerController KFPC;
    countdownActive = true;
    currentCountdownSeconds = countdownSeconds;

    foreach LocalPlayerControllers(class'DPlayerController', KFPC)
    {
        KFPC.DMyGFxDHud.TimerWidgetContainer.seconds = currentCountdownSeconds;
        KFPC.DMyGFxDHud.TimerWidgetContainer.Show();
    }
}

simulated function CountdownStop()
{
    countdownActive = false;
}

simulated function CountdownReset()
{
    countdownActive = false;
    currentCountdownSeconds = countdownSeconds;
}

function bool IsRunning()
{
    return countdownActive;
}

function bool IsStopped()
{
    return ( countdownActive == false && currentCountdownSeconds > 0 );
}

function bool IsCompleted()
{
    return ( countdownActive == false && currentCountdownSeconds <= 0 );
}

function CountdownTicker( float DeltaTime )
{
    local DPlayerController KFPC;
    if ( countdownActive )
    {
        currentCountdownSeconds -= DeltaTime;

        foreach LocalPlayerControllers(class'DPlayerController', KFPC)
        {
            KFPC.DMyGFxDHud.TimerWidgetContainer.seconds = currentCountdownSeconds;
        }

        if ( currentCountdownSeconds <= 0 )
        {
            currentCountdownSeconds = 0;
            CountdownStop();
            EmitCompleted();
            foreach LocalPlayerControllers(class'DPlayerController', KFPC)
            {
                KFPC.DMyGFxDHud.TimerWidgetContainer.seconds = currentCountdownSeconds;
                KFPC.DMyGFxDHud.TimerWidgetContainer.Hide();
            }
        }
    }
}

function Tick( float DeltaTime )
{
    CountdownTicker(DeltaTime);
    super.Tick(DeltaTime);
}

function EmitCompleted()
{
    `log("COUNTDOWN TIMER EMITTING COMPLETED");
    self.TriggerEventClass(
        class'DSeqEvent_CountdownTimer', // EventClass
        self, // Instigator
        2, // ActivateIndex
    );
}

defaultproperties
{
    Begin Object Class=SpriteComponent Name=Sprite
        Sprite=Texture2D'EditorResources.Counter'
        HiddenGame=true
        AlwaysLoadOnClient=False
        AlwaysLoadOnServer=False
    End Object
    Components.Add(Sprite)

    countdownTickerInterval = 0.2;

    SupportedEvents.Add(class'DSeqEvent_CountdownTimer')
}
