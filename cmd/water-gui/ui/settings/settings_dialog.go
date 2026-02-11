package settings

import (
	"water-ai/cmd/water-gui/client"
	"water-ai/cmd/water-gui/resources"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/canvas"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/dialog"
	"fyne.io/fyne/v2/layout"
	"fyne.io/fyne/v2/theme"
	"fyne.io/fyne/v2/widget"
)

// SettingsDialog represents the settings dialog
type SettingsDialog struct {
	parent   fyne.Window
	state    *client.AppState
	wsClient *client.WebSocketClient

	// UI Components
	dialog     dialog.Dialog
	modelEntry *widget.Select
	apiKeyEntry *widget.Entry
}

// NewSettingsDialog creates a new settings dialog
func NewSettingsDialog(parent fyne.Window, state *client.AppState, wsClient *client.WebSocketClient) *SettingsDialog {
	sd := &SettingsDialog{
		parent:   parent,
		state:    state,
		wsClient: wsClient,
	}
	sd.createUI()
	return sd
}

// createUI creates the settings dialog UI
func (sd *SettingsDialog) createUI() {
	// Create logo
	logoImg := canvas.NewImageFromResource(resources.GetLogoOnly())
	logoImg.SetMinSize(fyne.NewSize(64, 64))
	logoImg.FillMode = canvas.ImageFillContain

	// Model selection
	sd.modelEntry = widget.NewSelect([]string{
		"gpt-4",
		"gpt-4-turbo",
		"gpt-3.5-turbo",
		"claude-3-opus",
		"claude-3-sonnet",
		"claude-3-haiku",
		"gemini-pro",
	}, func(selected string) {
		sd.state.SelectedModel = selected
	})
	sd.modelEntry.SetSelected(sd.state.SelectedModel)

	modelRow := container.NewBorder(
		nil, nil,
		widget.NewLabel("Model:"),
		nil,
		sd.modelEntry,
	)

	// API Key entry
	sd.apiKeyEntry = widget.NewPasswordEntry()
	sd.apiKeyEntry.SetPlaceHolder("Enter your API key...")

	apiKeyRow := container.NewBorder(
		nil, nil,
		widget.NewLabel("API Key:"),
		nil,
		sd.apiKeyEntry,
	)

	// Connection status
	connectionStatus := widget.NewLabel("Disconnected")
	if sd.state.IsConnected {
		connectionStatus.SetText("Connected")
	}

	connectionRow := container.NewBorder(
		nil, nil,
		widget.NewLabel("Status:"),
		nil,
		connectionStatus,
	)

	// Workspace path
	workspacePath := widget.NewLabel(sd.state.WorkspacePath)
	if sd.state.WorkspacePath == "" {
		workspacePath.SetText("Not set")
	}

	workspaceRow := container.NewBorder(
		nil, nil,
		widget.NewLabel("Workspace:"),
		nil,
		workspacePath,
	)

	// VS Code button
	vscodeBtn := widget.NewButtonWithIcon("Open VS Code", theme.ComputerIcon(), func() {
		// TODO: Open VS Code
	})

	// Save button
	saveBtn := widget.NewButtonWithIcon("Save", theme.DocumentSaveIcon(), func() {
		sd.saveSettings()
	})

	// Cancel button
	cancelBtn := widget.NewButtonWithIcon("Cancel", theme.CancelIcon(), func() {
		sd.dialog.Hide()
	})

	// Button row
	buttonRow := container.NewHBox(
		layout.NewSpacer(),
		cancelBtn,
		saveBtn,
	)

	// Form layout
	form := container.NewVBox(
		container.NewCenter(logoImg),
		widget.NewSeparator(),
		modelRow,
		widget.NewSeparator(),
		apiKeyRow,
		widget.NewSeparator(),
		connectionRow,
		workspaceRow,
		widget.NewSeparator(),
		vscodeBtn,
		buttonRow,
	)

	// Create custom dialog
	sd.dialog = dialog.NewCustomWithoutButtons(
		"Settings",
		container.NewVScroll(form),
		sd.parent,
	)
}

// saveSettings saves the settings
func (sd *SettingsDialog) saveSettings() {
	// TODO: Implement settings persistence
	sd.dialog.Hide()
}

// Show shows the settings dialog
func (sd *SettingsDialog) Show() {
	sd.dialog.Show()
}

// Hide hides the settings dialog
func (sd *SettingsDialog) Hide() {
	sd.dialog.Hide()
}
