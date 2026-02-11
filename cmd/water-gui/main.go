package main

import (
	"water-ai/cmd/water-gui/resources"
	"water-ai/cmd/water-gui/ui"

	"fyne.io/fyne/v2/app"
)

func main() {
	// Create the Fyne application
	a := app.NewWithID("com.waterai.gui")

	// Set application icon
	a.SetIcon(resources.GetLogoOnly())

	// Create and run the main window
	mainWindow := ui.NewMainWindow(a)
	mainWindow.ShowAndRun()
}
