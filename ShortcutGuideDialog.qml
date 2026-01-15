import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts

Dialog {
    id: guideDialog
    //anchors.centerIn: parent
    x: parent.width / 2 - width / 2
    y: (parent.height / 2 - height / 2) - 50
    
    title: "快捷键指南"
    modal: true
    width: 400
    height: 500
    standardButtons: Dialog.Close

    // 定义一个快捷键数据模型
    property list<variant> shortcuts: [
        { key: "Ctrl + N", desc: "新建命令" },
        { key: "Ctrl + Shift + N", desc: "新建分组" },
        { key: "Ctrl + F", desc: "搜索命令" },
        { key: "Ctrl + B", desc: "显示/隐藏侧边栏" },
        { key: "Ctrl + I", desc: "导入数据" },
        { key: "Ctrl + E", desc: "导出数据" },
        { key: "F5", desc: "刷新列表" },
        { key: "Ctrl + Q", desc: "退出程序" }
    ]


    background: Rectangle {
        color: "#ffffff"
        radius: 12
        border.color: "#e5e5e5"
        border.width: 1
    }

    contentItem: TableView {
        id: tableView
        anchors.fill: parent
        anchors.margins: 16
        clip: true
        
        model: guideDialog.shortcuts

        // 定义列

        // 定义委托
        delegate: Row {
            spacing: 10
            height: 40
            Rectangle {
                width: tableView.columns[0].width
                height: parent.height
                color: "transparent"
                Text {
                    anchors.centerIn: parent
                    text: model.key
                    font.pixelSize: 13
                    color: "#0a0a0a"
                }
            }
            Rectangle {
                width: tableView.columns[1].width
                height: parent.height
                color: "transparent"
                Text {
                    anchors.centerIn: parent
                    text: model.desc
                    font.pixelSize: 13
                    color: "#0a0a0a"
                }
            }
        }
    }
}