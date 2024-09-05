void Main() {
    CGameCtnApp app = GetApp();
    CGameCtnEditorCommon editor = cast<CGameCtnEditorCommon@>(app.Editor);
    CGameEditorPluginMapMapType pmt = editor.PluginMapType;

    pmt.ComputeShadows1(CGameEditorPluginMap::EShadowsQuality::High);
}
