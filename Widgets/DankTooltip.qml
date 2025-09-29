import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common

PanelWindow {
    id: root

    property string text: ""
    property real targetX: 0
    property real targetY: 0
    property var targetScreen: null
    property bool alignLeft: false

    function show(text, x, y, screen, leftAlign) {
        if (!screen) {
            return
        }
        root.text = text
        targetScreen = screen
        alignLeft = leftAlign ?? false
        const screenX = screen.x || 0
        targetX = x - screenX
        targetY = y
        visible = true
    }

    function hide() {
        visible = false
        targetScreen = null
    }

    screen: targetScreen || Quickshell.screens[0]
    implicitWidth: Math.min(500, Math.max(120, textContent.implicitWidth + Theme.spacingM * 2))
    implicitHeight: textContent.implicitHeight + Theme.spacingS * 2
    color: "transparent"
    visible: false
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1

    anchors {
        top: true
        left: true
    }

    margins {
        left: alignLeft ? Math.round(targetX) : Math.round(targetX - implicitWidth / 2)
        top: Math.round(targetY - implicitHeight / 2)
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceContainerHigh
        radius: Theme.cornerRadius
        border.width: 1
        border.color: Theme.outlineMedium

        Text {
            id: textContent

            anchors.centerIn: parent
            text: root.text
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceText
            wrapMode: Text.NoWrap
            maximumLineCount: 1
        }
    }
}