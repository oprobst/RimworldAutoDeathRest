using Verse;

namespace AutoDeathRest
{
    public class AutoDeathRestSettings : ModSettings
    {
        public bool Enabled = true;
        public float TriggerThresholdPercent = 0.05f;
        public bool TriggerOnExhaustion = true;
        public bool RequireOwnedBed = false;
        public bool ShowNotification = true;
        public bool ForceAutoWake = true;

        public override void ExposeData()
        {
            Scribe_Values.Look(ref Enabled, "Enabled", true);
            Scribe_Values.Look(ref TriggerThresholdPercent, "TriggerThresholdPercent", 0.05f);
            Scribe_Values.Look(ref TriggerOnExhaustion, "TriggerOnExhaustion", true);
            Scribe_Values.Look(ref RequireOwnedBed, "RequireOwnedBed", false);
            Scribe_Values.Look(ref ShowNotification, "ShowNotification", true);
            Scribe_Values.Look(ref ForceAutoWake, "ForceAutoWake", true);
            base.ExposeData();
        }
    }
}
