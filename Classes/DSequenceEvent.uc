class DSequenceEvent extends SequenceEvent;

event Activated()
{
    `log(self$" Was Activated");
    Super.Activated();
}


