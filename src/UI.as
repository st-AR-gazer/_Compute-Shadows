void RenderInterface() {
    if (S_OpenInterface) {
        // UI::SetNextWindowSize(670, 300, UI::Cond::FirstUseEver);
        UI::BeginTabBar("Tabs");
        if (UI::BeginTabItem(Icons::Users + " " + Icons::Folder + " Local Files")) {
            RenderTab_IndexingAndFolderSelection();
            UI::EndTabItem();
        }
        if (UI::BeginTabItem(Icons::Users + Icons::Info + "Current Loaded Records")) {
            RenderTab_CurrentState();
            UI::EndTabItem();
        
        }
        UI::EndTabBar();
    }
}

void RenderTab_IndexingAndFolderSelection() {
    if (UI::Begin("Calculate Shadows", S_OpenInterface)) {
        UI::BeginTabBar("");

        if (UI::Button("Index Maps Folder")) {
            io.IndexFiles(IO::FromUserGameFolder("Maps/"));
        }
        
        if (io.IsIndexingInProgress()) {
            UI::Text("Indexing in progress... " + io.GetFilesProcessed() + " / " + io.GetTotalFiles() + "(files left: " + (io.GetTotalFiles() - io.GetFilesProcessed()) + ")");
            UI::ProgressBar(io.GetFilesProcessed(), io.GetTotalFiles());
        }

        UI::Separator();

        if (UI::Button("Start computing shadows for folders")) {
            startnew(GetFolderToCompute);

            ComputeShadows(shadowsQuality);
        }

        if (UI::BeginCombo("Shadows Quality", shadowsQuality)) {
            if (UI::Selectable("None", false)) {
                shadowsQuality = SelectedShadowsQuality::None;
            } else if (UI::Selectable("Very Fast", false)) {
                shadowsQuality = SelectedShadowsQuality::VeryFast;
            } else if (UI::Selectable("Fast", false)) {
                shadowsQuality = SelectedShadowsQuality::Fast;
            } else if (UI::Selectable("Default", false)) {
                shadowsQuality = SelectedShadowsQuality::Default;
            } else if (UI::Selectable("High", false)) {
                shadowsQuality = SelectedShadowsQuality::High;
            } else if (UI::Selectable("Ultra", false)) {
                shadowsQuality = SelectedShadowsQuality::Ultra;
            }
            UI::EndCombo();
        }
    }
    UI::End();
}

SelectedShadowsQuality shadowsQuality = SelectedShadowsQuality::None;
enum SelectedShadowsQuality {
    None,
    VeryFast,
    Fast,
    Default,
    High,
    Ultra
}

void ComputeShadows(SelectedShadowsQuality quality) {
    CGameCtnApp@ app = GetApp();
    CGameCtnEditorCommon@ editor = cast<CGameCtnEditorCommon@>(app.Editor);
    CGameEditorPluginMapMapType@ pmt = editor.PluginMapType;

    pmt.ComputeShadows1(quality);
}