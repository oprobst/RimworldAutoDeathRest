using RimWorld;
using Verse;

namespace AutoDeathRest
{
    /// <summary>
    /// Lazy-resolved references to defs that live in the Biotech DLC.
    /// Using DefDatabase with SilentFail keeps the mod from hard-crashing
    /// if a def name moves between RimWorld versions.
    /// </summary>
    internal static class DeathrestRefs
    {
        private static JobDef _deathrestJob;
        public static JobDef DeathrestJob =>
            _deathrestJob ?? (_deathrestJob = DefDatabase<JobDef>.GetNamedSilentFail("Deathrest"));

        private static HediffDef _exhaustionHediff;
        public static HediffDef DeathrestExhaustion =>
            _exhaustionHediff ?? (_exhaustionHediff = DefDatabase<HediffDef>.GetNamedSilentFail("DeathrestExhaustion"));

        private static ThingDef _deathrestCasket;
        public static ThingDef DeathrestCasket =>
            _deathrestCasket ?? (_deathrestCasket = DefDatabase<ThingDef>.GetNamedSilentFail("DeathrestCasket"));
    }
}
