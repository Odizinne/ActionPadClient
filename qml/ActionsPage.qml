import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts

Page {
    id: root
    objectName: "actionPage"

    property var client
    signal navigateToSettings()

    function updateStatus(text, color) {
        statusLabel.text = text
        statusLabel.color = color
    }

    function showUpdateIndicator() {
        updateIndicator.opacity = 1.0
        updateFadeOut.start()
    }

    header: ToolBar {
        ToolButton {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            icon.source: "qrc:/icons/menu.svg"
            icon.width: 18
            icon.height: 18
            onClicked: window.appDrawer.open()
        }

        Label {
            text: "Actions"
            font.pixelSize: 18
            font.bold: true
            anchors.centerIn: parent
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Status Bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "#f5f5f5"
            border.color: "#ddd"
            border.width: 1
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10

                Label {
                    id: statusLabel
                    text: client ? client.connectionStatus : "Disconnected"
                    color: client && client.isConnected ? "green" : "red"
                    Layout.fillWidth: true
                }

                Rectangle {
                    id: updateIndicator
                    width: 12
                    height: 12
                    radius: 6
                    color: "lightblue"
                    opacity: 0

                    NumberAnimation {
                        id: updateFadeOut
                        target: updateIndicator
                        property: "opacity"
                        from: 1.0
                        to: 0
                        duration: 1000
                    }
                }
            }
        }

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

                delegate: Rectangle {
                    width: actionsGrid.cellWidth - 10
                    height: actionsGrid.cellHeight - 10
                    radius: 8
                    color: mouseArea.pressed ? "#e0e0e0" : "#f5f5f5"
                    border.color: "#ddd"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5

                        Image {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            source: model.icon
                            fillMode: Image.PreserveAspectFit

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: "#ddd"
                                border.width: 1
                                visible: parent.status === Image.Error

                                Text {
                                    anchors.centerIn: parent
                                    text: "?"
                                    color: "#999"
                                    font.pixelSize: 24
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: model.name
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            font.pixelSize: 12
                            color: "#333"
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onClicked: {
                            if (client && client.isConnected) {
                                client.pressAction(model.actionId)

                                feedbackRect.opacity = 0.5
                                feedbackAnimation.start()
                            }
                        }
                    }

                    Rectangle {
                        id: feedbackRect
                        anchors.fill: parent
                        radius: parent.radius
                        color: "lightblue"
                        opacity: 0

                        NumberAnimation {
                            id: feedbackAnimation
                            target: feedbackRect
                            property: "opacity"
                            from: 0.5
                            to: 0
                            duration: 200
                        }
                    }
                }
            }
        }
    }
}
