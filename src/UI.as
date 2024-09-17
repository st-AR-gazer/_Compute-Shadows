bool g_isSelectingFiles = false;

void RenderInterface() {
    if (S_OpenInterface) {
        // UI::SetNextWindowSize(670, 300, UI::Cond::FirstUseEver);
        if (UI::Begin("Calculate Shadows", S_OpenInterface)) {

            UI::BeginTabBar("Tabs");
            if (UI::BeginTabItem(Icons::Folder + " Indexing and Folder Selection")) {
                RenderTab_IndexingAndFolderSelection();
                UI::EndTabItem();
            }
            if (g_isSelectingFiles) {
                if (UI::BeginTabItem(Icons::FilesO + " Further Selection")) {
                    RenderTab_FurtherSelection();
                    UI::EndTabItem();
                }
            }
            if (UI::BeginTabItem(Icons::Info + " Current State")) {
                RenderTab_CurrentState();
                UI::EndTabItem();
            }
            UI::EndTabBar();
        }

        UI::End();
    }
}
