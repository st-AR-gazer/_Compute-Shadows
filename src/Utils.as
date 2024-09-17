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

void ApplyShadowQualityToAll() {
    for (uint i = 0; i < selectedFiles.Length; i++) {
        selectedFiles[i]["shadowQuality"] = int(shadowsQuality);
    }
}

string ShadowQualityToString(SelectedShadowsQuality quality) {
    switch(quality) {
        case SelectedShadowsQuality::None: return "None";
        case SelectedShadowsQuality::VeryFast: return "Very Fast";
        case SelectedShadowsQuality::Fast: return "Fast";
        case SelectedShadowsQuality::Default: return "Default";
        case SelectedShadowsQuality::High: return "High";
        case SelectedShadowsQuality::Ultra: return "Ultra";
    }
    return "Unknown";
}
