namespace Tab_CurrentState {
    int totalShadowsToCalculate = 0;
    int shadowsCalculated = 0;
    string currentFileBeingCalculated = "";
    bool isCalculatingShadows = false;
    int64 calculationStartTime = 0;
    int64 calculationEndTime = 0;

    void Render() {
        UI::Text("Shadow Calculation Progress");
        UI::Separator();

        if (isCalculatingShadows) {
            int filesLeft = totalShadowsToCalculate - shadowsCalculated;
            float progress = totalShadowsToCalculate > 0 ? float(shadowsCalculated) / float(totalShadowsToCalculate) : 0;

            UI::Text("Files Processed: " + shadowsCalculated + " / " + totalShadowsToCalculate);
            UI::Text("Files Left: " + filesLeft);
            UI::ProgressBar(progress);

            if (currentFileBeingCalculated != "") {
                UI::Text("Currently Calculating Shadows for: " + currentFileBeingCalculated);
            }
        } else {
            UI::Text("No shadow calculations in progress.");
        }

        if (UI::Button("Start Calculating Shadows")) {
            StartShadowCalculation();
        }
    }

    void StartShadowCalculation() {
        isCalculatingShadows = true;
        shadowsCalculated = 0;
        totalShadowsToCalculate = IOManager::GetTotalFileCount();
        startnew(ComputeProcess::CalculateShadows);
    }
}
