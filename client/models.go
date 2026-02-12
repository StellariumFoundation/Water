package client

import (
	"time"
)

// Message represents a chat message
type Message struct {
	ID        string `json:"id"`
	Role      string `json:"role"` // user, assistant, system
	Content   string `json:"content"`
	Timestamp int64  `json:"timestamp"`
	IsHidden  bool   `json:"is_hidden"`
}

// Event types (used by UI event handling)
const (
	EventTypeConnectionEstablished = "connection_established"
	EventTypeAgentInitialized      = "agent_initialized"
	EventTypeProcessing            = "processing"
	EventTypeAgentResponse         = "agent_response"
	EventTypeStreamComplete        = "stream_complete"
	EventTypeError                 = "error"
	EventTypeSystem                = "system"
	EventTypePong                  = "pong"
	EventTypeWorkspaceInfo         = "workspace_info"
	EventTypeToolCall              = "tool_call"
	EventTypeToolResult            = "tool_result"
)

// ToolCallEvent represents a tool call event
type ToolCallEvent struct {
	ToolName  string                 `json:"tool_name"`
	ToolInput map[string]interface{} `json:"tool_input"`
}

// ToolResultEvent represents a tool result event
type ToolResultEvent struct {
	ToolName string      `json:"tool_name"`
	Result   interface{} `json:"result"`
}

// AppState holds the application state
type AppState struct {
	Messages           []Message
	CurrentQuestion    string
	IsLoading          bool
	IsConnected        bool
	IsAgentInitialized bool
	SelectedModel      string
	WorkspacePath      string
	VSCodeURL          string
	BrowserURL         string
	BrowserScreenshot  []byte
	CodeContent        string
	CodeFile           string
	TerminalOutput     string
}

// NewAppState creates a new AppState with default values
func NewAppState() *AppState {
	return &AppState{
		Messages:      []Message{},
		SelectedModel: "gpt-4",
	}
}

// AddMessage adds a new message to the state
func (s *AppState) AddMessage(msg Message) {
	s.Messages = append(s.Messages, msg)
}

// ClearMessages clears all messages
func (s *AppState) ClearMessages() {
	s.Messages = []Message{}
}

// NewMessage creates a new Message with current timestamp
func NewMessage(role, content string) Message {
	return Message{
		ID:        generateID(),
		Role:      role,
		Content:   content,
		Timestamp: time.Now().UnixMilli(),
		IsHidden:  false,
	}
}

// generateID generates a unique ID for messages
func generateID() string {
	return time.Now().Format("20060102150405.999999999")
}
