import QtQuick.Controls.Material
import QtQuick

ScrollView {
    ScrollBar.vertical: defaultVerticalScrollBar
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    ScrollBar {
        id: defaultVerticalScrollBar
        enabled: parent.enabled
        opacity: parent.opacity
        orientation: Qt.Vertical
        anchors.right: parent.right
        anchors.rightMargin: -8
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        visible: policy === ScrollBar.AlwaysOn
        active: true
        width: interactive ? implicitWidth - 4 : implicitWidth
        interactive: Qt.platform.os !== "android"
        policy: (parent.contentHeight > parent.height) ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    }
}
