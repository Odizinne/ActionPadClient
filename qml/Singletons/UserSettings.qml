pragma Singleton
import QtCore

Settings {
    id: settings
    property string savedIP: ""
    property string savedPort: ""
    property bool darkMode: true
}
