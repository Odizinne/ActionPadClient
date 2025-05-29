import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import Odizinne.ActionPadClient

Page {
    id: root

    property var client
    signal navigateBack()

    header: ToolBar {
        ToolButton {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            icon.source: "qrc:/icons/back.svg"
            icon.width: 18
            icon.height: 18
            onClicked: root.navigateBack()
        }

        Label {
            text: "Settings"
            font.pixelSize: 18
            font.bold: true
            anchors.centerIn: parent
        }
    }

    ScrollingArea {
        id: scrollArea
        anchors.fill: parent
        contentWidth: width
        contentHeight: textContainer.height + 20

        Item {
            id: textContainer
            width: scrollArea.width
            height: mainLyt.height + 20
            anchors.top: parent.top
            anchors.topMargin: 10

            ColumnLayout {
                id: mainLyt
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                anchors.top: parent.top
                anchors.topMargin: 10
                spacing: 15

                // Server IP
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Label {
                        text: "Server IP Address"
                        font.bold: true
                    }

                    TextField {
                        id: serverAddressField
                        Layout.fillWidth: true
                        text: UserSettings.savedIP
                        placeholderText: "192.168.1.100"
                        onTextChanged: {
                            if (client) client.serverAddress = text
                            UserSettings.savedIP = text
                        }
                    }
                }

                // Server Port
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Label {
                        text: "Server Port"
                        font.bold: true
                    }

                    TextField {
                        id: serverPortField
                        Layout.fillWidth: true
                        text: UserSettings.savedPort
                        placeholderText: "8080"
                        validator: IntValidator { bottom: 1; top: 65535 }
                        onTextChanged: {
                            if (text.length > 0 && client) {
                                client.serverPort = parseInt(text)
                                UserSettings.savedPort = text
                            }
                        }
                    }
                }

                // Connection Status
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#f8f8f8"
                    border.color: "#ddd"
                    border.width: 1
                    radius: 6

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10

                        Label {
                            text: "Connection Status"
                            font.bold: true
                            color: "#666"
                        }

                        Label {
                            text: client ? client.connectionStatus : "Disconnected"
                            color: client && client.isConnected ? "green" : "red"
                            font.pixelSize: 14
                        }
                    }
                }

                // Connection Controls
                RowLayout {
                    Layout.fillWidth: true

                    Button {
                        text: client && client.isConnected ? "Disconnect" : "Connect"
                        Layout.fillWidth: true

                        onClicked: {
                            if (client) {
                                if (client.isConnected) {
                                    client.disconnectFromServer()
                                } else {
                                    client.connectToServer()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
