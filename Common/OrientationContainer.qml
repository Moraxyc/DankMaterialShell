import QtQuick

Item {
    id: root

    property bool isVertical: false
    property Component horizontalLayout
    property Component verticalLayout

    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: root.isVertical ? root.verticalLayout : root.horizontalLayout
    }
}