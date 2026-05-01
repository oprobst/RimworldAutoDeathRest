using System.Collections.Generic;
using RimWorld;
using Verse;
using Verse.AI;

namespace AutoDeathRest
{
    /// <summary>
    /// Periodically scans colonist pawns with the Deathrest gene and issues
    /// a Deathrest job when their Need_Deathrest drops below the configured
    /// threshold — analogous to vanilla auto-consume for hemogen.
    ///
    /// Job construction mirrors vanilla FloatMenuOptionProvider_Deathrest:
    /// bed lookup via RestUtility.FindBedFor, forceSleep=true, JobTag.Misc.
    /// </summary>
    public class AutoDeathRestTracker : GameComponent
    {
        private const int CheckIntervalTicks = 250;

        // Per-pawn cooldown: if a queued job gets overridden (e.g. by a mental
        // state JobGiver) the deathrest never actually starts and we'd retry
        // every CheckIntervalTicks, spamming letters. Hold off for one in-game
        // hour after each attempt — and drop the entry once the pawn is
        // actually deathresting.
        private const int RetryCooldownTicks = 2500;
        private readonly Dictionary<int, int> _nextAttemptTick = new Dictionary<int, int>();

        public AutoDeathRestTracker(Game game) { }

        public override void GameComponentTick()
        {
            if (Find.TickManager.TicksGame % CheckIntervalTicks != 0) return;

            var settings = AutoDeathRestMod.Settings;
            if (settings == null || !settings.Enabled) return;

            foreach (var map in Find.Maps)
            {
                var colonists = map.mapPawns.FreeColonistsSpawned;
                for (int i = 0; i < colonists.Count; i++)
                {
                    ProcessPawn(colonists[i], settings);
                }
            }
        }

        private void ProcessPawn(Pawn pawn, AutoDeathRestSettings settings)
        {
            if (pawn?.genes == null || pawn.needs == null) return;

            var gene = pawn.genes.GetFirstGeneOfType<Gene_Deathrest>();
            if (gene == null || !gene.Active) return;

            var need = pawn.needs.TryGetNeed<Need_Deathrest>();
            if (need == null) return;

            if (need.Deathresting)
            {
                _nextAttemptTick.Remove(pawn.thingIDNumber);
                return;
            }

            if (!CanStartAutoDeathrest(pawn)) return;

            var jobDef = DeathrestRefs.DeathrestJob;
            if (jobDef == null) return;
            if (pawn.CurJobDef == jobDef) return;

            int now = Find.TickManager.TicksGame;
            if (_nextAttemptTick.TryGetValue(pawn.thingIDNumber, out int nextAllowed)
                && now < nextAllowed)
                return;

            bool exhaustion = settings.TriggerOnExhaustion
                && DeathrestRefs.DeathrestExhaustion != null
                && pawn.health.hediffSet.HasHediff(DeathrestRefs.DeathrestExhaustion);

            if (!exhaustion && need.CurLevelPercentage > settings.TriggerThresholdPercent)
                return;

            Building_Bed bed = FindBed(pawn, settings);

            Job job;
            if (bed != null)
            {
                job = JobMaker.MakeJob(jobDef, bed);
            }
            else if (!settings.RequireOwnedBed)
            {
                // Vanilla JobGiver_GetDeathrest fallback: deathrest on the ground.
                var spot = FindGroundSleepSpot(pawn);
                job = JobMaker.MakeJob(jobDef, spot);
            }
            else
            {
                return;
            }

            job.forceSleep = true;
            if (!pawn.jobs.TryTakeOrderedJob(job, JobTag.Misc)) return;

            if (settings.ForceAutoWake) gene.autoWake = true;

            // Even on a successful queue, the job may be overridden before it
            // actually starts (mental break interrupts, draft, etc.). Don't
            // retry — and don't fire another letter — until the cooldown elapses.
            _nextAttemptTick[pawn.thingIDNumber] = now + RetryCooldownTicks;

            if (settings.ShowNotification)
            {
                string title = "AutoDeathRest.LetterLabel".Translate(pawn.LabelShortCap);
                string body = exhaustion
                    ? "AutoDeathRest.LetterTextExhaustion".Translate(pawn.LabelShortCap)
                    : "AutoDeathRest.LetterText".Translate(
                        pawn.LabelShortCap,
                        (need.CurLevelPercentage * 100f).ToString("F0"));
                Find.LetterStack.ReceiveLetter(title, body, LetterDefOf.NeutralEvent, new LookTargets(pawn));
            }
        }

        private static bool CanStartAutoDeathrest(Pawn pawn)
        {
            // Auto-deathrest is a multi-day commitment — bail on anything that
            // would make the queued job get overridden or refused immediately.
            // Without this guard, mental breaks etc. caused the tracker to
            // re-trigger every CheckIntervalTicks and spam letters.
            if (pawn.Drafted) return false;
            if (pawn.InMentalState) return false;
            if (pawn.Downed) return false;
            if (pawn.IsBurning()) return false;
            if (pawn.IsWildMan()) return false;
            if (pawn.roping != null && pawn.roping.IsRoped) return false;
            if (pawn.IsColonyMech) return false;
            if (pawn.health?.capacities != null
                && !pawn.health.capacities.CanBeAwake) return false;
            return true;
        }

        private static Building_Bed FindBed(Pawn pawn, AutoDeathRestSettings settings)
        {
            // Assigned deathrest casket takes priority. RestUtility.FindBedFor
            // only prefers the casket when the pawn is *already* deathresting —
            // at trigger time we must route to it ourselves.
            var casket = pawn.ownership?.AssignedDeathrestCasket;
            if (casket != null && IsValidBedForPawn(pawn, casket))
                return casket;

            if (settings.RequireOwnedBed)
            {
                var owned = pawn.ownership?.OwnedBed;
                if (owned != null && IsValidBedForPawn(pawn, owned))
                    return owned;
                return null;
            }

            // Fallback: any humanlike bed RestUtility deems suitable (handles
            // pathing, reservations, sky-exposure, assignment rules, etc.).
            return RestUtility.FindBedFor(pawn);
        }

        private static bool IsValidBedForPawn(Pawn pawn, Building_Bed bed)
        {
            return RestUtility.IsValidBedFor(bed, pawn, pawn,
                checkSocialProperness: false,
                allowMedBedEvenIfSetToNoCare: false,
                ignoreOtherReservations: false,
                pawn.GuestStatus);
        }

        private static IntVec3 FindGroundSleepSpot(Pawn pawn)
        {
            var map = pawn.Map;
            var position = pawn.Position;
            for (int i = 0; i < 2; i++)
            {
                int radius = (i == 0) ? 4 : 12;
                if (CellFinder.TryRandomClosewalkCellNear(position, map, radius, out var result,
                    (IntVec3 x) => !x.IsForbidden(pawn) && !x.GetTerrain(map).avoidWander))
                {
                    return result;
                }
            }
            return CellFinder.RandomClosewalkCellNearNotForbidden(pawn, 4);
        }
    }
}
