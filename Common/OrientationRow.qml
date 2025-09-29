import QtQuick

Loader {
    id: root

    property bool isVertical: false
    property alias spacing: layout.spacing
    property alias children: layout.children

    sourceComponent: isVertical ? columnComponent : rowComponent

    Component {
        id: rowComponent
        Row {
            id: layout
        }
    }

    Component {
        id: columnComponent
        Column {
            id: layout
        }
    }
}