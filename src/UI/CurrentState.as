int totalShadowsToCalculate = 0;
int shadowsCalculated = 0;
string currentFileBeingCalculated = "";
bool isCalculatingShadows = false;
int64 calculationStartTime = 0;
int64 calculationEndTime = 0;

void RenderTab_CurrentState() {
    UI::Text("Shadow Calculation Progress");
    UI::Separator();

    if (isCalculatingShadows || shadowsCalculated > 0) {
        int filesLeft = totalShadowsToCalculate - shadowsCalculated;
        float progress = totalShadowsToCalculate > 0 ? float(shadowsCalculated) / float(totalShadowsToCalculate) : 0;

        UI::Text("Total Files Selected: " + totalShadowsToCalculate);
        UI::Text("Files Processed: " + shadowsCalculated + " / " + totalShadowsToCalculate);
        UI::Text("Files Left: " + filesLeft);
        UI::ProgressBar(progress);

        if (isCalculatingShadows && currentFileBeingCalculated != "") {
            UI::Text("Currently Calculating Shadows for: " + currentFileBeingCalculated);
        }

        int64 currentTime = Time::Now;
        int64 elapsedTime = currentTime - calculationStartTime;
        string formattedElapsedTime = Text::Format("%02d:%02d:%02d", elapsedTime);

        UI::Text("Time Elapsed: " + formattedElapsedTime);

        if (!isCalculatingShadows && calculationEndTime > 0) {
            int64 totalTime = calculationEndTime - calculationStartTime;
            string formattedTotalTime = Text::Format("%02d:%02d:%02d", totalTime);
            UI::Text("Calculation Completed in: " + formattedTotalTime);
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
    currentFileBeingCalculated = "";
    calculationStartTime = Time::Now;
    calculationEndTime = 0;

    totalShadowsToCalculate = selectedFiles.Length;

    startnew(ComputeProcess::CalculateShadows);
}

void UpdateCalculationState(int processedFiles, const string &in currentFile) {
    shadowsCalculated = processedFiles;
    currentFileBeingCalculated = currentFile;
}