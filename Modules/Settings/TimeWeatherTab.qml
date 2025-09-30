import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

Item {
    id: timeWeatherTab

    DankFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn

            width: parent.width
            spacing: Theme.spacingXL

            StyledRect {
                width: parent.width
                height: timeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.width: 0

                Column {
                    id: timeSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "schedule"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM - toggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "24-Hour Format"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Use 24-hour time format instead of 12-hour AM/PM"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        DankToggle {
                            id: toggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.use24HourClock
                            onToggled: checked => {
                                return SettingsData.setClockFormat(checked)
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: dateSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.width: 0

                Column {
                    id: dateSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "calendar_today"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Date Format"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankDropdown {
                        width: parent.width
                        height: 50
                        text: "Top Bar Format"
                        description: "Preview: " + (SettingsData.clockDateFormat ? new Date().toLocaleDateString(Qt.locale(), SettingsData.clockDateFormat) : new Date().toLocaleDateString(Qt.locale(), "ddd d"))
                        currentValue: {
                            if (!SettingsData.clockDateFormat || SettingsData.clockDateFormat.length === 0) {
                                return "System Default"
                            }
                            const presets = [{
                                "format": "ddd d",
                                "label": "Day Date"
                            }, {
                                "format": "ddd MMM d",
                                "label": "Day Month Date"
                            }, {
                                "format": "MMM d",
                                "label": "Month Date"
                            }, {
                                "format": "M/d",
                                "label": "Numeric (M/D)"
                            }, {
                                "format": "d/M",
                                "label": "Numeric (D/M)"
                            }, {
                                "format": "ddd d MMM yyyy",
                                "label": "Full with Year"
                            }, {
                                "format": "yyyy-MM-dd",
                                "label": "ISO Date"
                            }, {
                                "format": "dddd, MMMM d",
                                "label": "Full Day & Month"
                            }]
                            const match = presets.find(p => {
                                return p.format === SettingsData.clockDateFormat
                            })
                            return match ? match.label : "Custom: " + SettingsData.clockDateFormat
                        }
                        options: ["System Default", "Day Date", "Day Month Date", "Month Date", "Numeric (M/D)", "Numeric (D/M)", "Full with Year", "ISO Date", "Full Day & Month", "Custom..."]
                        onValueChanged: value => {
                            const formatMap = {
                                "System Default": "",
                                "Day Date": "ddd d",
                                "Day Month Date": "ddd MMM d",
                                "Month Date": "MMM d",
                                "Numeric (M/D)": "M/d",
                                "Numeric (D/M)": "d/M",
                                "Full with Year": "ddd d MMM yyyy",
                                "ISO Date": "yyyy-MM-dd",
                                "Full Day & Month": "dddd, MMMM d"
                            }
                            if (value === "Custom...") {
                                customFormatInput.visible = true
                            } else {
                                customFormatInput.visible = false
                                SettingsData.setClockDateFormat(formatMap[value])
                            }
                        }
                    }

                    DankDropdown {
                        width: parent.width
                        height: 50
                        text: "Lock Screen Format"
                        description: "Preview: " + (SettingsData.lockDateFormat ? new Date().toLocaleDateString(Qt.locale(), SettingsData.lockDateFormat) : new Date().toLocaleDateString(Qt.locale(), Locale.LongFormat))
                        currentValue: {
                            if (!SettingsData.lockDateFormat || SettingsData.lockDateFormat.length === 0) {
                                return "System Default"
                            }
                            const presets = [{
                                "format": "ddd d",
                                "label": "Day Date"
                            }, {
                                "format": "ddd MMM d",
                                "label": "Day Month Date"
                            }, {
                                "format": "MMM d",
                                "label": "Month Date"
                            }, {
                                "format": "M/d",
                                "label": "Numeric (M/D)"
                            }, {
                                "format": "d/M",
                                "label": "Numeric (D/M)"
                            }, {
                                "format": "ddd d MMM yyyy",
                                "label": "Full with Year"
                            }, {
                                "format": "yyyy-MM-dd",
                                "label": "ISO Date"
                            }, {
                                "format": "dddd, MMMM d",
                                "label": "Full Day & Month"
                            }]
                            const match = presets.find(p => {
                                return p.format === SettingsData.lockDateFormat
                            })
                            return match ? match.label : "Custom: " + SettingsData.lockDateFormat
                        }
                        options: ["System Default", "Day Date", "Day Month Date", "Month Date", "Numeric (M/D)", "Numeric (D/M)", "Full with Year", "ISO Date", "Full Day & Month", "Custom..."]
                        onValueChanged: value => {
                            const formatMap = {
                                "System Default": "",
                                "Day Date": "ddd d",
                                "Day Month Date": "ddd MMM d",
                                "Month Date": "MMM d",
                                "Numeric (M/D)": "M/d",
                                "Numeric (D/M)": "d/M",
                                "Full with Year": "ddd d MMM yyyy",
                                "ISO Date": "yyyy-MM-dd",
                                "Full Day & Month": "dddd, MMMM d"
                            }
                            if (value === "Custom...") {
                                customLockFormatInput.visible = true
                            } else {
                                customLockFormatInput.visible = false
                                SettingsData.setLockDateFormat(formatMap[value])
                            }
                        }
                    }

                    DankTextField {
                        id: customFormatInput

                        width: parent.width
                        visible: false
                        placeholderText: "Enter custom top bar format (e.g., ddd MMM d)"
                        text: SettingsData.clockDateFormat
                        onTextChanged: {
                            if (visible && text)
                                SettingsData.setClockDateFormat(text)
                        }
                    }

                    DankTextField {
                        id: customLockFormatInput

                        width: parent.width
                        visible: false
                        placeholderText: "Enter custom lock screen format (e.g., dddd, MMMM d)"
                        text: SettingsData.lockDateFormat
                        onTextChanged: {
                            if (visible && text)
                                SettingsData.setLockDateFormat(text)
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: formatHelp.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Theme.surfaceContainerHigh
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
                        border.width: 0

                        Column {
                            id: formatHelp

                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Format Legend"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.primary
                                font.weight: Font.Medium
                            }

                            Row {
                                width: parent.width
                                spacing: Theme.spacingL

                                Column {
                                    width: (parent.width - Theme.spacingL) / 2
                                    spacing: 2

                                    StyledText {
                                        text: "• d - Day (1-31)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• dd - Day (01-31)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• ddd - Day name (Mon)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• dddd - Day name (Monday)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• M - Month (1-12)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }
                                }

                                Column {
                                    width: (parent.width - Theme.spacingL) / 2
                                    spacing: 2

                                    StyledText {
                                        text: "• MM - Month (01-12)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• MMM - Month (Jan)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• MMMM - Month (January)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• yy - Year (24)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• yyyy - Year (2024)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }
                                }
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: enableWeatherSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.width: 0

                Column {
                    id: enableWeatherSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "cloud"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM - enableToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Enable Weather"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Show weather information in top bar and control center"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        DankToggle {
                            id: enableToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.weatherEnabled
                            onToggled: checked => {
                                return SettingsData.setWeatherEnabled(checked)
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: temperatureSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.width: 0
                visible: SettingsData.weatherEnabled
                opacity: visible ? 1 : 0

                Column {
                    id: temperatureSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "thermostat"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM - temperatureToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Use Fahrenheit"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Use Fahrenheit instead of Celsius for temperature"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        DankToggle {
                            id: temperatureToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.useFahrenheit
                            onToggled: checked => {
                                return SettingsData.setTemperatureUnit(checked)
                            }
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: locationSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.width: 0
                visible: SettingsData.weatherEnabled
                opacity: visible ? 1 : 0

                Column {
                    id: locationSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "location_on"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM - autoLocationToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Auto Location"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Automatically determine your location using your IP address"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        DankToggle {
                            id: autoLocationToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.useAutoLocation
                            onToggled: checked => {
                                return SettingsData.setAutoLocation(checked)
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS
                        visible: !SettingsData.useAutoLocation

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Theme.outline
                            opacity: 0.2
                        }

                        StyledText {
                            text: "Custom Location"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            Column {
                                width: (parent.width - Theme.spacingM) / 2
                                spacing: Theme.spacingXS

                                StyledText {
                                    text: "Latitude"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                }

                                DankTextField {
                                    id: latitudeInput
                                    width: parent.width
                                    height: 48
                                    placeholderText: "40.7128"
                                    backgroundColor: Theme.surfaceVariant
                                    normalBorderColor: Theme.primarySelected
                                    focusedBorderColor: Theme.primary
                                    keyNavigationTab: longitudeInput

                                    Component.onCompleted: {
                                        if (SettingsData.weatherCoordinates) {
                                            const coords = SettingsData.weatherCoordinates.split(',')
                                            if (coords.length > 0) {
                                                text = coords[0].trim()
                                            }
                                        }
                                    }

                                    Connections {
                                        target: SettingsData
                                        function onWeatherCoordinatesChanged() {
                                            if (SettingsData.weatherCoordinates) {
                                                const coords = SettingsData.weatherCoordinates.split(',')
                                                if (coords.length > 0) {
                                                    latitudeInput.text = coords[0].trim()
                                                }
                                            }
                                        }
                                    }

                                    onTextEdited: {
                                        if (text && longitudeInput.text) {
                                            const coords = text + "," + longitudeInput.text
                                            SettingsData.weatherCoordinates = coords
                                            SettingsData.saveSettings()
                                        }
                                    }
                                }
                            }

                            Column {
                                width: (parent.width - Theme.spacingM) / 2
                                spacing: Theme.spacingXS

                                StyledText {
                                    text: "Longitude"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                }

                                DankTextField {
                                    id: longitudeInput
                                    width: parent.width
                                    height: 48
                                    placeholderText: "-74.0060"
                                    backgroundColor: Theme.surfaceVariant
                                    normalBorderColor: Theme.primarySelected
                                    focusedBorderColor: Theme.primary
                                    keyNavigationTab: locationSearchInput
                                    keyNavigationBacktab: latitudeInput

                                    Component.onCompleted: {
                                        if (SettingsData.weatherCoordinates) {
                                            const coords = SettingsData.weatherCoordinates.split(',')
                                            if (coords.length > 1) {
                                                text = coords[1].trim()
                                            }
                                        }
                                    }

                                    Connections {
                                        target: SettingsData
                                        function onWeatherCoordinatesChanged() {
                                            if (SettingsData.weatherCoordinates) {
                                                const coords = SettingsData.weatherCoordinates.split(',')
                                                if (coords.length > 1) {
                                                    longitudeInput.text = coords[1].trim()
                                                }
                                            }
                                        }
                                    }

                                    onTextEdited: {
                                        if (text && latitudeInput.text) {
                                            const coords = latitudeInput.text + "," + text
                                            SettingsData.weatherCoordinates = coords
                                            SettingsData.saveSettings()
                                        }
                                    }
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Location Search"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                font.weight: Font.Medium
                            }

                            DankLocationSearch {
                                id: locationSearchInput
                                width: parent.width
                                currentLocation: ""
                                placeholderText: "New York, NY"
                                keyNavigationBacktab: longitudeInput
                                onLocationSelected: (displayName, coordinates) => {
                                    SettingsData.setWeatherLocation(displayName, coordinates)

                                    const coords = coordinates.split(',')
                                    if (coords.length >= 2) {
                                        latitudeInput.text = coords[0].trim()
                                        longitudeInput.text = coords[1].trim()
                                    }
                                }
                            }
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }
                }
            }
        }
    }
}