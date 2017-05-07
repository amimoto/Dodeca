class DInventoryManager extends KFInventoryManager;


enum DKeyColours {
    DKC_Red,
    DKC_Green,
    DKC_Blue,
};

function bool HasKey ( DKeyColours keyColour )
{
    local Inventory Item;
    local DInventory_Key Key;

    // No inventory? Then no cards!
    if( InventoryChain == None )
    {
        return false;
    }

    for (Item = InventoryChain; Item != None; Item = Item.Inventory)
    {
        Key = DInventory_Key (Item);
        if ( Key != none )
        {
            if ( Key.IndicatorIndex == keyColour )
            {
                return true;
            }
        }
    }

    // No matches. Sadness.
    return false;
}

function ConsumeKey ( DKeyColours keyColour )
{
    local Inventory Item;
    local DInventory_Key Key;

    // No inventory? Then no cards!
    if( InventoryChain == None ) return;

    // Seek and destroy
    for (Item = InventoryChain; Item != None; Item = Item.Inventory)
    {
        Key = DInventory_Key (Item);
        if ( Key != none )
        {
            if ( Key.IndicatorIndex == keyColour )
            {
                RemoveFromInventory(Item);
            }
        }
    }

}
