class DParsers extends Object;

/*********************************************************************************************
 * Parse ZedNames in the CD short format
 * Only support the short format since, well, variation is annoying to implement and I'm lazy
 *********************************************************************************************/

function ParseSpawnCycle( string SpawnCycle )
{
}

function class<KFPawn_Monster> GetZedClass(string ClassSuffix)
{
    return class<KFPawn_Monster>(
          DynamicLoadObject("KFGameContent.KFPawn_Zed"$ClassSuffix,
          class'Class'
      ));
}

function class<KFPawn_Monster> ParseZedName(string ZedName)
{
    switch( Caps(ZedName) )
    {
        case "CA": return GetZedClass("Clot_Alpha");
        case "CA*": return GetZedClass("Clot_AlphaKing");

        case "CS":
        case "SL": return GetZedClass("Clot_Slasher");
        case "CC": return GetZedClass("Clot_Cyst");

        case "B": return GetZedClass("Bloat");

        case "CR": return GetZedClass("Crawler");
        case "CR*": return GetZedClass("CrawlerKing");

        case "HU": return GetZedClass("Husk");

        case "SI": return GetZedClass("Siren");

        case "ST": return GetZedClass("Stalker");

        case "G":
        case "GF": return GetZedClass("Gorefast");
        case "G*":
        case "GF*": return GetZedClass("GorefastDualBlade");

        case "FP": return GetZedClass("Fleshpound");
        case "SC": return GetZedClass("Scrake");

        case "C": return GetZedClass("Hans");
        case "C": return GetZedClass("Patriarch");
    }

    return none;
}




