import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

Item {
    id: root

    property bool recording: false
    property string capturedToken: ""

    signal captured(string xkbToken)

    implicitWidth: 320
    implicitHeight: captureRow.implicitHeight

    function startRecording() {
        root.recording = true
        captureField.forceActiveFocus()
        root.capturedToken = ""
    }

    function stopRecording(cancel) {
        root.recording = false
    }

    function modsFromEvent(mods) {
        const result = []
        if (mods & Qt.ControlModifier) result.push("Ctrl")
        if (mods & Qt.ShiftModifier) result.push("Shift")
        if (mods & Qt.AltModifier) result.push("Alt")
        if (mods & Qt.MetaModifier) result.push("Mod")
        return result
    }

    function xkbKeyFromQtKey(qk) {
        if (qk >= Qt.Key_A && qk <= Qt.Key_Z) {
            return String.fromCharCode(qk)
        }
        if (qk >= Qt.Key_0 && qk <= Qt.Key_9) {
            return String.fromCharCode(qk)
        }

        const map = {
            [Qt.Key_Left]: "Left",
            [Qt.Key_Right]: "Right",
            [Qt.Key_Up]: "Up",
            [Qt.Key_Down]: "Down",
            [Qt.Key_Comma]: "Comma",
            [Qt.Key_Period]: "Period",
            [Qt.Key_Slash]: "Slash",
            [Qt.Key_Semicolon]: "Semicolon",
            [Qt.Key_Apostrophe]: "Apostrophe",
            [Qt.Key_BracketLeft]: "BracketLeft",
            [Qt.Key_BracketRight]: "BracketRight",
            [Qt.Key_Backslash]: "Backslash",
            [Qt.Key_Minus]: "Minus",
            [Qt.Key_Equal]: "Equal",
            [Qt.Key_QuoteLeft]: "grave",
            [Qt.Key_Space]: "space",
            [Qt.Key_Print]: "Print",
            [Qt.Key_Return]: "Return",
            [Qt.Key_Enter]: "Return",
            [Qt.Key_Tab]: "Tab",
            [Qt.Key_Backspace]: "BackSpace",
            [Qt.Key_Delete]: "Delete",
            [Qt.Key_Insert]: "Insert",
            [Qt.Key_Home]: "Home",
            [Qt.Key_End]: "End",
            [Qt.Key_PageUp]: "Page_Up",
            [Qt.Key_PageDown]: "Page_Down"
        }

        if (qk >= Qt.Key_F1 && qk <= Qt.Key_F35) {
            return "F" + (qk - Qt.Key_F1 + 1)
        }

        return map[qk] || ""
    }

    function formatToken(mods, key) {
        return (mods.length ? mods.join("+") + "+" : "") + key
    }

    Row {
        id: captureRow
        width: parent.width
        spacing: Theme.spacingM

        FocusScope {
            id: captureField
            width: parent.width - recordButton.width - Theme.spacingM
            height: 48
            focus: root.recording

            Rectangle {
                id: captureBackground
                anchors.fill: parent
                radius: Theme.cornerRadius
                color: root.recording ? Theme.primaryContainer : Theme.surfaceVariant
                border.color: root.recording ? Theme.primary : Theme.primarySelected
                border.width: root.recording ? 2 : 1

                StyledText {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacingM
                    anchors.rightMargin: Theme.spacingM
                    text: root.capturedToken || (root.recording ? "Press keys / click / scroll... (Esc cancels)" : "Click Record to capture")
                    font.pixelSize: Theme.fontSizeMedium
                    color: root.capturedToken ? Theme.surfaceText : Theme.surfaceVariantText
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.shortDuration
                        easing.type: Theme.standardEasing
                    }
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: Theme.shortDuration
                        easing.type: Theme.standardEasing
                    }
                }
            }

            Keys.onPressed: (event) => {
                if (!root.recording) return

                if (event.key === Qt.Key_Escape) {
                    root.stopRecording(true)
                    event.accepted = true
                    return
                }

                const onlyModifier = [Qt.Key_Control, Qt.Key_Shift, Qt.Key_Alt, Qt.Key_Meta].includes(event.key)
                if (onlyModifier) {
                    event.accepted = true
                    return
                }

                const mods = root.modsFromEvent(event.modifiers)
                const key = root.xkbKeyFromQtKey(event.key)
                if (key) {
                    const token = root.formatToken(mods, key)
                    root.capturedToken = token
                    root.captured(token)
                    root.stopRecording(false)
                    event.accepted = true
                }
            }

            TapHandler {
                acceptedButtons: Qt.AllButtons
                enabled: root.recording
                onTapped: (eventPoint, button) => {
                    const mods = root.modsFromEvent(eventPoint.modifiers)
                    let key = ""
                    if (button === Qt.LeftButton) key = "MouseLeft"
                    else if (button === Qt.RightButton) key = "MouseRight"
                    else if (button === Qt.MiddleButton) key = "MouseMiddle"
                    else if (button === Qt.BackButton) key = "MouseBack"
                    else if (button === Qt.ForwardButton) key = "MouseForward"

                    if (key) {
                        const token = root.formatToken(mods, key)
                        root.capturedToken = token
                        root.captured(token)
                        root.stopRecording(false)
                    }
                }
            }

            WheelHandler {
                enabled: root.recording
                onWheel: (event) => {
                    const mods = root.modsFromEvent(event.modifiers)
                    let key = ""
                    if (Math.abs(event.angleDelta.y) >= Math.abs(event.angleDelta.x)) {
                        key = event.angleDelta.y < 0 ? "WheelScrollDown" : "WheelScrollUp"
                    } else {
                        key = event.angleDelta.x < 0 ? "WheelScrollRight" : "WheelScrollLeft"
                    }
                    const token = root.formatToken(mods, key)
                    root.capturedToken = token
                    root.captured(token)
                    root.stopRecording(false)
                    event.accepted = true
                }
            }
        }

        DankActionButton {
            id: recordButton
            width: 48
            height: 48
            circular: false
            iconName: recording ? "close" : "radio_button_checked"
            iconSize: Theme.iconSize
            iconColor: recording ? Theme.error : Theme.primary
            onClicked: recording ? root.stopRecording(true) : root.startRecording()
        }
    }
}