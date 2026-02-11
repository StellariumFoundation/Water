package panels

import (
	"strings"
	"water-ai/cmd/water-gui/client"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/layout"
	"fyne.io/fyne/v2/theme"
	"fyne.io/fyne/v2/widget"
)

// TerminalPanel displays terminal output
type TerminalPanel struct {
	widget.BaseWidget

	state *client.AppState

	// UI Components
	output     *widget.Label
	scroll     *container.Scroll
	outputText strings.Builder
}

// NewTerminalPanel creates a new terminal panel
func NewTerminalPanel(state *client.AppState) *TerminalPanel {
	tp := &TerminalPanel{
		state: state,
	}
	tp.ExtendBaseWidget(tp)
	tp.createUI()
	return tp
}

// createUI creates the terminal panel UI components
func (tp *TerminalPanel) createUI() {
	// Output label (monospace)
	tp.output = widget.NewLabel("")
	tp.output.TextStyle = fyne.TextStyle{Monospace: true}
	tp.output.Wrapping = fyne.TextWrapWord
	tp.output.Alignment = fyne.TextAlignLeading

	// Scroll container
	tp.scroll = container.NewVScroll(tp.output)
	tp.scroll.SetMinSize(fyne.NewSize(600, 400))
}

// AppendOutput appends text to the terminal output
func (tp *TerminalPanel) AppendOutput(text string) {
	tp.outputText.WriteString(text)
	tp.outputText.WriteString("\n")
	tp.output.SetText(tp.outputText.String())
	
	// Scroll to bottom
	tp.scroll.ScrollToBottom()
}

// ClearOutput clears the terminal output
func (tp *TerminalPanel) ClearOutput() {
	tp.outputText.Reset()
	tp.output.SetText("")
}

// Refresh updates the terminal panel
func (tp *TerminalPanel) Refresh() {
	if tp.state.TerminalOutput != "" {
		tp.output.SetText(tp.state.TerminalOutput)
	}
	tp.BaseWidget.Refresh()
}

// CreateRenderer creates the widget renderer
func (tp *TerminalPanel) CreateRenderer() fyne.WidgetRenderer {
	// Toolbar
	clearBtn := widget.NewButtonWithIcon("Clear", theme.DeleteIcon(), func() {
		tp.ClearOutput()
	})

	toolbar := container.NewHBox(
		widget.NewIcon(theme.DocumentIcon()),
		widget.NewLabel("Terminal Output"),
		layout.NewSpacer(),
		clearBtn,
	)

	// Main content with dark background
	content := container.NewBorder(
		toolbar,  // top
		nil,      // bottom
		nil,      // left
		nil,      // right
		tp.scroll, // center
	)

	return widget.NewSimpleRenderer(content)
}

// MinSize returns the minimum size
func (tp *TerminalPanel) MinSize() fyne.Size {
	return fyne.NewSize(600, 500)
}
