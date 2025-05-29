import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls.impl
import QtQuick.Layouts
import Odizinne.ActionPadClient

Page {
    id: root
    objectName: "actionPage"

    property var client
    signal navigateToSettings()
    signal openDrawer()
    Material.background: UserSettings.darkMode ? "#1C1C1C" : "#E3E3E3"

    header: ToolBar {
        Material.elevation: 6
        Material.background: UserSettings.darkMode ? "#2B2B2B" : "#FFFFFF"

        ToolButton {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            icon.source: "qrc:/icons/menu.svg"
            icon.width: 18
            icon.height: 18
            onClicked: root.openDrawer()
        }

        Label {
            text: "Actions"
            font.pixelSize: 18
            font.bold: true
            anchors.centerIn: parent
        }
    }

    Label {
        text: "Disconnected"
        visible: client.connectionStatus === "Disconnected"
        anchors.centerIn: parent
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Actions Grid
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            GridView {
                id: actionsGrid
                anchors.fill: parent
                cellWidth: 120
                cellHeight: 120
                model: client ? client.actionModel : null

                add: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 300
                    }
                    NumberAnimation {
                        property: "scale"
                        from: 0.8
                        to: 1.0
                        duration: 300
                    }
                }

                remove: Transition {
                    NumberAnimation {
                        property: "opacity"
                        to: 0
                        duration: 200
                    }
                    NumberAnimation {
                        property: "scale"
                        to: 0.8
                        duration: 200
                    }
                }

                delegate: Button {
                    width: actionsGrid.cellWidth - 10
                    height: actionsGrid.cellHeight - 10
                    Material.roundedScale: Material.SmallScale
                    onClicked: {
                        if (client && client.isConnected) {
                            client.pressAction(model.actionId)
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5

                        IconImage {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            source: model.icon
                            color: UserSettings.darkMode ? "white" : "white"
                            fillMode: Image.PreserveAspectFit
                        }

                        Label {
                            Layout.fillWidth: true
                            text: model.name
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }
}
