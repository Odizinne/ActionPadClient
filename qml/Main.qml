import QtQuick
import QtQuick.Controls.Material
import Odizinne.ActionPadClient 1.0

ApplicationWindow {
    id: window
    width: 360
    height: 640
    visible: true
    title: qsTr("Action Pad")
    color: UserSettings.darkMode ? "#1C1C1C" : "#E3E3E3"
    Material.theme: UserSettings.darkMode ? Material.Dark : Material.Light

    property bool backPressedOnce: false

    onClosing: function(close) {
        if (Qt.platform.os === "android") {
            if (stackView.depth > 1) {
                close.accepted = false
                stackView.pop()
                return
            }

            if (!backPressedOnce) {
                close.accepted = false
                backPressedOnce = true
                exitTooltip.show()
                exitTimer.start()
                return
            }

            close.accepted = true
        }
    }

    Timer {
        id: exitTimer
        interval: 2000
        onTriggered: {
            window.backPressedOnce = false
            exitTooltip.hide()
        }
    }

    ToolTip {
        id: exitTooltip
        text: qsTr("Press back again to exit")
        timeout: 2000
        x: (parent.width - width) / 2
        y: parent.height - height - 60
        font.pixelSize: 16
        Material.roundedScale: Material.SmallScale

        function show() {
            visible = true
        }

        function hide() {
            visible = false
        }
    }

    ActionPadClient {
        id: client
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: actionPage
    }

    ActionsPage {
        id: actionPage
        visible: false
        client: client

        onNavigateToSettings: stackView.push(settingsPage)
        onOpenDrawer: drawer.open()
    }

    SettingsPage {
        id: settingsPage
        visible: false
        client: client

        onNavigateBack: stackView.pop()
    }

    Drawer {
        id: drawer
        width: window.width * 0.66
        height: window.height
        Material.roundedScale: Material.NotRounded

        Column {
            anchors.fill: parent
            //anchors.margins: 20
            //spacing: 20

            ItemDelegate {
                width: parent.width
                text: "Settings"
                icon.source: "qrc:/icons/settings.svg"
                onClicked: {
                    drawer.close()
                    stackView.push(settingsPage)
                }
            }
        }
    }

    property alias appDrawer: drawer
}
