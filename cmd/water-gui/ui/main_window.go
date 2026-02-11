package ui

import (
	"water-ai/cmd/water-gui/client"
	"water-ai/cmd/water-gui/resources"
	"water-ai/cmd/water-gui/ui/chat"
	"water-ai/cmd/water-gui/ui/panels"
	"water-ai/cmd/water-gui/ui/settings"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/canvas"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/dialog"
	"fyne.io/fyne/v2/layout"
	"fyne.io/fyne/v2/theme"
	"fyne.io/fyne/v2/widget"
)

const (
	serverURL = "ws://localhost:7777/ws"
)

// MainWindow represents the main application window
type MainWindow struct {
	app         fyne.App
	window      fyne.Window
	state       *client.AppState
	wsClient    *client.WebSocketClient

	// UI Components
	chatView      *chat.ChatView
	browserPanel  *panels.BrowserPanel
	codePanel     *panels.CodePanel
	terminalPanel *panels.TerminalPanel
	settingsDialog *settings.SettingsDialog

	// Tabs
	panelTabs *container.AppTabs
}

// NewMainWindow creates a new main window
func NewMainWindow(app fyne.App) *MainWindow {
	mw := &MainWindow{
		app:   app,
		state: client.NewAppState(),
	}

	// Initialize WebSocket client
	mw.wsClient = client.NewWebSocketClient(serverURL, mw.state)
	mw.wsClient.SetOnStateChange(mw.onStateChange)
	mw.wsClient.SetOnEvent(mw.onEvent)
	mw.wsClient.SetOnConnected(mw.onConnected)
	mw.wsClient.SetOnDisconnected(mw.onDisconnected)

	// Create the window
	mw.window = app.NewWindow("Water AI")

	// Set window size
	mw.window.Resize(fyne.NewSize(1200, 800))

	// Create UI components
	mw.createUI()

	// Set up window close handler
	mw.window.SetCloseIntercept(mw.onClose)

	return mw
}

// createUI creates all UI components
func (mw *MainWindow) createUI() {
	// Create chat view
	mw.chatView = chat.NewChatView(mw.state, mw.wsClient)

	// Create panel views
	mw.browserPanel = panels.NewBrowserPanel(mw.state)
	mw.codePanel = panels.NewCodePanel(mw.state)
	mw.terminalPanel = panels.NewTerminalPanel(mw.state)

	// Create settings dialog
	mw.settingsDialog = settings.NewSettingsDialog(mw.window, mw.state, mw.wsClient)

	// Create tabbed panel
	mw.panelTabs = container.NewAppTabs(
		container.NewTabItemWithIcon("Browser", theme.ComputerIcon(), mw.browserPanel),
		container.NewTabItemWithIcon("Code", theme.FileTextIcon(), mw.codePanel),
		container.NewTabItemWithIcon("Terminal", theme.DocumentIcon(), mw.terminalPanel),
	)

	// Create header
	header := mw.createHeader()

	// Create status bar
	statusBar := mw.createStatusBar()

	// Create main content with split layout
	// Left side: Chat view (40%)
	// Right side: Tabbed panels (60%)
	content := container.NewHSplit(
		mw.chatView,
		mw.panelTabs,
	)
	content.SetOffset(0.4)

	// Main layout
	mainLayout := container.NewBorder(
		header,      // top
		statusBar,   // bottom
		nil,         // left
		nil,         // right
		content,     // center
	)

	mw.window.SetContent(mainLayout)
}

// createHeader creates the header bar
func (mw *MainWindow) createHeader() fyne.CanvasObject {
	// Create logo image
	logoImg := canvas.NewImageFromResource(resources.GetLogoOnly())
	logoImg.SetMinSize(fyne.NewSize(32, 32))
	logoImg.FillMode = canvas.ImageFillContain

	title := widget.NewLabelWithStyle("Water AI", fyne.TextAlignCenter, fyne.TextStyle{Bold: true})

	settingsBtn := widget.NewButtonWithIcon("", theme.SettingsIcon(), func() {
		mw.settingsDialog.Show()
	})

	return container.NewBorder(
		nil, nil,
		container.NewHBox(
			logoImg,
			title,
		),
		container.NewHBox(
			settingsBtn,
		),
	)
}

// createStatusBar creates the status bar
func (mw *MainWindow) createStatusBar() fyne.CanvasObject {
	connectionStatus := widget.NewLabel("Disconnected")
	connectionStatus.Importance = widget.LowImportance

	// Update connection status based on state
	if mw.state.IsConnected {
		connectionStatus.SetText("Connected")
	}

	return container.NewBorder(
		nil, nil,
		container.NewHBox(
			widget.NewIcon(theme.DownloadIcon()),
			connectionStatus,
		),
		nil,
	)
}

// onStateChange handles state changes
func (mw *MainWindow) onStateChange() {
	// Update UI components on the main thread
	mw.chatView.Refresh()
	mw.browserPanel.Refresh()
	mw.codePanel.Refresh()
	mw.terminalPanel.Refresh()
}

// onEvent handles WebSocket events
func (mw *MainWindow) onEvent(eventType string, content interface{}) {
	// Handle specific events
	switch eventType {
	case client.EventTypeToolCall:
		if tc, ok := content.(client.ToolCallEvent); ok {
			mw.handleToolCall(tc)
		}
	case client.EventTypeToolResult:
		if tr, ok := content.(client.ToolResultEvent); ok {
			mw.handleToolResult(tr)
		}
	}
}

// handleToolCall handles tool call events
func (mw *MainWindow) handleToolCall(tc client.ToolCallEvent) {
	// Switch to appropriate tab based on tool
	switch tc.ToolName {
	case "browser_view", "browser_click", "browser_enter_text", "browser_navigate":
		mw.panelTabs.SelectIndex(0) // Browser tab
	case "write_file", "read_file", "edit_file":
		mw.panelTabs.SelectIndex(1) // Code tab
	case "execute_command":
		mw.panelTabs.SelectIndex(2) // Terminal tab
	}
}

// handleToolResult handles tool result events
func (mw *MainWindow) handleToolResult(tr client.ToolResultEvent) {
	// Update panels based on tool result
	switch tr.ToolName {
	case "browser_view", "browser_screenshot":
		if screenshot, ok := tr.Result.(string); ok {
			mw.browserPanel.SetScreenshot(screenshot)
		}
	case "write_file", "read_file":
		if content, ok := tr.Result.(string); ok {
			mw.codePanel.SetContent(content)
		}
	case "execute_command":
		if output, ok := tr.Result.(string); ok {
			mw.terminalPanel.AppendOutput(output)
		}
	}
}

// onConnected handles connection established
func (mw *MainWindow) onConnected() {
	// Update status bar
}

// onDisconnected handles disconnection
func (mw *MainWindow) onDisconnected() {
	// Update status bar
}

// onClose handles window close
func (mw *MainWindow) onClose() {
	// Show confirmation dialog
	dialog.ShowConfirm(
		"Quit Water AI?",
		"Are you sure you want to quit?",
		func(confirmed bool) {
			if confirmed {
				mw.wsClient.Disconnect()
				mw.window.Close()
			}
		},
		mw.window,
	)
}

// ShowAndRun shows the window and runs the application
func (mw *MainWindow) ShowAndRun() {
	// Show the window
	mw.window.Show()

	// Attempt to connect to the server
	go func() {
		if err := mw.wsClient.Connect(); err != nil {
			// Show error dialog on main thread
			mw.app.SendNotification(&fyne.Notification{
				Title:   "Connection Error",
				Content: "Failed to connect to server: " + err.Error(),
			})
		}
	}()

	// Run the application
	mw.app.Run()
}

// Refresh refreshes the UI
func (mw *MainWindow) Refresh() {
	mw.window.Content().Refresh()
}
