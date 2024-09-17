namespace ComputeProcess {
    void CalculateShadows() {
        int shadowsCalculated = 0;

        for (uint i = 0; i < selectedFiles.Length; i++) {
            string filePath = string(selectedFiles[i]["filePath"]);
            SelectedShadowsQuality quality = SelectedShadowsQuality(selectedFiles[i]["shadowQuality"]);

            EnterMap(filePath);

            ComputeShadows(quality);

            shadowsCalculated++;
            UpdateCalculationState(shadowsCalculated, filePath);
        }

        isCalculatingShadows = false;
        calculationEndTime = Time::Now;
    }

    void ComputeShadows(SelectedShadowsQuality quality) {
        CGameCtnApp@ app = GetApp();
        CGameCtnEditorCommon@ editor = cast<CGameCtnEditorCommon@>(app.Editor);
        CGameEditorPluginMapMapType@ pmt = editor.PluginMapType;

        pmt.ComputeShadows1(quality);
    }

    void EnterMap(wstring filePath) {
        auto app = cast<CTrackMania>(GetApp());
        app.ManiaTitleControlScriptAPI.EditMap4(filePath, "", "", "", MwFastBuffer<wstring>(), MwFastBuffer<wstring>(), true);
    }
}
