import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Common
import qs.Services

Item {
    id: root

    property var powermenu: null
    property var processlist: null
    property var controlCenter: null
    property var dash: null
    property var notepadVariants: null
    property var spotlight: null
    property var clipboard: null
    property var notifications: null
    property var settings: null

    function getFocusedScreenName() {
        if (CompositorService.isHyprland && Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.monitor) {
            return Hyprland.focusedWorkspace.monitor.name
        }
        if (CompositorService.isNiri && NiriService.currentOutput) {
            return NiriService.currentOutput
        }
        return ""
    }

    function getActiveNotepadInstance() {
        if (!notepadVariants || notepadVariants.instances.length === 0) {
            return null
        }

        if (notepadVariants.instances.length === 1) {
            return notepadVariants.instances[0]
        }

        var focusedScreen = getFocusedScreenName()
        if (focusedScreen && notepadVariants.instances.length > 0) {
            for (var i = 0; i < notepadVariants.instances.length; i++) {
                var slideout = notepadVariants.instances[i]
                if (slideout.modelData && slideout.modelData.name === focusedScreen) {
                    return slideout
                }
            }
        }

        for (var i = 0; i < notepadVariants.instances.length; i++) {
            var slideout = notepadVariants.instances[i]
            if (slideout.isVisible) {
                return slideout
            }
        }

        return notepadVariants.instances[0]
    }

    IpcHandler {
        function open() {
            powermenu.active = true
            if (powermenu.item)
                powermenu.item.open()
            return "POWERMENU_OPEN_SUCCESS"
        }

        function close() {
            if (powermenu.item) {
                powermenu.item.close()
                powermenu.active = false
            }
            return "POWERMENU_CLOSE_SUCCESS"
        }

        function toggle() {
            powermenu.active = true
            if (powermenu.item)
                powermenu.item.toggle()
            return "POWERMENU_TOGGLE_SUCCESS"
        }

        target: "powermenu"
    }

    IpcHandler {
        function open(): string {
            processlist.active = true
            if (processlist.item)
                processlist.item.show()
            return "PROCESSLIST_OPEN_SUCCESS"
        }

        function close(): string {
            if (processlist.item) {
                processlist.item.hide()
                processlist.active = false
            }
            return "PROCESSLIST_CLOSE_SUCCESS"
        }

        function toggle(): string {
            processlist.active = true
            if (processlist.item)
                processlist.item.toggle()
            return "PROCESSLIST_TOGGLE_SUCCESS"
        }

        target: "processlist"
    }

    IpcHandler {
        function open(): string {
            controlCenter.active = true
            if (controlCenter.item) {
                controlCenter.item.open()
                return "CONTROL_CENTER_OPEN_SUCCESS"
            }
            return "CONTROL_CENTER_OPEN_FAILED"
        }

        function close(): string {
            if (controlCenter.item) {
                controlCenter.item.close()
                controlCenter.active = false
                return "CONTROL_CENTER_CLOSE_SUCCESS"
            }
            return "CONTROL_CENTER_CLOSE_FAILED"
        }

        function toggle(): string {
            controlCenter.active = true
            if (controlCenter.item) {
                controlCenter.item.toggle()
                return "CONTROL_CENTER_TOGGLE_SUCCESS"
            }
            return "CONTROL_CENTER_TOGGLE_FAILED"
        }

        target: "control-center"
    }

    IpcHandler {
        function open(tab: string): string {
            dash.active = true
            if (dash.item) {
                switch (tab.toLowerCase()) {
                case "media":
                    dash.item.currentTabIndex = 1
                    break
                case "weather":
                    dash.item.currentTabIndex = SettingsData.weatherEnabled ? 2 : 0
                    break
                default:
                    dash.item.currentTabIndex = 0
                    break
                }
                dash.item.setTriggerPosition(Screen.width / 2, Theme.barHeight + Theme.spacingS, 100, "center", Screen)
                dash.item.dashVisible = true
                return "DASH_OPEN_SUCCESS"
            }
            return "DASH_OPEN_FAILED"
        }

        function close(): string {
            if (dash.item) {
                dash.item.dashVisible = false
                dash.active = false
                return "DASH_CLOSE_SUCCESS"
            }
            return "DASH_CLOSE_FAILED"
        }

        function toggle(tab: string): string {
            dash.active = true
            if (dash.item) {
                if (dash.item.dashVisible) {
                    dash.item.dashVisible = false
                } else {
                    switch (tab.toLowerCase()) {
                    case "media":
                        dash.item.currentTabIndex = 1
                        break
                    case "weather":
                        dash.item.currentTabIndex = SettingsData.weatherEnabled ? 2 : 0
                        break
                    default:
                        dash.item.currentTabIndex = 0
                        break
                    }
                    dash.item.setTriggerPosition(Screen.width / 2, Theme.barHeight + Theme.spacingS, 100, "center", Screen)
                    dash.item.dashVisible = true
                }
                return "DASH_TOGGLE_SUCCESS"
            }
            return "DASH_TOGGLE_FAILED"
        }

        target: "dash"
    }

    IpcHandler {
        function open(): string {
            var instance = getActiveNotepadInstance()
            if (instance) {
                instance.show()
                return "NOTEPAD_OPEN_SUCCESS"
            }
            return "NOTEPAD_OPEN_FAILED"
        }

        function close(): string {
            var instance = getActiveNotepadInstance()
            if (instance) {
                instance.hide()
                return "NOTEPAD_CLOSE_SUCCESS"
            }
            return "NOTEPAD_CLOSE_FAILED"
        }

        function toggle(): string {
            var instance = getActiveNotepadInstance()
            if (instance) {
                instance.toggle()
                return "NOTEPAD_TOGGLE_SUCCESS"
            }
            return "NOTEPAD_TOGGLE_FAILED"
        }

        target: "notepad"
    }

    IpcHandler {
        function open(): string {
            spotlight.active = true
            if (spotlight.item) {
                spotlight.item.show()
                return "SPOTLIGHT_OPEN_SUCCESS"
            }
            return "SPOTLIGHT_OPEN_FAILED"
        }

        function close(): string {
            if (spotlight.item) {
                spotlight.item.hide()
                spotlight.active = false
                return "SPOTLIGHT_CLOSE_SUCCESS"
            }
            return "SPOTLIGHT_CLOSE_FAILED"
        }

        function toggle(): string {
            spotlight.active = true
            if (spotlight.item) {
                spotlight.item.toggle()
                return "SPOTLIGHT_TOGGLE_SUCCESS"
            }
            return "SPOTLIGHT_TOGGLE_FAILED"
        }

        target: "spotlight"
    }

    IpcHandler {
        function open(): string {
            clipboard.active = true
            if (clipboard.item) {
                clipboard.item.show()
                return "CLIPBOARD_OPEN_SUCCESS"
            }
            return "CLIPBOARD_OPEN_FAILED"
        }

        function close(): string {
            if (clipboard.item) {
                clipboard.item.hide()
                clipboard.active = false
                return "CLIPBOARD_CLOSE_SUCCESS"
            }
            return "CLIPBOARD_CLOSE_FAILED"
        }

        function toggle(): string {
            clipboard.active = true
            if (clipboard.item) {
                clipboard.item.toggle()
                return "CLIPBOARD_TOGGLE_SUCCESS"
            }
            return "CLIPBOARD_TOGGLE_FAILED"
        }

        target: "clipboard"
    }

    IpcHandler {
        function open(): string {
            notifications.active = true
            if (notifications.item) {
                notifications.item.show()
                return "NOTIFICATION_MODAL_OPEN_SUCCESS"
            }
            return "NOTIFICATION_MODAL_OPEN_FAILED"
        }

        function close(): string {
            if (notifications.item) {
                notifications.item.hide()
                notifications.active = false
                return "NOTIFICATION_MODAL_CLOSE_SUCCESS"
            }
            return "NOTIFICATION_MODAL_CLOSE_FAILED"
        }

        function toggle(): string {
            notifications.active = true
            if (notifications.item) {
                notifications.item.toggle()
                return "NOTIFICATION_MODAL_TOGGLE_SUCCESS"
            }
            return "NOTIFICATION_MODAL_TOGGLE_FAILED"
        }

        target: "notifications"
    }

    IpcHandler {
        function open(): string {
            settings.active = true
            if (settings.item) {
                settings.item.show()
                return "SETTINGS_OPEN_SUCCESS"
            }
            return "SETTINGS_OPEN_FAILED"
        }

        function close(): string {
            if (settings.item) {
                settings.item.hide()
                settings.active = false
                return "SETTINGS_CLOSE_SUCCESS"
            }
            return "SETTINGS_CLOSE_FAILED"
        }

        function toggle(): string {
            settings.active = true
            if (settings.item) {
                settings.item.toggle()
                return "SETTINGS_TOGGLE_SUCCESS"
            }
            return "SETTINGS_TOGGLE_FAILED"
        }

        target: "settings"
    }

    IpcHandler {
        function browse(type: string) {
            settings.active = true
            if (settings.item) {
                if (type === "wallpaper") {
                    settings.item.wallpaperBrowser.allowStacking = false
                    settings.item.wallpaperBrowser.open()
                } else if (type === "profile") {
                    settings.item.profileBrowser.allowStacking = false
                    settings.item.profileBrowser.open()
                }
            }
        }

        target: "file"
    }
}