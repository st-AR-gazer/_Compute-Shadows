// Variables needed for further selection
Json::Value[] selectedFiles;
dictionary filesMarkedForCalculation;
SelectedShadowsQuality shadowsQuality = SelectedShadowsQuality::High;

void RenderTab_FurtherSelection() {
    UI::Text("Further Selection of Files and Folders");
    UI::Separator();

    UI::Text("Default Shadows Quality for all selected files:");
    if (UI::BeginCombo("Shadows Quality (Apply to All)", ShadowQualityToString(shadowsQuality))) {
        if (UI::Selectable("None", shadowsQuality == SelectedShadowsQuality::None)) shadowsQuality = SelectedShadowsQuality::None;
        else if (UI::Selectable("Very Fast", shadowsQuality == SelectedShadowsQuality::VeryFast)) shadowsQuality = SelectedShadowsQuality::VeryFast;
        else if (UI::Selectable("Fast", shadowsQuality == SelectedShadowsQuality::Fast)) shadowsQuality = SelectedShadowsQuality::Fast;
        else if (UI::Selectable("Default", shadowsQuality == SelectedShadowsQuality::Default)) shadowsQuality = SelectedShadowsQuality::Default;
        else if (UI::Selectable("High", shadowsQuality == SelectedShadowsQuality::High)) shadowsQuality = SelectedShadowsQuality::High;
        else if (UI::Selectable("Ultra", shadowsQuality == SelectedShadowsQuality::Ultra)) shadowsQuality = SelectedShadowsQuality::Ultra;

        UI::EndCombo();
    }

    if (UI::Button("Apply " + ShadowQualityToString(shadowsQuality) + " to all")) {
        ApplyShadowQualityToAll();
    }

    UI::Separator();

    for (uint i = 0; i < selectedFiles.Length; i++) {
        string folderPath = string(selectedFiles[i]["folderPath"]);
        string filePath = string(selectedFiles[i]["filePath"]);
        SelectedShadowsQuality fileQuality = SelectedShadowsQuality(selectedFiles[i]["shadowQuality"]);

        if (UI::TreeNode(folderPath)) {
            RenderFileWithShadowOptions(filePath, fileQuality);
            UI::TreePop();
        }
    }
}

void RenderFileWithShadowOptions(const string &in filePath, SelectedShadowsQuality &out fileQuality) {
    bool calculateShadows = true;
    filesMarkedForCalculation.Get(filePath, calculateShadows);

    if (UI::Checkbox(filePath, calculateShadows)) {
        filesMarkedForCalculation.Set(filePath, calculateShadows);
    }

    if (UI::BeginCombo("Shadows Quality", ShadowQualityToString(fileQuality))) {
        if (UI::Selectable("None", fileQuality == SelectedShadowsQuality::None)) fileQuality = SelectedShadowsQuality::None;
        else if (UI::Selectable("Very Fast", fileQuality == SelectedShadowsQuality::VeryFast)) fileQuality = SelectedShadowsQuality::VeryFast;
        else if (UI::Selectable("Fast", fileQuality == SelectedShadowsQuality::Fast)) fileQuality = SelectedShadowsQuality::Fast;
        else if (UI::Selectable("Default", fileQuality == SelectedShadowsQuality::Default)) fileQuality = SelectedShadowsQuality::Default;
        else if (UI::Selectable("High", fileQuality == SelectedShadowsQuality::High)) fileQuality = SelectedShadowsQuality::High;
        else if (UI::Selectable("Ultra", fileQuality == SelectedShadowsQuality::Ultra)) fileQuality = SelectedShadowsQuality::Ultra;

        selectedFiles[i]["shadowQuality"] = int(fileQuality);
        UI::EndCombo();
    }
}

