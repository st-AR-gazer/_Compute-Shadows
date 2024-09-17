void Main() {
    PrepareDll();
}

[Setting category="Index Files" name="Open Interface"]
bool S_OpenInterface = true;

void RenderMenu() {
    if (UI::MenuItem("Index Files", "", S_OpenInterface)) {
        S_OpenInterface = !S_OpenInterface;
    }
}

SelectedShadowsQuality shadowsQuality = SelectedShadowsQuality::High;

enum SelectedShadowsQuality {
    None, VeryFast, Fast, Default, High, Ultra
}