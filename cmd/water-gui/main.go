package main

import (
	"water-ai/cmd/water-gui/resources"
	"water-ai/cmd/water-gui/ui"
	"water-ai/cmd/water-gui/ui/theme"

	"fyne.io/fyne/v2/app"
)

func main() {
	// Create the Fyne application
	a := app.NewWithID("com.waterai.gui")

	// Set the dark theme matching the existing frontend
	a.Settings().SetTheme(theme.NewWaterAITheme())

	// Set application icon
	a.SetIcon(resources.GetLogoOnly())

	// Create and run the main window
	mainWindow := ui.NewMainWindow(a)
	mainWindow.ShowAndRun()
}
