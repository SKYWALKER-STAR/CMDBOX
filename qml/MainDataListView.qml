import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import CommandManager 1.0

ListView {
    id: listView
    Layout.fillWidth: true
    Layout.fillHeight: true
    model: buildMainModel()
    clip: true
    spacing: 2  // 减小间距，让 folder 紧密排列
    signal addFolderRequested()
    signal addCommandRequested()
    
    property string selectedGroup: "All"
    
    // 引用外部组件
    property var commandDialog: null
    property var copyNotification: null
    property var previewWin: null
    
    onSelectedGroupChanged: {
        listView.model = buildMainModel()
    }
    
    Connections {
        target: CommandManager
        function onCommandsChanged() {
            listView.model = buildMainModel()
        }
        function onGroupsChanged() {
            listView.model = buildMainModel()
        }
    }
    
    function buildMainModel() {
        if (selectedGroup === "All" || selectedGroup === "" || !CommandManager) {
            return []
        }
        
        var result = []
        
        // 添加folder条目
        result.push({
            isFolder: true,
            title: selectedGroup,
            commandContent: "", // folder没有命令内容
            description: "",
            group: selectedGroup,
            sourceIndex: -1
        })
        
        // 添加该folder下的所有命令
        var commands = CommandManager.commandsInFolder(selectedGroup)
        for (var i = 0; i < commands.length; i++) {
            result.push(commands[i])
        }
        
        return result
    }
    
    onAddFolderRequested: {
        if (commandDialog && typeof commandDialog.openForAddFolder === 'function') {
            commandDialog.openForAddFolder()
        } else {
            console.log("Add folder requested but commandDialog unavailable")
        }
    }
    onAddCommandRequested: {
        if (commandDialog && typeof commandDialog.openForAdd === 'function') {
            commandDialog.openForAdd()
        } else {
            console.log("Add command requested but commandDialog unavailable")
        }
    }
    
    delegate: ItemDelegate {
        required property bool isFolder
        required property string title
        required property string commandContent
        required property string description
        required property string group
        required property int sourceIndex
        
        width: listView.width
        // 动态计算高度
        height: isFolder ? folderColumn.implicitHeight + 22 : commandColumn.implicitHeight + 22

        onClicked: {
            if (isFolder) return
            if (!CommandManager) return
            CommandManager.copyToClipboard(commandContent)
            if (copyNotification) {
                copyNotification.text = "已复制: " + title
                copyNotification.open()
            }
        }

        background: Rectangle {
            color: cardColor
            // 移除 folder 的悬停效果，保持固定边框
            border.color: subtleBorder
            border.width: 1
            radius: 6 // Sharper corners
        }

        ColumnLayout {
            id: folderColumn
            anchors.fill: parent
            anchors.margins: 12
            visible: isFolder
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                visible: isFolder
                spacing: 10

                Label {
                    text: title
                    font.bold: true
                    font.pixelSize: 15
                    Layout.fillWidth: true
                    color: textPrimary
                }
            }
        }

        // Command delegate
        ColumnLayout {
            id: commandColumn
            anchors.fill: parent
            anchors.margins: 12
            visible: !isFolder
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: title
                    font.bold: true
                    Layout.fillWidth: true
                    color: textPrimary
                }
                CButton {
                    text: "复制"
                    theme: "primary"
                    onClicked: {
                        if (CommandManager) {
                            CommandManager.copyToClipboard(commandContent)
                            if (copyNotification) {
                                copyNotification.text = "已复制: " + title
                                copyNotification.open()
                            }
                        }
                    }
                }
                CButton {
                    text: "修改"
                    theme: "warning"
                    onClicked: {
                        if (commandDialog) commandDialog.openForEdit(sourceIndex, title, commandContent, description, group, false)
                    }
                }
                CButton {
                    text: "删除"
                    theme: "danger"
                    onClicked: {
                        if (CommandManager) CommandManager.removeCommand(sourceIndex)
                    }
                }

                CButton {
                    text: "</>"
                    theme: "success"
                    implicitWidth: 40
                    onClicked: previewWin.openWith(title,commandContent)
                }
            }
            Rectangle {
                Layout.fillWidth: true
                height: 44
                color: "#f7fafc"
                radius: 6
                border.color: "#eef2f5"

                Text {
                    anchors.fill: parent
                    anchors.margins: 8
                    text: commandContent
                    font.family: "Courier New"
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    color: textPrimary
                }
            }

            Label {
                text: description
                color: textSecondary
                font.pixelSize: 12
                visible: description !== ""
            }
        }
    }
}  // 关闭 ListView