namespace Tab_IndexingAndFolderSelection {
    dictionary foldersMarkedForCalculation;
    Json::Value[] selectedFiles;
    SelectedShadowsQuality selectedShadowsQuality = SelectedShadowsQuality::Default;

    void Render() {
        UI::Text("Indexing and Folder Selection");
        UI::Separator();
        UI::Text("Index Maps Folder");

        if (UI::Button("Start Indexing Maps Folder")) {
            IOManager::StartIndexing(IO::FromUserGameFolder("Maps/"));
        }

        if (IOManager::IsIndexingInProgress()) {
            int processed = IOManager::GetTotalFileCount();
            UI::Text("Indexing in progress... " + processed + " files found.");
        }

        UI::Separator();

        UI::Text("Select default Shadow Quality");

        if (UI::BeginCombo("Shadows Quality", ShadowQualityToString(selectedShadowsQuality))) {
            if (UI::Selectable("None", selectedShadowsQuality == SelectedShadowsQuality::None)) selectedShadowsQuality = SelectedShadowsQuality::None;
            else if (UI::Selectable("Very Fast", selectedShadowsQuality == SelectedShadowsQuality::VeryFast)) selectedShadowsQuality = SelectedShadowsQuality::VeryFast;
            else if (UI::Selectable("Fast", selectedShadowsQuality == SelectedShadowsQuality::Fast)) selectedShadowsQuality = SelectedShadowsQuality::Fast;
            else if (UI::Selectable("Default", selectedShadowsQuality == SelectedShadowsQuality::Default)) selectedShadowsQuality = SelectedShadowsQuality::Default;
            else if (UI::Selectable("High", selectedShadowsQuality == SelectedShadowsQuality::High)) selectedShadowsQuality = SelectedShadowsQuality::High;
            else if (UI::Selectable("Ultra", selectedShadowsQuality == SelectedShadowsQuality::Ultra)) selectedShadowsQuality = SelectedShadowsQuality::Ultra;

            UI::EndCombo();
        }

        UI::Separator();
        
        UI::Text("Select Folder(s) to Calculate Shadows");

        if (UI::Button("Confirm Selection")) {
            SaveSelectedFolders();
        }

        RenderFolderTree();
    }

    Json::Value indexedHierarchy;

    void RenderFolderTree() {
        indexedHierarchy = IOManager::GetIndexedHierarchy();

        RenderFolderTreeRecursively(indexedHierarchy, true);
    }

    string basePath = "C:\\Users\\AR_\\Documents\\Trackmania2020\\";

    void RenderFolderTreeRecursively(Json::Value@ folder, bool isRoot = false) {
        if (folder.GetType() != Json::Type::Object) {
            log("Error: Expected JSON object for folder.", LogLevel::Error);
            return;
        }

        if (!folder.HasKey("path") || folder["path"].GetType() != Json::Type::String) {
            return;
        }

        string folderPath = folder["path"];

        if (isRoot) {
            UI::Text("Base Folder: " + folderPath);
            UI::Separator();
        } else {
            folderPath = folderPath.Replace(basePath, "/");
        }

        if (UI::TreeNode(folderPath)) {
            bool selected = foldersMarkedForCalculation.Exists(folder["path"]);

            if (UI::Checkbox("Select Folder: " + folderPath, selected)) {
                MarkFolderForCalculation(folder["path"], selected);
            }

            if (folder.HasKey("folders") && folder["folders"].GetType() == Json::Type::Array) {
                Json::Value subfolders = folder["folders"];
                for (uint i = 0; i < subfolders.Length; i++) {
                    RenderFolderTreeRecursively(subfolders[i], false);
                }
            }

            UI::TreePop();
        }
    }

    void MarkFolderForCalculation(const string &in folderPath, bool selected) {
        if (selected) {
            foldersMarkedForCalculation.Set(folderPath, true);
        } else {
            foldersMarkedForCalculation.Delete(folderPath);
        }
    }

    Json::Value selectedFolders = Json::Array();
    
    void SaveSelectedFolders() {
        array<string> folderKeys = foldersMarkedForCalculation.GetKeys();
        
        for (uint i = 0; i < folderKeys.Length; i++) {
            selectedFolders.Add(folderKeys[i]);
        }
    }
}
