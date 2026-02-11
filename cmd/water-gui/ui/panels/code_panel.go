package panels

import (
	"water-ai/cmd/water-gui/client"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/layout"
	"fyne.io/fyne/v2/theme"
	"fyne.io/fyne/v2/widget"
)

// CodePanel displays code files with syntax highlighting
type CodePanel struct {
	widget.BaseWidget

	state *client.AppState

	// UI Components
	fileLabel   *widget.Label
	codeEntry   *widget.Entry
	scroll      *container.Scroll
}

// NewCodePanel creates a new code panel
func NewCodePanel(state *client.AppState) *CodePanel {
	cp := &CodePanel{
		state: state,
	}
	cp.ExtendBaseWidget(cp)
	cp.createUI()
	return cp
}

// createUI creates the code panel UI components
func (cp *CodePanel) createUI() {
	// File label
	cp.fileLabel = widget.NewLabel("No file selected")
	cp.fileLabel.TextStyle = fyne.TextStyle{Bold: true}

	// Code entry (read-only)
	cp.codeEntry = widget.NewMultiLineEntry()
	cp.codeEntry.SetPlaceHolder("Code will appear here...")
	cp.codeEntry.Wrapping = fyne.TextWrapWord
	cp.codeEntry.Disable() // Read-only

	// Scroll container
	cp.scroll = container.NewScroll(cp.codeEntry)
	cp.scroll.SetMinSize(fyne.NewSize(600, 400))
}

// SetContent sets the code content
func (cp *CodePanel) SetContent(content string) {
	cp.codeEntry.SetText(content)
}

// SetFile sets the current file name
func (cp *CodePanel) SetFile(filename string) {
	cp.fileLabel.SetText(filename)
}

// Refresh updates the code panel
func (cp *CodePanel) Refresh() {
	if cp.state.CodeContent != "" {
		cp.codeEntry.SetText(cp.state.CodeContent)
	}

	if cp.state.CodeFile != "" {
		cp.fileLabel.SetText(cp.state.CodeFile)
	}

	cp.BaseWidget.Refresh()
}

// CreateRenderer creates the widget renderer
func (cp *CodePanel) CreateRenderer() fyne.WidgetRenderer {
	// Toolbar
	copyBtn := widget.NewButtonWithIcon("Copy", theme.ContentCopyIcon(), func() {
		// TODO: Copy to clipboard
	})

	toolbar := container.NewHBox(
		widget.NewIcon(theme.FileTextIcon()),
		cp.fileLabel,
		layout.NewSpacer(),
		copyBtn,
	)

	// Main content
	content := container.NewBorder(
		toolbar,   // top
		nil,       // bottom
		nil,       // left
		nil,       // right
		cp.scroll, // center
	)

	return widget.NewSimpleRenderer(content)
}

// MinSize returns the minimum size
func (cp *CodePanel) MinSize() fyne.Size {
	return fyne.NewSize(600, 500)
}
