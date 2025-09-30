import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

Item {
    id: keybindsTab

    property var parentModal: null

    ListModel {
        id: bindingsModel
    }

    function addBinding() {
        console.log("Adding binding, current count:", bindingsModel.count)
        bindingsModel.append({
            token: "",
            configType: "dms",
            actionName: "",
            args: [],
            shellCmd: "",
            repeatEnabled: true,
            cooldownMs: 0,
            allowWhenLocked: false,
            overlayTitle: ""
        })
        console.log("After append, count:", bindingsModel.count)
    }

    function removeBinding(index) {
        bindingsModel.remove(index)
    }

    function exportBindings() {
        const lines = []
        for (let i = 0; i < bindingsRepeater.count; i++) {
            const item = bindingsRepeater.itemAt(i)
            if (item) {
                const line = item.toConfigLine()
                if (line) {
                    const existingToken = line.split(" {")[0].trim()
                    const duplicate = lines.some(l => l.split(" {")[0].trim() === existingToken)
                    if (duplicate) {
                        console.warn("Duplicate binding found:", existingToken)
                    }
                    lines.push(line)
                }
            }
        }
        const block = "binds {\n    " + lines.join("\n    ") + "\n}\n"
        console.log("Exported bindings block:")
        console.log(block)
        return block
    }

    DankFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn

            width: parent.width
            spacing: Theme.spacingL

            StyledRect {
                width: parent.width
                height: headerSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.width: 0

                Row {
                    id: headerSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    DankIcon {
                        name: "keyboard"
                        size: Theme.iconSize
                        color: Theme.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        width: parent.width - Theme.iconSize - Theme.spacingM - addButton.width - Theme.spacingM
                        spacing: Theme.spacingXS
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            text: "Key Bindings Editor"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        StyledText {
                            text: "Configure keyboard shortcuts, mouse bindings, and scroll gestures"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                    }

                    DankActionButton {
                        id: addButton
                        width: 40
                        height: 40
                        circular: false
                        iconName: "add"
                        iconSize: Theme.iconSize
                        iconColor: Theme.primary
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: keybindsTab.addBinding()
                    }
                }
            }

            Column {
                width: parent.width
                spacing: Theme.spacingM

                StyledText {
                    text: "Bindings count: " + bindingsModel.count
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    visible: bindingsModel.count === 0
                }

                Repeater {
                    id: bindingsRepeater
                    model: bindingsModel

                    delegate: KeybindRow {
                        width: parent.width
                        token: model.token || ""
                        configType: model.configType || "dms"
                        actionName: model.actionName || ""
                        args: model.args || []
                        shellCmd: model.shellCmd || ""
                        repeatEnabled: model.repeatEnabled ?? true
                        cooldownMs: model.cooldownMs || 0
                        allowWhenLocked: model.allowWhenLocked ?? false
                        overlayTitle: model.overlayTitle || ""
                        panelWindow: keybindsTab.parentModal
                        onRemoveRequested: keybindsTab.removeBinding(index)
                        onChanged: {
                            bindingsModel.set(index, {
                                token: token,
                                configType: configType,
                                actionName: actionName,
                                args: args,
                                shellCmd: shellCmd,
                                repeatEnabled: repeatEnabled,
                                cooldownMs: cooldownMs,
                                allowWhenLocked: allowWhenLocked,
                                overlayTitle: overlayTitle
                            })
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: Theme.spacingXL
            }
        }
    }

    Component.onCompleted: {
        addBinding()
    }
}