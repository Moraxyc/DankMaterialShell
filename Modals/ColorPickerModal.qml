import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Common
import qs.Modals.Common
import qs.Services
import qs.Widgets

DankModal {
    id: root

    signal colorSelected(color selectedColor)

    property color currentColor: Theme.primary
    property real hue: 0
    property real saturation: 1
    property real value: 1
    property real alpha: 1
    property real gradientX: 0
    property real gradientY: 0
    property var recentColors: []

    function show() {
        currentColor = Theme.primary
        updateFromColor(currentColor)
        open()
    }

    function hide() {
        close()
    }

    function copyColorToClipboard(colorValue) {
        Quickshell.execDetached(["sh", "-c", `echo "${colorValue}" | wl-copy`])
        ToastService.showInfo(`Color ${colorValue} copied`)
        addToRecentColors(currentColor)
    }

    function addToRecentColors(color) {
        const colorStr = color.toString()
        let recent = recentColors.slice()
        recent = recent.filter(c => c !== colorStr)
        recent.unshift(colorStr)
        if (recent.length > 5) recent = recent.slice(0, 5)
        recentColors = recent
    }

    function updateFromColor(color) {
        hue = color.hsvHue
        saturation = color.hsvSaturation
        value = color.hsvValue
        alpha = color.a
        gradientX = saturation
        gradientY = 1 - value
    }

    function updateColor() {
        currentColor = Qt.hsva(hue, saturation, value, alpha)
    }

    function updateColorFromGradient(x, y) {
        saturation = Math.max(0, Math.min(1, x))
        value = Math.max(0, Math.min(1, 1 - y))
        updateColor()
    }

    function pickColorFromScreen() {
        close()
        eyedropperWindow.visible = true
        eyedropperTimer.start()
    }

    PanelWindow {
        id: eyedropperWindow

        property string screenshotPath: "/tmp/quickshell-eyedropper.png"
        property point mousePos: Qt.point(0, 0)
        property color hoveredColor: "transparent"

        visible: false
        color: "transparent"

        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        Timer {
            id: eyedropperTimer
            interval: 100
            repeat: true
            running: false
            onTriggered: {
                screenshotCapture.running = true
            }
        }

        Process {
            id: screenshotCapture
            running: false
            command: ["sh", "-c", `x=${Math.floor(eyedropperWindow.mousePos.x)}; y=${Math.floor(eyedropperWindow.mousePos.y)}; grim -g "$x,$y 1x1" -t ppm - 2>/dev/null | convert - -format '%[hex:p{0,0}]' txt:- 2>/dev/null | grep -o '#[0-9A-Fa-f]\\{6\\}'`]

            stdout: SplitParser {
                onRead: data => {
                    const colorStr = data.trim()
                    if (colorStr.length >= 7 && colorStr.startsWith('#')) {
                        eyedropperWindow.hoveredColor = colorStr
                    }
                }
            }
        }

        Rectangle {
            id: magnifier
            width: 140
            height: 180
            radius: Theme.cornerRadius
            color: Theme.surfaceContainer
            border.color: Theme.outlineStrong
            border.width: 2
            x: eyedropperWindow.mousePos.x + 30
            y: eyedropperWindow.mousePos.y + 30
            z: 100

            Column {
                anchors.fill: parent
                anchors.margins: Theme.spacingS
                spacing: Theme.spacingS

                Rectangle {
                    width: parent.width
                    height: 80
                    radius: Theme.cornerRadius
                    color: eyedropperWindow.hoveredColor
                    border.color: Theme.outlineStrong
                    border.width: 1
                }

                StyledText {
                    width: parent.width
                    text: eyedropperWindow.hoveredColor.toString()
                    font.pixelSize: Theme.fontSizeSmall
                    font.family: "monospace"
                    color: Theme.surfaceText
                    horizontalAlignment: Text.AlignHCenter
                }

                StyledText {
                    width: parent.width
                    text: "Click to copy"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceTextMedium
                    horizontalAlignment: Text.AlignHCenter
                }

                StyledText {
                    width: parent.width
                    text: "ESC to cancel"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceTextMedium
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Rectangle {
            width: 20
            height: 2
            color: "white"
            x: eyedropperWindow.mousePos.x - 10
            y: eyedropperWindow.mousePos.y
            z: 99

            Rectangle {
                anchors.fill: parent
                color: "black"
                anchors.margins: -0.5
                z: -1
            }
        }

        Rectangle {
            width: 2
            height: 20
            color: "white"
            x: eyedropperWindow.mousePos.x
            y: eyedropperWindow.mousePos.y - 10
            z: 99

            Rectangle {
                anchors.fill: parent
                color: "black"
                anchors.margins: -0.5
                z: -1
            }
        }

        FocusScope {
            anchors.fill: parent
            focus: true

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.BlankCursor

                onPositionChanged: mouse => {
                    eyedropperWindow.mousePos = Qt.point(mouse.x, mouse.y)
                }

                onClicked: mouse => {
                    const hexColor = eyedropperWindow.hoveredColor.toString()
                    copyColorToClipboard(hexColor)
                    root.currentColor = eyedropperWindow.hoveredColor
                    root.updateFromColor(eyedropperWindow.hoveredColor)
                    eyedropperTimer.stop()
                    eyedropperWindow.visible = false
                    root.open()
                }
            }

            Keys.onEscapePressed: event => {
                eyedropperTimer.stop()
                eyedropperWindow.visible = false
                root.open()
                event.accepted = true
            }

            Component.onCompleted: forceActiveFocus()
        }
    }

    width: 680
    height: 680
    shouldBeVisible: false

    onBackgroundClicked: () => {
        close()
    }

    readonly property var standardColors: [
        "#f44336", "#e91e63", "#9c27b0", "#673ab7", "#3f51b5", "#2196f3", "#03a9f4", "#00bcd4",
        "#009688", "#4caf50", "#8bc34a", "#cddc39", "#ffeb3b", "#ffc107", "#ff9800", "#ff5722",
        "#d32f2f", "#c2185b", "#7b1fa2", "#512da8", "#303f9f", "#1976d2", "#0288d1", "#0097a7",
        "#00796b", "#388e3c", "#689f38", "#afb42b", "#fbc02d", "#ffa000", "#f57c00", "#e64a19",
        "#c62828", "#ad1457", "#6a1b9a", "#4527a0", "#283593", "#1565c0", "#0277bd", "#00838f",
        "#00695c", "#2e7d32", "#558b2f", "#9e9d24", "#f9a825", "#ff8f00", "#ef6c00", "#d84315",
        "#ffffff", "#9e9e9e", "#212121"
    ]

    content: Component {
        FocusScope {
            id: colorContent

            anchors.fill: parent
            focus: true

            Keys.onEscapePressed: event => {
                close()
                event.accepted = true
            }

            Column {
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingM

                Row {
                    width: parent.width
                    spacing: Theme.spacingS

                    Column {
                        width: parent.width - 90
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Color Picker"
                            font.pixelSize: Theme.fontSizeLarge
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        StyledText {
                            text: "Select a color from the palette or use custom sliders"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceTextMedium
                        }
                    }

                    DankActionButton {
                        iconName: "colorize"
                        iconSize: Theme.iconSize - 4
                        iconColor: Theme.surfaceText
                        onClicked: () => {
                            pickColorFromScreen()
                        }
                    }

                    DankActionButton {
                        iconName: "close"
                        iconSize: Theme.iconSize - 4
                        iconColor: Theme.surfaceText
                        onClicked: () => {
                            close()
                        }
                    }
                }

                Row {
                    width: parent.width
                    spacing: Theme.spacingM

                    Rectangle {
                        id: gradientPicker
                        width: parent.width - 70
                        height: 280
                        radius: Theme.cornerRadius
                        border.color: Theme.outlineStrong
                        border.width: 1
                        clip: true

                        Rectangle {
                            anchors.fill: parent
                            color: Qt.hsva(root.hue, 1, 1, 1)

                            Rectangle {
                                anchors.fill: parent
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: "#ffffff" }
                                    GradientStop { position: 1.0; color: "transparent" }
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                gradient: Gradient {
                                    orientation: Gradient.Vertical
                                    GradientStop { position: 0.0; color: "transparent" }
                                    GradientStop { position: 1.0; color: "#000000" }
                                }
                            }
                        }

                        Rectangle {
                            id: pickerCircle
                            width: 16
                            height: 16
                            radius: 8
                            border.color: "white"
                            border.width: 2
                            color: "transparent"
                            x: root.gradientX * parent.width - width / 2
                            y: root.gradientY * parent.height - height / 2

                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width - 4
                                height: parent.height - 4
                                radius: width / 2
                                border.color: "black"
                                border.width: 1
                                color: "transparent"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.CrossCursor
                            onPressed: mouse => {
                                const x = Math.max(0, Math.min(1, mouse.x / width))
                                const y = Math.max(0, Math.min(1, mouse.y / height))
                                root.gradientX = x
                                root.gradientY = y
                                root.updateColorFromGradient(x, y)
                            }
                            onPositionChanged: mouse => {
                                if (pressed) {
                                    const x = Math.max(0, Math.min(1, mouse.x / width))
                                    const y = Math.max(0, Math.min(1, mouse.y / height))
                                    root.gradientX = x
                                    root.gradientY = y
                                    root.updateColorFromGradient(x, y)
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: hueSlider
                        width: 50
                        height: 280
                        radius: Theme.cornerRadius
                        border.color: Theme.outlineStrong
                        border.width: 1

                        gradient: Gradient {
                            orientation: Gradient.Vertical
                            GradientStop { position: 0.00; color: "#ff0000" }
                            GradientStop { position: 0.17; color: "#ffff00" }
                            GradientStop { position: 0.33; color: "#00ff00" }
                            GradientStop { position: 0.50; color: "#00ffff" }
                            GradientStop { position: 0.67; color: "#0000ff" }
                            GradientStop { position: 0.83; color: "#ff00ff" }
                            GradientStop { position: 1.00; color: "#ff0000" }
                        }

                        Rectangle {
                            id: hueIndicator
                            width: parent.width
                            height: 4
                            color: "white"
                            border.color: "black"
                            border.width: 1
                            y: root.hue * parent.height - height / 2
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.SizeVerCursor
                            onPressed: mouse => {
                                const h = Math.max(0, Math.min(1, mouse.y / height))
                                root.hue = h
                                root.updateColor()
                            }
                            onPositionChanged: mouse => {
                                if (pressed) {
                                    const h = Math.max(0, Math.min(1, mouse.y / height))
                                    root.hue = h
                                    root.updateColor()
                                }
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing: Theme.spacingS

                    StyledText {
                        text: "Material Colors"
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceText
                        font.weight: Font.Medium
                    }

                    GridView {
                        width: parent.width
                        height: 140
                        cellWidth: 38
                        cellHeight: 38
                        clip: true
                        interactive: false
                        model: root.standardColors

                        delegate: Rectangle {
                            width: 36
                            height: 36
                            color: modelData
                            radius: 4
                            border.color: Theme.outlineStrong
                            border.width: 1

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: () => {
                                    root.currentColor = modelData
                                    root.updateFromColor(root.currentColor)
                                }
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing: Theme.spacingS

                    Row {
                        width: parent.width
                        spacing: Theme.spacingS

                        Column {
                            width: 210
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Recent Colors"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                                visible: root.recentColors.length > 0
                            }

                            Row {
                                width: parent.width
                                spacing: Theme.spacingXS
                                visible: root.recentColors.length > 0

                                Repeater {
                                    model: root.recentColors

                                    Rectangle {
                                        width: 36
                                        height: 36
                                        radius: 4
                                        color: modelData
                                        border.color: Theme.outlineStrong
                                        border.width: 1

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: () => {
                                                root.currentColor = modelData
                                                root.updateFromColor(root.currentColor)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Column {
                            width: parent.width - 330
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Opacity"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            DankSlider {
                                width: parent.width
                                value: Math.round(root.alpha * 100)
                                minimum: 0
                                maximum: 100
                                showValue: false
                                onSliderValueChanged: (newValue) => {
                                    root.alpha = newValue / 100
                                    root.updateColor()
                                }
                            }
                        }

                        Rectangle {
                            width: 100
                            height: 50
                            radius: Theme.cornerRadius
                            color: root.currentColor
                            border.color: Theme.outlineStrong
                            border.width: 2
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Row {
                    width: parent.width
                    spacing: Theme.spacingS

                    StyledText {
                        text: "Hex:"
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceTextMedium
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    DankTextField {
                        id: hexInput
                        width: 160
                        height: 38
                        text: root.currentColor.toString()
                        font.pixelSize: Theme.fontSizeMedium - 1
                        textColor: Theme.surfaceText
                        placeholderText: "#000000"
                        backgroundColor: Theme.surfaceHover
                        borderWidth: 1
                        focusedBorderWidth: 2
                        anchors.verticalCenter: parent.verticalCenter
                        onAccepted: () => {
                            const color = Qt.color(text)
                            if (color) {
                                root.currentColor = color
                                root.updateFromColor(color)
                            }
                        }
                    }

                    Rectangle {
                        width: 80
                        height: 36
                        radius: Theme.cornerRadius
                        color: applyHexArea.containsMouse ? Qt.darker(Theme.primary, 1.1) : Theme.primary
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            anchors.centerIn: parent
                            text: "Apply"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.background
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: applyHexArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: () => {
                                const color = Qt.color(hexInput.text)
                                if (color) {
                                    root.currentColor = color
                                    root.updateFromColor(color)
                                }
                            }
                        }
                    }

                    Item {
                        width: parent.width - 460
                        height: 1
                    }

                    Rectangle {
                        width: 70
                        height: 36
                        radius: Theme.cornerRadius
                        color: cancelArea.containsMouse ? Theme.surfaceTextHover : "transparent"
                        border.color: Theme.surfaceVariantAlpha
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            id: cancelText
                            anchors.centerIn: parent
                            text: "Cancel"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: cancelArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: () => {
                                close()
                            }
                        }
                    }

                    Rectangle {
                        width: 70
                        height: 36
                        radius: Theme.cornerRadius
                        color: copyArea.containsMouse ? Qt.darker(Theme.primary, 1.1) : Theme.primary
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            id: copyText
                            anchors.centerIn: parent
                            text: "Copy"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.background
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: copyArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: () => {
                                const colorString = root.currentColor.toString()
                                copyColorToClipboard(colorString)
                                colorSelected(root.currentColor)
                                close()
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.shortDuration
                                easing.type: Theme.standardEasing
                            }
                        }
                    }
                }
            }
        }
    }
}