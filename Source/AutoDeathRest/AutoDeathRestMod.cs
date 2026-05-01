using HarmonyLib;
using UnityEngine;
using Verse;

namespace AutoDeathRest
{
    public class AutoDeathRestMod : Mod
    {
        public static AutoDeathRestSettings Settings;

        public AutoDeathRestMod(ModContentPack content) : base(content)
        {
            Settings = GetSettings<AutoDeathRestSettings>();
            new Harmony("oprobst.autodeathrest").PatchAll();
        }

        public override void DoSettingsWindowContents(Rect inRect)
        {
            var listing = new Listing_Standard();
            listing.Begin(inRect);

            listing.CheckboxLabeled("AutoDeathRest.Enabled".Translate(), ref Settings.Enabled,
                "AutoDeathRest.EnabledTip".Translate());
            listing.Gap(8f);

            listing.Label("AutoDeathRest.ThresholdLabel".Translate(
                (Settings.TriggerThresholdPercent * 100f).ToString("F0")));
            Settings.TriggerThresholdPercent = listing.Slider(Settings.TriggerThresholdPercent, 0.01f, 0.95f);
            listing.Gap(8f);

            listing.CheckboxLabeled("AutoDeathRest.TriggerOnExhaustion".Translate(),
                ref Settings.TriggerOnExhaustion,
                "AutoDeathRest.TriggerOnExhaustionTip".Translate());
            listing.Gap(8f);

            listing.CheckboxLabeled("AutoDeathRest.RequireOwnedBed".Translate(),
                ref Settings.RequireOwnedBed,
                "AutoDeathRest.RequireOwnedBedTip".Translate());
            listing.Gap(8f);

            listing.CheckboxLabeled("AutoDeathRest.ShowNotification".Translate(),
                ref Settings.ShowNotification,
                "AutoDeathRest.ShowNotificationTip".Translate());
            listing.Gap(8f);

            listing.CheckboxLabeled("AutoDeathRest.ForceAutoWake".Translate(),
                ref Settings.ForceAutoWake,
                "AutoDeathRest.ForceAutoWakeTip".Translate());

            listing.End();
            base.DoSettingsWindowContents(inRect);
        }

        public override string SettingsCategory() => "Auto-Deathrest";
    }
}
