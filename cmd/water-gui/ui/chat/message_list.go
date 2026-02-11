package chat

import (
	"fmt"
	"water-ai/cmd/water-gui/client"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/theme"
	"fyne.io/fyne/v2/widget"
)

// MessageList displays a list of chat messages
type MessageList struct {
	widget.BaseWidget

	state *client.AppState
	items []fyne.CanvasObject
}

// NewMessageList creates a new message list
func NewMessageList(state *client.AppState) *MessageList {
	ml := &MessageList{
		state: state,
	}
	ml.ExtendBaseWidget(ml)
	return ml
}

// Refresh updates the message list
func (ml *MessageList) Refresh() {
	ml.items = nil

	for _, msg := range ml.state.Messages {
		if msg.IsHidden {
			continue
		}
		ml.items = append(ml.items, NewMessageItem(msg))
	}

	ml.BaseWidget.Refresh()
}

// CreateRenderer creates the widget renderer
func (ml *MessageList) CreateRenderer() fyne.WidgetRenderer {
	container := container.NewVBox()
	return widget.NewSimpleRenderer(container)
}

// MinSize returns the minimum size
func (ml *MessageList) MinSize() fyne.Size {
	return fyne.NewSize(400, 500)
}

// MessageItem represents a single message in the chat
type MessageItem struct {
	widget.BaseWidget

	message client.Message
}

// NewMessageItem creates a new message item
func NewMessageItem(msg client.Message) *MessageItem {
	mi := &MessageItem{
		message: msg,
	}
	mi.ExtendBaseWidget(mi)
	return mi
}

// CreateRenderer creates the widget renderer
func (mi *MessageItem) CreateRenderer() fyne.WidgetRenderer {
	// Determine style based on role
	var icon fyne.Resource
	var roleLabel string
	var bgColor fyne.Color

	switch mi.message.Role {
	case "user":
		icon = theme.AccountIcon()
		roleLabel = "You"
		bgColor = theme.PrimaryColor()
	case "assistant":
		icon = theme.ComputerIcon()
		roleLabel = "Water AI"
		bgColor = theme.DisabledColor()
	default:
		icon = theme.InfoIcon()
		roleLabel = "System"
		bgColor = theme.DisabledColor()
	}

	// Create header
	header := container.NewHBox(
		widget.NewIcon(icon),
		widget.NewLabelWithStyle(roleLabel, fyne.TextAlignLeading, fyne.TextStyle{Bold: true}),
	)

	// Create content
	content := widget.NewLabel(mi.message.Content)
	content.Wrapping = fyne.TextWrapWord

	// Create message container
	messageContainer := container.NewVBox(
		header,
		widget.NewSeparator(),
		content,
	)

	// Add padding based on role
	var padding fyne.CanvasObject
	if mi.message.Role == "user" {
		padding = container.NewBorder(nil, nil, nil, widget.NewLabel(""), messageContainer)
	} else {
		padding = container.NewBorder(nil, nil, widget.NewLabel(""), nil, messageContainer)
	}

	// Create card-like appearance
	card := widget.NewCard("", "", padding)

	return widget.NewSimpleRenderer(card)
}

// MinSize returns the minimum size for the message item
func (mi *MessageItem) MinSize() fyne.Size {
	return fyne.NewSize(350, 80)
}

// String returns a string representation
func (mi *MessageItem) String() string {
	return fmt.Sprintf("Message[%s]: %s", mi.message.Role, mi.message.Content[:min(50, len(mi.message.Content))])
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
