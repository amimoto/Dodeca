class DActor_CountdownTimer extends Actor
  placeable;

/** Countdown seconds */
var() float countdownSeconds;

/** Countdown active */
var() bool countdownActive;

/** Countdown ticker interval */
var() float countdownTickerInterval;

/** Initiate the countdown timer */
function CountdownStart()
{
    local DPlayerController KFPC;
    countdownActive = true;

    foreach LocalPlayerControllers(class'DPlayerController', KFPC)
    {
        KFPC.DMyGFxDHud.TimerWidgetContainer.seconds = countdownSeconds;
        KFPC.DMyGFxDHud.TimerWidgetContainer.Show();
    }
}

function CountdownStop()
{
    countdownActive = false;
}

function CountdownTicker( float DeltaTime )
{
    local DPlayerController KFPC;
    if ( countdownActive )
    {
        countdownSeconds -= DeltaTime;

        foreach LocalPlayerControllers(class'DPlayerController', KFPC)
        {
            KFPC.DMyGFxDHud.TimerWidgetContainer.seconds = countdownSeconds;
        }

        if ( countdownSeconds <= 0 )
        {
            countdownSeconds = 0;
            CountdownStop();
            EmitCompleted();
            foreach LocalPlayerControllers(class'DPlayerController', KFPC)
            {
                KFPC.DMyGFxDHud.TimerWidgetContainer.seconds = countdownSeconds;
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
    self.TriggerEventClass(class'DSeqEvent_CountdownComplete',self,-1);
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

    SupportedEvents.Add(class'DSeqEvent_CountdownStart')
    SupportedEvents.Add(class'DSeqEvent_CountdownStarted')
    SupportedEvents.Add(class'DSeqEvent_CountdownComplete')
}
