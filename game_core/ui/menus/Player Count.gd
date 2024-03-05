extends LineEdit

@onready var NumberLineEdit = $"."
@onready var LineEditRegEx = RegEx.new()
var old_text = ""

func _ready() -> void:
	LineEditRegEx.compile("^[0-9]*$")


func _on_LineEdit_text_changed(new_text):
	if LineEditRegEx.search(new_text):
		old_text = str(new_text)
	else:
		NumberLineEdit.text = old_text
		NumberLineEdit.set_cursor_position(NumberLineEdit.text.length())
