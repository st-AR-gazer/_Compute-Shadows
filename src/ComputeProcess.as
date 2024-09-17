namespace ComputeProcess {
    void CalculateShadows() {
        int shadowsCalculated = 0;

        Json::Value indexedHierarchy = IOManager::GetIndexedHierarchy();

        CalculateShadowsRecursively(indexedHierarchy, shadowsCalculated);

        Tab_CurrentState::isCalculatingShadows = false;
        Tab_CurrentState::calculationEndTime = Time::Now;
    }

    void CalculateShadowsRecursively(Json::Value@ folder, int &out shadowsCalculated) {
        if (folder.GetType() != Json::Type::Object) return;

        Json::Value files = folder["files"];
        for (uint i = 0; i < files.Length; i++) {
            string filePath = string(files[i]["filePath"]);

            EnterMap(filePath);

            ComputeShadows(selectedShadowsQuality);

            shadowsCalculated++;
            UpdateCalculationState(shadowsCalculated, filePath);
        }

        Json::Value subfolders = folder["folders"];
        for (uint i = 0; i < subfolders.Length; i++) {
            CalculateShadowsRecursively(subfolders[i], shadowsCalculated);
        }
    }

    void ComputeShadows(SelectedShadowsQuality quality) {
        CGameCtnApp@ app = GetApp();
        CGameCtnEditorCommon@ editor = cast<CGameCtnEditorCommon@>(app.Editor);
        CGameEditorPluginMapMapType@ pmt = editor.PluginMapType;

        pmt.ComputeShadows1(ConvertSelectedShadowQualityToEShadowsQuality(quality));
    }

    void EnterMap(wstring filePath) {
        auto app = cast<CTrackMania>(GetApp());
        app.ManiaTitleControlScriptAPI.EditMap4(filePath, "", "", "", MwFastBuffer<wstring>(), MwFastBuffer<wstring>(), true);
    }

    void UpdateCalculationState(int processedFiles, const string &in currentFile) {
        Tab_CurrentState::shadowsCalculated = processedFiles;
        Tab_CurrentState::currentFileBeingCalculated = currentFile;
    }

    CGameEditorPluginMap::EShadowsQuality ConvertSelectedShadowQualityToEShadowsQuality(SelectedShadowsQuality quality) {
        switch (quality) {
            case SelectedShadowsQuality::None:
                return CGameEditorPluginMap::EShadowsQuality::NotComputed;
            case SelectedShadowsQuality::VeryFast:
                return CGameEditorPluginMap::EShadowsQuality::VeryFast;
            case SelectedShadowsQuality::Fast:
                return CGameEditorPluginMap::EShadowsQuality::Fast;
            case SelectedShadowsQuality::Default:
                return CGameEditorPluginMap::EShadowsQuality::Default;
            case SelectedShadowsQuality::High:
                return CGameEditorPluginMap::EShadowsQuality::High;
            case SelectedShadowsQuality::Ultra:
                return CGameEditorPluginMap::EShadowsQuality::Ultra;
        }
        return CGameEditorPluginMap::EShadowsQuality::High;
    }
}
