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