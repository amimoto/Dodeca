// To hold the information related to a squad that may
// be spawned. It's just a nice little container, really,
// that's all :D

class DAISpawnSquads extends Object;

`include(ControlledDifficulty/CD_Log.uci)

var array< class<KFPawn_Monster> > AIClassList;
var array<AISquadElement> CustomMonsterList;

var int SquadIndex;

var CD_AIWaveInfo SquadInfo;

const mInZedsInElement = 1;
const MaxZedsInElement = 10;

const MinZedsInSquad = 1;
const MaxZedsInSquad = 10;

function Initialize( string SquadString, array< class<KFPawn_Monster> > BaseAIClassList )
{
    AIClassList = BaseAIClassList;
    ParseSpawnCycleDef(SquadString);
    SquadIndex = 0;
}

function ParseSpawnCycleDef ( string SquadString )
{
    local int i, j;

    local array<string> SquadDefs;
    local array<string> ElemDefs;

    local int CurSquadSize;
    local CD_AISpawnSquad CurSquad;

    local ESquadType CurElementVolume;

    local ESquadType LargestVolumeInSquad;
    local AISquadElement CurElement;

    SquadInfo = new class'DAIWaveInfo';

    // Split on , and drop empty elements
    SquadDefs = SplitString( SquadString, ",", true );

    for ( i=0; i<SquadDefs.Length; i++ )
    {
        CurSquadSize = 0;
        CurSquad = new class'ControlledDifficulty.CD_AISpawnSquad';
        LargestVolumeInSquad = EST_Crawler;

        // Squads may in general be heterogeneous, e.g.
        // 2Cyst_3Crawler_2Gorefast_2Siren
        //
        // But specific squads may be homogeneous, e.g. 
        // 6Crawler
        //
        // In the following code, we split on _ and loop through
        // each element, populating a CD_AISpawnSquad as we go.
        ElemDefs = SplitString( SquadDefs[i], "_", true );

        for ( j = 0; j < ElemDefs.length; j++ )
        {

            if ( !ParseSquadElement( ElemDefs[j], CurElement ) )
            {
                continue; // Parse error in that element
            }

            `cdlog("[squad#"$ i $",elem#"$ j $"] "$CurElement.Num$"x"$CurElement.Type);

            CurSquad.AddSquadElement( CurElement );
            CurSquadSize += CurElement.Num;

            // Update LargestVolumeInSquad
            CurElementVolume = AIClassList[CurElement.Type].default.MinSpawnSquadSizeType;

            // ESquadType is biggest first (boss) to smallest last (crawler)
            // blame tripwire
            if ( CurElementVolume < LargestVolumeInSquad )
            {
                LargestVolumeInSquad = CurElementVolume;
            }


            // Check overall zed count of the squad (summing across all elements)
            if ( CurSquadSize < MinZedsInSquad )
            {
                `log("Squad size "$ CurSquadSize $" is too small.  "$
                    "Must be between "$ MinZedsInSquad $" to "$ MaxZedsInSquad $" (inclusive).");
                continue;
            }
            if ( CurSquadSize > MaxZedsInSquad )
            {
                `log("Squad size "$ CurSquadSize $" is too large.  "$
                    "Must be between "$ MinZedsInSquad $" to "$ MaxZedsInSquad $" (inclusive).");
                continue;
            }

            // I think the squad volume type doesn't even matter in most cases,
            // judging from KFAISpawnManager and the shambholic state of this
            // property on the official TWI squad archetypes
            CurSquad.MinVolumeType = LargestVolumeInSquad;
            `cdlog("[squad#"$i$"] Set spawn volume type: "$CurSquad.MinVolumeType, true);

            SquadInfo.CustomSquads.AddItem(CurSquad);
        }
    }
}

/*
 * Parse a single squad.
 */
function bool ParseSquadElement( const out String ElemDef, out AISquadElement SquadElement )
{
    local int ElemStrLen, UnicodePoint, ElemCount, i;
    local string ElemType;
    local EAIType ElemEAIType;
    local bool IsSpecial;

    IsSpecial = false;
    ElemStrLen = Len( ElemDef );

    if ( 0 == ElemStrLen )
    {
        `log("Spawn elements must not be empty.");
        return false;
    }

    // Locate the first index into ElemDef where the count
    // of zeds in the element ends and the type of zed should begin
    for ( i = 0; i < ElemStrLen; i++ )
    {
        // Get unicode codepoint (as int) for char at index i
        UnicodePoint = Asc( Mid( ElemDef, i, 1 ) );

        // Check for low ascii numerals [0-9]
        if ( !( 48 <= UnicodePoint && UnicodePoint <= 57 ) )
        {
            break; // not a numeral
        }
    }

    // The index must not be at the very beginning or end of the string.
    // If that's true, then we can assume it was malformed.
    if ( i <= 0 || i >= ElemStrLen )
    {
        `log("Spawn element \""$ ElemDef $"\" could not be parsed.");
        return false;
    }

    // Check whether the element string ends with a *.  The
    // asterisk suffix denotes special/albino zeds.  It is only
    // valid on crawlers and alphas (when this comment was written,
    // at least).  We will have to check that constraint later so
    // that we correctly reject requests for nonexistent specials,
    // e.g. albino scrake.
    if ( "*" == Right( ElemDef, 1 ) )
    {
        IsSpecial = true;

        // Check that the zed name is not empty
        if ( i >= ElemStrLen - 1)
        {
            `log("Spawn element \""$ ElemDef $"\" could not be parsed.");
            return false;
        }
    }

    // Cut string into two parts.
    //
    // Left is the count as a stringified int.  We know it is a
    // parseable int because of the preceding unicode check loop.
    //
    // Right is possibly the name of a zed as a string, but it is
    // totally unverified at this stage.  We exclude the * suffix
    // (if it was detected above).
    ElemCount = int( Mid( ElemDef, 0, i ) );
    ElemType  = Mid( ElemDef, i, ElemStrLen - i - ( IsSpecial ? 1 : 0 ) );

    // Check value range for ElemCount
    if ( ElemCount < MinZedsInElement )
    {
        `log("Element count "$ ElemCount $" is not positive.  "$
                   "Must be between "$ MinZedsInElement $" to "$ MaxZedsInElement $" (inclusive).");
        return false;
    }
    if ( ElemCount > MaxZedsInElement )
    {
        `log("Element count "$ ElemCount $" is too large.  "$
                   "Must be between "$ MinZedsInElement $" to "$ MaxZedsInElement $" (inclusive).");
        return false;
    }

    // Convert user-provided zed type name into a zed type enum
    ElemEAIType = class'CD_ZedNameUtils'.static.GetZedType( ElemType );

    // Was it a valid zed type name?
    if ( 255 == ElemEAIType )
    {
        `log("\""$ ElemType $"\" does not appear to be a zed name."$
                      "  Must be a zed name or abbreviation like cyst, fp, etc.");
        return false;
    }

    // If the ElemDef requested a special zed, then we need to
    // check that the zed described by ElemType actually has a
    // special/albino variant.
    if ( IsSpecial && !( ElemEAIType == AT_AlphaClot || ElemEAIType == AT_Crawler || ElemEAIType == AT_GoreFast ) )
    {
        `log("\""$ ElemType $"\" does not have a special variant."$
              "  Remove the trailing asterisk from \""$ ElemDef $"\" to spawn a non-special equivalent.");
        return false;
    }

    SquadElement.Type = ElemEAIType;
    SquadElement.Num = ElemCount;

    // Apply custom class overrides that control albinism
    if ( ElemEAIType == AT_AlphaClot )
    {
        SquadElement.CustomClass = IsSpecial ?
            class'CD_Pawn_ZedClot_Alpha_Special' :
            class'CD_Pawn_ZedClot_Alpha_Regular' ;
    }
    else if ( ElemEAIType == AT_Crawler )
    {
        SquadElement.CustomClass = IsSpecial ?
            class'CD_Pawn_ZedCrawler_Special' :
            class'CD_Pawn_ZedCrawler_Regular' ;
    }
    else if ( ElemEAIType == AT_GoreFast )
    {
        SquadElement.CustomClass = IsSpecial ?
            class'CD_Pawn_ZedGorefast_Special' :
            class'CD_Pawn_ZedGorefast_Regular' ;
    }
    else
    {
        SquadElement.CustomClass = None;
    }

    return true;
}

function DumpSquadInformation()
{
    local int i;
    local CD_AISpawnSquad Squad;
    local array<AISquadElement> CML;

    Squad = GetNextSquad();
    CML = Squad.CustomMonsterList;

    `log(">>>>>>>>>>>>>>>>>>>>>>>>> Squad: ");
    for (i=0;i<CML.Length;i++)
    {
        `log(CML[i].Type@" Count "@CML[i].Num);
    }
    `log("<<<<<<<<<<<<<<<<<<<<<<<<< Squad: ");
}

function CD_AISpawnSquad GetNextSquad()
{
    return SquadInfo.CustomSquads[SquadIndex];
}

function SetupNextSquad()
{
    SquadIndex = ( SquadIndex + 1 ) % SquadInfo.CustomSquads.Length;
    `log("+++++++++++++++++++++++++++++ SETUP NEXT SQUAD: "$SquadIndex);
    DumpSquadInformation();
}

defaultproperties
{
}


