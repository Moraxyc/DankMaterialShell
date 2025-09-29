import QtQuick
import Quickshell.Services.UPower
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
    id: battery

    property bool isVertical: axis?.isVertical ?? false
    property var axis: null
    property bool batteryPopupVisible: false
    property string section: "right"
    property var popupTarget: null
    property var parentScreen: null
    property real widgetThickness: 30
    property real barThickness: 48
    readonly property real horizontalPadding: SettingsData.dankBarNoBackground ? 0 : Math.max(Theme.spacingXS, Theme.spacingS * (widgetThickness / 30))

    signal toggleBatteryPopup()

    width: isVertical ? widgetThickness : (batteryContent.implicitWidth + horizontalPadding * 2)
    height: isVertical ? (batteryColumn.implicitHeight + horizontalPadding * 2) : widgetThickness
    radius: SettingsData.dankBarNoBackground ? 0 : Theme.cornerRadius
    color: {
        if (SettingsData.dankBarNoBackground) {
            return "transparent";
        }

        const baseColor = batteryArea.containsMouse ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor;
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency);
    }
    visible: true

    Column {
        id: batteryColumn
        visible: battery.isVertical
        anchors.centerIn: parent
        spacing: 1

        DankIcon {
            name: BatteryService.getBatteryIcon()
            size: Theme.iconSize - 8
            color: {
                if (!BatteryService.batteryAvailable) {
                    return Theme.surfaceText
                }

                if (BatteryService.isLowBattery && !BatteryService.isCharging) {
                    return Theme.error
                }

                if (BatteryService.isCharging || BatteryService.isPluggedIn) {
                    return Theme.primary
                }

                return Theme.surfaceText
            }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        StyledText {
            text: BatteryService.batteryLevel.toString()
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
            color: Theme.surfaceText
            anchors.horizontalCenter: parent.horizontalCenter
            visible: BatteryService.batteryAvailable
        }
    }

    Row {
        id: batteryContent
        visible: !battery.isVertical
        anchors.centerIn: parent
        spacing: SettingsData.dankBarNoBackground ? 1 : 2

        DankIcon {
            name: BatteryService.getBatteryIcon()
            size: Theme.iconSize - 6
            color: {
                if (!BatteryService.batteryAvailable) {
                    return Theme.surfaceText;
                }

                if (BatteryService.isLowBattery && !BatteryService.isCharging) {
                    return Theme.error;
                }

                if (BatteryService.isCharging || BatteryService.isPluggedIn) {
                    return Theme.primary;
                }

                return Theme.surfaceText;
            }
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: `${BatteryService.batteryLevel}%`
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
            color: Theme.surfaceText
            anchors.verticalCenter: parent.verticalCenter
            visible: BatteryService.batteryAvailable
        }

    }

    MouseArea {
        id: batteryArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: {
            if (popupTarget && popupTarget.setTriggerPosition) {
                const globalPos = mapToGlobal(0, 0)
                const currentScreen = parentScreen || Screen
                const pos = SettingsData.getPopupTriggerPosition(globalPos, currentScreen, barThickness, width)
                popupTarget.setTriggerPosition(pos.x, pos.y, pos.width, section, currentScreen)
            }
            toggleBatteryPopup();
        }
    }

    Rectangle {
        id: batteryTooltip

        width: Math.max(120, tooltipText.contentWidth + Theme.spacingM * 2)
        height: tooltipText.contentHeight + Theme.spacingS * 2
        radius: Theme.cornerRadius
        color: Theme.widgetBaseBackgroundColor
        border.color: Theme.surfaceVariantAlpha
        border.width: 1
        visible: batteryArea.containsMouse && !batteryPopupVisible
        anchors.bottom: parent.top
        anchors.bottomMargin: Theme.spacingS
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: batteryArea.containsMouse ? 1 : 0

        Column {
            anchors.centerIn: parent
            spacing: 2

            StyledText {
                id: tooltipText

                text: {
                    if (!BatteryService.batteryAvailable) {
                        if (typeof PowerProfiles === "undefined") {
                            return "Power Management";
                        }

                        switch (PowerProfiles.profile) {
                        case PowerProfile.PowerSaver:
                            return "Power Profile: Power Saver";
                        case PowerProfile.Performance:
                            return "Power Profile: Performance";
                        default:
                            return "Power Profile: Balanced";
                        }
                    }
                    const status = BatteryService.batteryStatus;
                    const level = `${BatteryService.batteryLevel}%`;
                    const time = BatteryService.formatTimeRemaining();
                    if (time !== "Unknown") {
                        return `${status} • ${level} • ${time}`;
                    } else {
                        return `${status} • ${level}`;
                    }
                }
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                horizontalAlignment: Text.AlignHCenter
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
