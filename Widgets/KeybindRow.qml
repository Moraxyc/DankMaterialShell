import QtQuick
import QtQuick.Controls
import Quickshell.Wayland
import qs.Common
import qs.Widgets

Item {
    id: row

    property string token: ""
    property string configType: "dms"
    property string actionName: ""
    property var args: []
    property string shellCmd: ""
    property bool repeatEnabled: true
    property int cooldownMs: 0
    property bool allowWhenLocked: false
    property string overlayTitle: ""
    property bool expanded: false
    property bool recording: false
    property var panelWindow: null

    signal removeRequested()
    signal changed()

    width: parent.width
    height: mainContent.height

    function startRecording() {
        recording = true
        captureScope.forceActiveFocus()
    }

    function stopRecording() {
        recording = false
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

    function toConfigLine() {
        if (!row.token || !row.actionName) return ""

        const flags = []
        if (!row.repeatEnabled) flags.push("repeat=false")
        if (row.cooldownMs > 0) flags.push(`cooldown-ms=${row.cooldownMs}`)
        if (row.allowWhenLocked) flags.push("allow-when-locked=true")
        if (row.overlayTitle === "null") flags.push("hotkey-overlay-title=null")
        else if (row.overlayTitle.length > 0) {
            const escaped = row.overlayTitle.replace(/"/g, '\\"')
            flags.push(`hotkey-overlay-title="${escaped}"`)
        }

        let actionStr = ""
        if (row.actionName === "spawn") {
            const parts = (row.args || []).filter(s => s && s.length > 0)
                .map(s => `"${s.replace(/"/g, '\\"')}"`).join(" ")
            actionStr = `{ spawn ${parts}; }`
        } else if (row.actionName === "spawn-sh") {
            const escaped = (row.shellCmd || "").replace(/"/g, '\\"')
            actionStr = `{ spawn-sh "${escaped}"; }`
        } else {
            actionStr = `{ ${row.actionName}; }`
        }

        const head = flags.length ? `${row.token} ${flags.join(" ")} ` : `${row.token} `
        return head + actionStr
    }

    ShortcutsInhibitor {
        window: row.panelWindow
        enabled: row.recording
    }

    StyledRect {
        id: mainContent
        width: parent.width
        height: mainColumn.height
        color: Theme.surfaceContainerHigh
        radius: Theme.cornerRadius
        border.width: 0

        Column {
            id: mainColumn
            width: parent.width
            spacing: Theme.spacingM

            Column {
                width: parent.width
                spacing: Theme.spacingM

                Row {
                    width: parent.width
                    height: 60
                    spacing: Theme.spacingM
                    padding: Theme.spacingM

                    FocusScope {
                        id: captureScope
                        width: 180
                        height: 48
                        anchors.verticalCenter: parent.verticalCenter
                        focus: row.recording

                        Rectangle {
                            anchors.fill: parent
                            radius: Theme.cornerRadius
                            color: row.recording ? Theme.primaryContainer : Theme.surfaceVariant
                            border.color: row.recording ? Theme.primary : Theme.primarySelected
                            border.width: row.recording ? 2 : 1

                            StyledText {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spacingM
                                anchors.rightMargin: Theme.spacingM
                                text: row.token || (row.recording ? "Press combo..." : "Not set")
                                font.pixelSize: Theme.fontSizeMedium
                                color: row.token ? Theme.surfaceText : Theme.surfaceVariantText
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
                            if (!row.recording) return

                            if (event.key === Qt.Key_Escape) {
                                row.stopRecording()
                                event.accepted = true
                                return
                            }

                            const onlyModifier = [Qt.Key_Control, Qt.Key_Shift, Qt.Key_Alt, Qt.Key_Meta].includes(event.key)
                            if (onlyModifier) {
                                event.accepted = true
                                return
                            }

                            const mods = row.modsFromEvent(event.modifiers)
                            const key = row.xkbKeyFromQtKey(event.key)
                            if (key) {
                                const token = row.formatToken(mods, key)
                                row.token = token
                                row.changed()
                                row.stopRecording()
                                event.accepted = true
                            }
                        }

                        TapHandler {
                            acceptedButtons: Qt.AllButtons
                            enabled: row.recording
                            onTapped: (eventPoint, button) => {
                                const mods = row.modsFromEvent(eventPoint.modifiers)
                                let key = ""
                                if (button === Qt.LeftButton) key = "MouseLeft"
                                else if (button === Qt.RightButton) key = "MouseRight"
                                else if (button === Qt.MiddleButton) key = "MouseMiddle"
                                else if (button === Qt.BackButton) key = "MouseBack"
                                else if (button === Qt.ForwardButton) key = "MouseForward"

                                if (key) {
                                    const token = row.formatToken(mods, key)
                                    row.token = token
                                    row.changed()
                                    row.stopRecording()
                                }
                            }
                        }

                        WheelHandler {
                            enabled: row.recording
                            onWheel: (event) => {
                                const mods = row.modsFromEvent(event.modifiers)
                                let key = ""
                                if (Math.abs(event.angleDelta.y) >= Math.abs(event.angleDelta.x)) {
                                    key = event.angleDelta.y < 0 ? "WheelScrollDown" : "WheelScrollUp"
                                } else {
                                    key = event.angleDelta.x < 0 ? "WheelScrollRight" : "WheelScrollLeft"
                                }
                                const token = row.formatToken(mods, key)
                                row.token = token
                                row.changed()
                                row.stopRecording()
                                event.accepted = true
                            }
                        }
                    }

                    DankActionButton {
                        id: recordButton
                        width: 36
                        height: 36
                        circular: false
                        iconName: recording ? "close" : "radio_button_checked"
                        iconSize: Theme.iconSize - 4
                        iconColor: recording ? Theme.error : Theme.primary
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: recording ? row.stopRecording() : row.startRecording()
                    }

                    Column {
                        width: parent.width - captureScope.width - recordButton.width - expandButton.width - deleteButton.width - parent.padding * 2 - Theme.spacingM * 4
                        spacing: Theme.spacingXS
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            text: {
                                if (row.configType === "dms") {
                                    return row.actionName || "DMS Action..."
                                } else if (row.configType === "compositor") {
                                    return row.actionName || "Compositor Action..."
                                } else {
                                    if (row.args.length > 0 && row.args[0]) {
                                        return row.args[0]
                                    }
                                    return "Custom Command..."
                                }
                            }
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        StyledText {
                            text: {
                                if (row.configType === "dms") {
                                    return "DMS"
                                } else if (row.configType === "compositor") {
                                    return "Compositor"
                                } else {
                                    return "Custom Command"
                                }
                            }
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                        }
                    }

                    DankActionButton {
                        id: expandButton
                        width: 36
                        height: 36
                        circular: false
                        iconName: row.expanded ? "expand_less" : "expand_more"
                        iconSize: Theme.iconSize
                        iconColor: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: row.expanded = !row.expanded
                    }

                    DankActionButton {
                        id: deleteButton
                        width: 36
                        height: 36
                        circular: false
                        iconName: "delete"
                        iconSize: Theme.iconSize
                        iconColor: Theme.error
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: row.removeRequested()
                    }
                }
            }

            Column {
                width: parent.width
                spacing: Theme.spacingM
                padding: Theme.spacingM
                visible: row.expanded
                opacity: row.expanded ? 1 : 0

                DankButtonGroup {
                    width: parent.width - parent.padding * 2
                    model: ["dms", "compositor", "command"]
                    currentIndex: {
                        if (row.configType === "dms") return 0
                        if (row.configType === "compositor") return 1
                        if (row.configType === "command") return 2
                        return 0
                    }
                    onSelectionChanged: (index, selected) => {
                        if (selected) {
                            if (index === 0) row.configType = "dms"
                            else if (index === 1) row.configType = "compositor"
                            else if (index === 2) row.configType = "command"
                            row.changed()
                        }
                    }
                }

                Column {
                    width: parent.width - parent.padding * 2
                    spacing: Theme.spacingM
                    visible: row.configType === "dms"

                    DankDropdown {
                        width: parent.width
                        height: 48
                        text: "DMS Action"
                        currentValue: row.actionName || "Select action..."
                        options: [
                            "Spotlight Launcher",
                            "App Drawer",
                            "Control Center",
                            "Notifications",
                            "Settings",
                            "Power Menu",
                            "Lock Screen",
                            "Screenshot"
                        ]
                        onValueChanged: value => {
                            row.actionName = value
                            row.changed()
                        }
                    }
                }

                Column {
                    width: parent.width - parent.padding * 2
                    spacing: Theme.spacingM
                    visible: row.configType === "compositor"

                    DankDropdown {
                        width: parent.width
                        height: 48
                        text: "Compositor Action"
                        currentValue: row.actionName || "Select action..."
                        options: [
                            "quit",
                            "close-window",
                            "focus-workspace-down",
                            "focus-workspace-up",
                            "focus-window-down",
                            "focus-window-up",
                            "focus-window-left",
                            "focus-window-right",
                            "move-window-down",
                            "move-window-up",
                            "move-window-left",
                            "move-window-right",
                            "fullscreen-window",
                            "toggle-window-floating",
                            "screenshot",
                            "screenshot-screen",
                            "screenshot-window",
                            "do-screen-transition",
                            "toggle-keyboard-shortcuts-inhibit"
                        ]
                        onValueChanged: value => {
                            row.actionName = value
                            row.changed()
                        }
                    }
                }

                Column {
                    width: parent.width - parent.padding * 2
                    spacing: Theme.spacingS
                    visible: row.configType === "command"

                    StyledText {
                        text: "Command"
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceText
                    }

                    DankTextField {
                        width: parent.width
                        height: 48
                        text: row.args.length > 0 ? row.args[0] : ""
                        placeholderText: "Enter command (e.g., kitty, firefox)"
                        onTextChanged: {
                            if (row.args.length === 0) {
                                row.args = [text]
                            } else {
                                row.args[0] = text
                            }
                            row.actionName = "spawn"
                            row.changed()
                        }
                    }

                    StyledText {
                        text: "Arguments (optional)"
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceText
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        Repeater {
                            model: Math.max(1, row.args.length - 1)

                            Row {
                                width: parent.width
                                spacing: Theme.spacingS

                                DankTextField {
                                    width: parent.width - removeArgButton.width - Theme.spacingS
                                    height: 40
                                    text: row.args.length > index + 1 ? row.args[index + 1] : ""
                                    placeholderText: "Argument " + (index + 1)
                                    onTextChanged: {
                                        if (row.args.length > index + 1) {
                                            row.args[index + 1] = text
                                        } else {
                                            row.args.push(text)
                                        }
                                        row.changed()
                                    }
                                }

                                DankActionButton {
                                    id: removeArgButton
                                    width: 36
                                    height: 36
                                    circular: false
                                    iconName: "remove"
                                    iconSize: Theme.iconSize - 4
                                    iconColor: Theme.error
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: {
                                        row.args.splice(index + 1, 1)
                                        row.args = row.args.slice()
                                        row.changed()
                                    }
                                }
                            }
                        }

                        DankActionButton {
                            width: parent.width
                            height: 36
                            circular: false
                            iconName: "add"
                            iconSize: Theme.iconSize - 4
                            iconColor: Theme.primary
                            onClicked: {
                                row.args.push("")
                                row.args = row.args.slice()
                                row.changed()
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width - parent.padding * 2
                    height: 1
                    color: Theme.outline
                    opacity: 0.2
                }

                Column {
                    width: parent.width - parent.padding * 2
                    spacing: Theme.spacingM

                    StyledText {
                        text: "Options"
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankToggle {
                            id: repeatToggle
                            checked: row.repeatEnabled
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: checked => {
                                row.repeatEnabled = checked
                                row.changed()
                            }
                        }

                        StyledText {
                            text: "Allow repeat"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        StyledText {
                            text: "Cooldown (ms)"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        DankTextField {
                            width: 120
                            height: 40
                            text: row.cooldownMs.toString()
                            placeholderText: "0"
                            onTextChanged: {
                                const val = parseInt(text) || 0
                                if (row.cooldownMs !== val) {
                                    row.cooldownMs = val
                                    row.changed()
                                }
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankToggle {
                            id: lockedToggle
                            checked: row.allowWhenLocked
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: checked => {
                                row.allowWhenLocked = checked
                                row.changed()
                            }
                        }

                        StyledText {
                            text: "Allow when locked"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Hotkey overlay title"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                        }

                        DankTextField {
                            width: parent.width
                            height: 40
                            text: row.overlayTitle
                            placeholderText: ""
                            onTextChanged: {
                                if (row.overlayTitle !== text) {
                                    row.overlayTitle = text
                                    row.changed()
                                }
                            }
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.shortDuration
                        easing.type: Theme.standardEasing
                    }
                }
            }
        }
    }
}