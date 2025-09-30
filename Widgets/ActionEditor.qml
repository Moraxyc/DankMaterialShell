import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

Item {
    id: root

    property string actionName: ""
    property var args: []
    property string shellCmd: ""

    signal changed()

    implicitWidth: actionRow.implicitWidth
    implicitHeight: actionRow.implicitHeight

    readonly property var niriActions: [
        "spawn",
        "spawn-sh",
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

    Column {
        id: actionRow
        width: parent.width
        spacing: Theme.spacingM

        DankDropdown {
            id: actionBox
            width: parent.width
            height: 48
            text: "Action"
            currentValue: root.actionName || "Select action..."
            options: root.niriActions
            onValueChanged: value => {
                root.actionName = value
                if (value === "spawn") {
                    if (root.args.length === 0) {
                        root.args = [""]
                    }
                } else if (value !== "spawn-sh") {
                    root.args = []
                    root.shellCmd = ""
                }
                root.changed()
            }
        }

        Column {
            width: parent.width
            spacing: Theme.spacingS
            visible: root.actionName === "spawn" && root.args.length > 0

            Repeater {
                model: root.actionName === "spawn" ? root.args.length : 0

                DankTextField {
                    width: parent.width
                    height: 48
                    placeholderText: index === 0 ? "program/binary" : "arg " + index
                    text: root.args[index] || ""
                    onTextChanged: {
                        if (root.args[index] !== text) {
                            root.args[index] = text
                            root.changed()
                        }
                    }
                }
            }

            Row {
                width: parent.width
                spacing: Theme.spacingS

                DankActionButton {
                    width: 36
                    height: 36
                    circular: false
                    iconName: "add"
                    iconSize: Theme.iconSize - 4
                    iconColor: Theme.primary
                    onClicked: {
                        root.args.push("")
                        root.args = root.args
                        root.changed()
                    }
                }

                DankActionButton {
                    width: 36
                    height: 36
                    circular: false
                    iconName: "remove"
                    iconSize: Theme.iconSize - 4
                    iconColor: Theme.error
                    enabled: root.args.length > 1
                    onClicked: {
                        if (root.args.length > 1) {
                            root.args.pop()
                            root.args = root.args
                            root.changed()
                        }
                    }
                }
            }
        }

        DankTextField {
            width: parent.width
            height: 48
            visible: root.actionName === "spawn-sh"
            placeholderText: "shell command"
            text: root.shellCmd
            onTextChanged: {
                if (root.shellCmd !== text) {
                    root.shellCmd = text
                    root.changed()
                }
            }
        }
    }
}