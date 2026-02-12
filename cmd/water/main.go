package main

import (
	"fmt"
	"os"

	"water-ai/resources"
	"water-ai/ui"
	"water-ai/ui/theme"

	"fyne.io/fyne/v2/app"
)

// Build-time variables injected via ldflags
var (
	Version   = "dev"
	GitCommit = "unknown"
	BuildDate = "unknown"
	GoVersion = "unknown"
)

func main() {
	// ---------------------------------------------------------
	// Version flag
	// ---------------------------------------------------------
	if len(os.Args) > 1 && (os.Args[1] == "--version" || os.Args[1] == "-v") {
		fmt.Printf("Water AI %s (commit: %s, built: %s, go: %s)\n",
			Version, GitCommit, BuildDate, GoVersion)
		return
	}

	// ---------------------------------------------------------
	// Launch the Fyne GUI (default)
	// ---------------------------------------------------------
	runGUI()
}

// runGUI launches the Fyne GUI on the main thread.
func runGUI() {
	a := app.NewWithID("com.waterai.gui")
	a.Settings().SetTheme(theme.NewWaterAITheme())
	a.SetIcon(resources.GetLogoOnly())

	mainWindow := ui.NewMainWindow(a)

	// Show the window and run the event loop (blocks until quit)
	mainWindow.ShowAndRun()
}
