void Main() {
    IOManager::Initialize();
}


[Setting category="Index Files" name="Open Interface"]
bool S_OpenInterface = true;

void RenderMenu() {
    if (UI::MenuItem("Index Files", "", S_OpenInterface)) {
        S_OpenInterface = !S_OpenInterface;
    }
}

SelectedShadowsQuality selectedShadowsQuality = SelectedShadowsQuality::High;
enum SelectedShadowsQuality {
    None, VeryFast, Fast, Default, High, Ultra
}

string ShadowQualityToString(SelectedShadowsQuality selectedShadowsQuality) {
    switch (selectedShadowsQuality) {
        case SelectedShadowsQuality::None: return "None";
        case SelectedShadowsQuality::VeryFast: return "Very Fast";
        case SelectedShadowsQuality::Fast: return "Fast";
        case SelectedShadowsQuality::Default: return "Default";
        case SelectedShadowsQuality::High: return "High";
        case SelectedShadowsQuality::Ultra: return "Ultra";
    }
    return "None";
}

SelectedShadowsQuality StringToShadowQuality(const string &in quality) {
    if (quality == "None") return SelectedShadowsQuality::None;
    if (quality == "Very Fast") return SelectedShadowsQuality::VeryFast;
    if (quality == "Fast") return SelectedShadowsQuality::Fast;
    if (quality == "Default") return SelectedShadowsQuality::Default;
    if (quality == "High") return SelectedShadowsQuality::High;
    if (quality == "Ultra") return SelectedShadowsQuality::Ultra;
    return SelectedShadowsQuality::High;
}