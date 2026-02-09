import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import CommandManager 1.0

Popup {
    id: copyNotification
    property string statusText: "已复制"
    property string commandName: ""
    property int notificationDuration: 2000
    property real progress: 1.0
    property int margin: 20

    width: Math.max(240, Math.max(statusLine.implicitWidth, commandLine.implicitWidth) + 32)
    height: textColumn.implicitHeight + 20
    x: 0
    y: 0
    closePolicy: Popup.NoAutoClose
    
    Timer {
        id: notificationTimer
        interval: notificationDuration
        onTriggered: copyNotification.close()
    }

    NumberAnimation {
        id: progressAnim
        target: copyNotification
        property: "progress"
        from: 1.0
        to: 0.0
        duration: notificationDuration
        easing.type: Easing.Linear
    }

    SequentialAnimation {
        id: slideInAnim
        NumberAnimation {
            target: copyNotification
            property: "x"
            to: Math.max(0, (parent ? parent.width : 0) - copyNotification.width - copyNotification.margin)
            duration: 260
            easing.type: Easing.OutBack
        }
        NumberAnimation {
            target: copyNotification
            property: "scale"
            from: 0.98
            to: 1.0
            duration: 120
            easing.type: Easing.OutQuad
        }
    }
    
    function open() {
        if (parent) {
            x = parent.width + 16
            y = parent.height - height - margin
        }
        scale = 1.0
        progress = 1.0
        visible = true
        slideInAnim.restart()
        progressAnim.restart()
        notificationTimer.restart()
    }

    function showCopied(name) {
        statusText = "已复制"
        commandName = name || ""
        open()
    }

    background: Rectangle {
        color: "#c9f7d1"
        radius: 8
        border.color: "#8fe3a0"
        border.width: 1
        opacity: 0.98
    }

    contentItem: ColumnLayout {
        id: textColumn
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6

        Text {
            id: statusLine
            text: statusText
            color: "#115d2e"
            font.pixelSize: 13
            font.bold: true
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        Text {
            id: commandLine
            text: commandName
            color: "#145c2f"
            font.pixelSize: 12
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        Rectangle {
            id: progressTrack
            Layout.fillWidth: true
            height: 4
            radius: 2
            color: "#b1efc1"

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Math.max(0, parent.width * copyNotification.progress)
                radius: 2
                color: "#4cc46a"
            }
        }
    }
}