package chat

import (
	"water-ai/cmd/water-gui/client"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/widget"
)

// ChatView represents the chat interface
type ChatView struct {
	widget.BaseWidget

	state    *client.AppState
	wsClient *client.WebSocketClient

	// UI Components
	messageList *MessageList
	inputArea   *InputArea
	scroll      *container.Scroll
}

// NewChatView creates a new chat view
func NewChatView(state *client.AppState, wsClient *client.WebSocketClient) *ChatView {
	cv := &ChatView{
		state:    state,
		wsClient: wsClient,
	}

	cv.ExtendBaseWidget(cv)
	cv.createUI()

	return cv
}

// createUI creates the chat UI components
func (cv *ChatView) createUI() {
	// Create message list
	cv.messageList = NewMessageList(cv.state)

	// Create scroll container for messages
	cv.scroll = container.NewScroll(cv.messageList)
	cv.scroll.SetMinSize(fyne.NewSize(400, 500))

	// Create input area
	cv.inputArea = NewInputArea(cv.state, cv.wsClient)
	cv.inputArea.OnSubmit = cv.handleSubmit
}

// handleSubmit handles message submission
func (cv *ChatView) handleSubmit(text string) {
	if text == "" {
		return
	}

	// Add user message to state
	msg := client.NewMessage("user", text)
	cv.state.AddMessage(msg)

	// Clear input
	cv.inputArea.SetText("")

	// Initialize agent if not already done
	if !cv.state.IsAgentInitialized {
		cv.wsClient.InitAgent(cv.state.SelectedModel, map[string]interface{}{}, 0)
	}

	// Send query
	cv.wsClient.SendQuery(text, len(cv.state.Messages) > 1, nil)

	// Refresh UI
	cv.Refresh()
}

// Refresh refreshes the chat view
func (cv *ChatView) Refresh() {
	cv.messageList.Refresh()
	cv.inputArea.Refresh()
	cv.BaseWidget.Refresh()
}

// CreateRenderer creates the widget renderer
func (cv *ChatView) CreateRenderer() fyne.WidgetRenderer {
	// Create the layout
	content := container.NewBorder(
		nil,           // top
		cv.inputArea,  // bottom
		nil,           // left
		nil,           // right
		cv.scroll,     // center
	)

	return widget.NewSimpleRenderer(content)
}
