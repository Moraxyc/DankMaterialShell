// Orientation utility functions for DankBar vertical support

function getWidgetSize(baseWidth, baseHeight, isVertical) {
    return isVertical ?
        { width: baseHeight, height: baseWidth } :
        { width: baseWidth, height: baseHeight }
}

function getAnchorProperty(isVertical, horizontal, vertical) {
    return isVertical ? vertical : horizontal
}

function getSpacingDirection(isVertical) {
    return isVertical ? "vertical" : "horizontal"
}

function getPrimaryDimension(item, isVertical) {
    return isVertical ? item.height : item.width
}

function getSecondaryDimension(item, isVertical) {
    return isVertical ? item.width : item.height
}

function setPrimaryDimension(item, value, isVertical) {
    if (isVertical) {
        item.height = value
    } else {
        item.width = value
    }
}

function setSecondaryDimension(item, value, isVertical) {
    if (isVertical) {
        item.width = value
    } else {
        item.height = value
    }
}

function getLayoutDirection(isVertical) {
    return isVertical ? Qt.Vertical : Qt.Horizontal
}

function getCenterAnchor(anchors, isVertical) {
    return isVertical ? anchors.horizontalCenter : anchors.verticalCenter
}

function getCrossAxisCenterAnchor(anchors, isVertical) {
    return isVertical ? anchors.verticalCenter : anchors.horizontalCenter
}