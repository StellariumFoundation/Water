package chat

import (
	"water-ai/cmd/water-gui/client"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/theme"
	"fyne.io/fyne/v2/widget"
)

// InputArea represents the chat input area
type InputArea struct {
	widget.BaseWidget

	state    *client.AppState
	wsClient *client.WebSocketClient

	// UI Components
	entry      *widget.Entry
	sendBtn    *widget.Button
	cancelBtn  *widget.Button
	attachBtn  *widget.Button

	// Callbacks
	OnSubmit func(text string)
}

// NewInputArea creates a new input area
func NewInputArea(state *client.AppState, wsClient *client.WebSocketClient) *InputArea {
	ia := &InputArea{
		state:    state,
		wsClient: wsClient,
	}
	ia.ExtendBaseWidget(ia)
	ia.createUI()
	return ia
}

// createUI creates the input area UI components
func (ia *InputArea) createUI() {
	// Create multi-line entry
	ia.entry = widget.NewMultiLineEntry()
	ia.entry.SetPlaceHolder("Give Water AI a task to work on...")
	ia.entry.Wrapping = fyne.TextWrapWord
	ia.entry.SetMinRowsVisible(3)

	// Handle Enter key (submit on Enter, newline on Shift+Enter)
	ia.entry.OnSubmitted = func(text string) {
		if ia.OnSubmit != nil {
			ia.OnSubmit(text)
		}
	}

	// Create send button
	ia.sendBtn = widget.NewButtonWithIcon("Send", theme.MailSendIcon(), func() {
		if ia.OnSubmit != nil {
			ia.OnSubmit(ia.entry.Text)
		}
	})

	// Create cancel button
	ia.cancelBtn = widget.NewButtonWithIcon("Cancel", theme.CancelIcon(), func() {
		ia.wsClient.CancelQuery()
	})

	// Create attach button
	ia.attachBtn = widget.NewButtonWithIcon("", theme.DocumentIcon(), func() {
		// TODO: Implement file attachment
	})
}

// SetText sets the entry text
func (ia *InputArea) SetText(text string) {
	ia.entry.SetText(text)
}

// GetText returns the entry text
func (ia *InputArea) GetText() string {
	return ia.entry.Text
}

// Refresh updates the input area state
func (ia *InputArea) Refresh() {
	// Update button states based on loading state
	if ia.state.IsLoading {
		ia.sendBtn.Disable()
		ia.cancelBtn.Enable()
	} else {
		ia.sendBtn.Enable()
		ia.cancelBtn.Disable()
	}

	// Update based on connection state
	if !ia.state.IsConnected {
		ia.sendBtn.Disable()
		ia.entry.SetPlaceHolder("Connecting to server...")
	} else {
		ia.entry.SetPlaceHolder("Give Water AI a task to work on...")
	}

	ia.BaseWidget.Refresh()
}

// CreateRenderer creates the widget renderer
func (ia *InputArea) CreateRenderer() fyne.WidgetRenderer {
	// Create button row
	buttonRow := container.NewHBox(
		ia.attachBtn,
		container.NewCenter(widget.NewLabel("Shift+Enter for newline")),
		layout.NewSpacer(),
		ia.cancelBtn,
		ia.sendBtn,
	)

	// Create main layout
	content := container.NewBorder(
		nil,        // top
		buttonRow,  // bottom
		nil,        // left
		nil,        // right
		ia.entry,   // center
	)

	return widget.NewSimpleRenderer(content)
}

// MinSize returns the minimum size
func (ia *InputArea) MinSize() fyne.Size {
	return fyne.NewSize(400, 100)
}
