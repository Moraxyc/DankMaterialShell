//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Hyprland
import qs.Common
import qs.Modals
import qs.Modals.Clipboard
import qs.Modals.Common
import qs.Modals.Settings
import qs.Modals.Spotlight
import qs.Modules
import qs.Modules.AppDrawer
import qs.Modules.DankDash
import qs.Modules.ControlCenter
import qs.Modules.Dock
import qs.Modules.Lock
import qs.Modules.Notifications.Center
import qs.Widgets
import "./Modules/Notepad"
import qs.Modules.Notifications.Popup
import qs.Modules.OSD
import qs.Modules.ProcessList
import qs.Modules.Settings
import qs.Modules.TopBar
import qs.Services

ShellRoot {
    id: root

    Component.onCompleted: {
        PortalService.init()
        // Initialize DisplayService night mode functionality
        DisplayService.nightModeEnabled
        // Initialize WallpaperCyclingService
        WallpaperCyclingService.cyclingActive
    }

    WallpaperBackground {}

    Lock {
        id: lock

        anchors.fill: parent
    }

    Variants {
        model: SettingsData.getFilteredScreens("topBar")

        delegate: TopBar {
            modelData: item
            notepadVariants: notepadSlideoutVariants
            onColorPickerRequested: {
                colorPickerModalLoader.active = true
                if (colorPickerModalLoader.item)
                    colorPickerModalLoader.item.show()
            }
        }
    }

    Variants {
        model: SettingsData.getFilteredScreens("dock")

        delegate: Dock {
            modelData: item
            contextMenu: dockContextMenuLoader.item ? dockContextMenuLoader.item : null
            Component.onCompleted: {
                dockContextMenuLoader.active = true
            }
        }
    }

    Loader {
        id: dankDashPopoutLoader

        active: false
        asynchronous: true

        sourceComponent: Component {
            DankDashPopout {
                id: dankDashPopout
            }
        }
    }

    LazyLoader {
        id: dockContextMenuLoader

        active: false

        DockContextMenu {
            id: dockContextMenu
        }
    }

    LazyLoader {
        id: notificationCenterLoader

        active: false

        NotificationCenterPopout {
            id: notificationCenter
        }
    }

    Variants {
        model: SettingsData.getFilteredScreens("notifications")

        delegate: NotificationPopupManager {
            modelData: item
        }
    }

    LazyLoader {
        id: controlCenterLoader

        active: false

        ControlCenterPopout {
            id: controlCenterPopout

            onPowerActionRequested: (action, title, message) => {
                                        powerConfirmModalLoader.active = true
                                        if (powerConfirmModalLoader.item) {
                                            powerConfirmModalLoader.item.confirmButtonColor = action === "poweroff" ? Theme.error : action === "reboot" ? Theme.warning : Theme.primary
                                            powerConfirmModalLoader.item.show(title, message, function () {
                                                switch (action) {
                                                case "logout":
                                                    SessionService.logout()
                                                    break
                                                case "suspend":
                                                    SessionService.suspend()
                                                    break
                                                case "hibernate":
                                                    SessionService.hibernate()
                                                    break
                                                case "reboot":
                                                    SessionService.reboot()
                                                    break
                                                case "poweroff":
                                                    SessionService.poweroff()
                                                    break
                                                }
                                            }, function () {})
                                        }
                                    }
            onLockRequested: {
                lock.activate()
            }
        }
    }

    LazyLoader {
        id: wifiPasswordModalLoader

        active: false

        WifiPasswordModal {
            id: wifiPasswordModal
        }
    }

    LazyLoader {
        id: networkInfoModalLoader

        active: false

        NetworkInfoModal {
            id: networkInfoModal
        }
    }

    LazyLoader {
        id: batteryPopoutLoader

        active: false

        BatteryPopout {
            id: batteryPopout
        }
    }

    LazyLoader {
        id: vpnPopoutLoader

        active: false

        VpnPopout {
            id: vpnPopout
        }
    }

    LazyLoader {
        id: powerMenuLoader

        active: false

        PowerMenu {
            id: powerMenu

            onPowerActionRequested: (action, title, message) => {
                                        powerConfirmModalLoader.active = true
                                        if (powerConfirmModalLoader.item) {
                                            powerConfirmModalLoader.item.confirmButtonColor = action === "poweroff" ? Theme.error : action === "reboot" ? Theme.warning : Theme.primary
                                            powerConfirmModalLoader.item.show(title, message, function () {
                                                switch (action) {
                                                case "logout":
                                                    SessionService.logout()
                                                    break
                                                case "suspend":
                                                    SessionService.suspend()
                                                    break
                                                case "hibernate":
                                                    SessionService.hibernate()
                                                    break
                                                case "reboot":
                                                    SessionService.reboot()
                                                    break
                                                case "poweroff":
                                                    SessionService.poweroff()
                                                    break
                                                }
                                            }, function () {})
                                        }
                                    }
        }
    }

    LazyLoader {
        id: powerConfirmModalLoader

        active: false

        ConfirmModal {
            id: powerConfirmModal
        }
    }

    LazyLoader {
        id: processListPopoutLoader

        active: false

        ProcessListPopout {
            id: processListPopout
        }
    }

    LazyLoader {
        id: settingsModalLoader

        active: false

        SettingsModal {
            id: settingsModal
        }
    }

    LazyLoader {
        id: appDrawerLoader

        active: false

        AppDrawerPopout {
            id: appDrawerPopout
        }
    }

    LazyLoader {
        id: spotlightModalLoader

        active: false

        SpotlightModal {
            id: spotlightModal
        }
    }

    LazyLoader {
        id: clipboardHistoryModalLoader

        active: false

        ClipboardHistoryModal {
            id: clipboardHistoryModalPopup
        }
    }

    LazyLoader {
        id: notificationModalLoader

        active: false

        NotificationModal {
            id: notificationModal
        }
    }

    LazyLoader {
        id: colorPickerModalLoader

        active: false

        ColorPickerModal {
            id: colorPickerModal
        }
    }

    LazyLoader {
        id: processListModalLoader

        active: false

        ProcessListModal {
            id: processListModal
        }
    }

    LazyLoader {
        id: systemUpdateLoader

        active: false

        SystemUpdatePopout {
            id: systemUpdatePopout
        }
    }

    Variants {
        id: notepadSlideoutVariants
        model: SettingsData.getFilteredScreens("notepad")

        delegate: DankSlideout {
            id: notepadSlideout
            modelData: item
            title: qsTr("Notepad")
            slideoutWidth: 480
            expandable: true
            expandedWidthValue: 960
            customTransparency: SettingsData.notepadTransparencyOverride

            content: Component {
                Notepad {
                    onHideRequested: {
                        notepadSlideout.hide()
                    }
                }
            }

            function toggle() {
                if (isVisible) {
                    hide()
                } else {
                    show()
                }
            }
        }
    }

    LazyLoader {
        id: powerMenuModalLoader

        active: false

        PowerMenuModal {
            id: powerMenuModal

            onPowerActionRequested: (action, title, message) => {
                                        powerConfirmModalLoader.active = true
                                        if (powerConfirmModalLoader.item) {
                                            powerConfirmModalLoader.item.confirmButtonColor = action === "poweroff" ? Theme.error : action === "reboot" ? Theme.warning : Theme.primary
                                            powerConfirmModalLoader.item.show(title, message, function () {
                                                switch (action) {
                                                case "logout":
                                                    SessionService.logout()
                                                    break
                                                case "suspend":
                                                    SessionService.suspend()
                                                    break
                                                case "hibernate":
                                                    SessionService.hibernate()
                                                    break
                                                case "reboot":
                                                    SessionService.reboot()
                                                    break
                                                case "poweroff":
                                                    SessionService.poweroff()
                                                    break
                                                }
                                            }, function () {})
                                        }
                                    }
        }
    }

    IPC {
        id: ipcHandlers

        powermenu: powerMenuModalLoader
        processlist: processListModalLoader
        controlCenter: controlCenterLoader
        dash: dankDashPopoutLoader
        notepadVariants: notepadSlideoutVariants
        spotlight: spotlightModalLoader
        clipboard: clipboardHistoryModalLoader
        notifications: notificationModalLoader
        settings: settingsModalLoader
    }

    Variants {
        model: SettingsData.getFilteredScreens("toast")

        delegate: Toast {
            modelData: item
            visible: ToastService.toastVisible
        }
    }

    Variants {
        model: SettingsData.getFilteredScreens("osd")

        delegate: VolumeOSD {
            modelData: item
        }
    }

    Variants {
        model: SettingsData.getFilteredScreens("osd")

        delegate: MicMuteOSD {
            modelData: item
        }
    }

    Variants {
        model: SettingsData.getFilteredScreens("osd")

        delegate: BrightnessOSD {
            modelData: item
        }
    }

    Variants {
        model: SettingsData.getFilteredScreens("osd")

        delegate: IdleInhibitorOSD {
            modelData: item
        }
    }
}
