void RenderInterface() {
    if (S_OpenInterface) {
        if (UI::Begin("Calculate Shadows", S_OpenInterface)) {
            UI::BeginTabBar("Tabs");

            if (UI::BeginTabItem("Indexing and Folder Selection")) {
                Tab_IndexingAndFolderSelection::Render();
                UI::EndTabItem();
            }

            if (UI::BeginTabItem("Further Selection")) {
                Tab_FurtherSelection::Render();
                UI::EndTabItem();
            }

            if (UI::BeginTabItem("Current State")) {
                Tab_CurrentState::Render();
                UI::EndTabItem();
            }

            UI::EndTabBar();
        }
        UI::End();
    }
}
