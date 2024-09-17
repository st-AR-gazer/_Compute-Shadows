namespace Tab_FurtherSelection {
    dictionary selectedFilesForCalculation;

    void Render() {
        UI::Text("Further Selection of Files");
        UI::Separator();

        Json::Value indexedHierarchy = IOManager::GetIndexedHierarchy();
        RenderSelectionTree(indexedHierarchy);
    }

    void RenderSelectionTree(Json::Value@ folder) {
        if (folder.GetType() != Json::Type::Object) return;

        string folderPath = folder["path"];

        if (UI::TreeNode(folderPath)) {
            Json::Value files = folder["files"];
            for (uint i = 0; i < files.Length; i++) {
                string filePath = string(files[i]["filePath"]);
                bool selected = selectedFilesForCalculation.Exists(filePath);

                if (UI::Checkbox(filePath, selected)) {
                    MarkFileForCalculation(filePath, selected);
                }
            }

            Json::Value subfolders = folder["folders"];
            for (uint i = 0; i < subfolders.Length; i++) {
                RenderSelectionTree(subfolders[i]);
            }

            UI::TreePop();
        }
    }

    void MarkFileForCalculation(const string &in filePath, bool selected) {
        if (selected) {
            selectedFilesForCalculation.Set(filePath, true);
        } else {
            selectedFilesForCalculation.Delete(filePath);
        }
    }
}
