import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.qmlmodels

Dialog {
    id: guideDialog
    title: "快捷键指南"
    modal: true

    width: 420
    height: 520
    standardButtons: Dialog.Close

    anchors.centerIn: Overlay.overlay

    readonly property int rowHeight: 44
    readonly property int headerHeight: 36
    readonly property int leftColWidth: 150
    readonly property int tableMaxWidth: 380
    readonly property int tableMaxHeight: 360

    background: Rectangle {
        color: "#ffffff"
        radius: 12
        border.color: "#e5e5e5"
        border.width: 1
    }

    contentItem: Item {
        anchors.fill: parent
        anchors.margins: 16

        /* ===== 使用 Column 填充父级 ===== */
        Column {
            anchors.fill: parent
            anchors.top: parent.top
            spacing: 0
            width: Math.min(parent.width, tableMaxWidth)

            /* ===== Header ===== */
            Row {
                id: headerRow
                width: parent.width
                height: headerHeight

                Rectangle {
                    width: leftColWidth
                    height: parent.height
                    color: "#f6f6f6"

                    Text {
                        anchors.centerIn: parent
                        text: "快捷键"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#555555"
                    }
                }

                Rectangle {
                    width: parent.width - leftColWidth
                    height: parent.height
                    color: "#f6f6f6"

                    Text {
                        anchors.centerIn: parent
                        text: "功能说明"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#555555"
                    }
                }
            }

            /* ===== TableView ===== */
            TableView {
                id: tableView
                width: parent.width
                anchors.bottom: parent.bottom
                height: Math.min(parent.height - headerHeight, tableMaxHeight)
                clip: true

                model: TableModel {
                    TableModelColumn { display: "key" }
                    TableModelColumn { display: "desc" }

                    rows: [
                        { key: "Ctrl + N",         desc: "新建命令" },
                        { key: "Ctrl + Shift + N", desc: "新建分组" },
                        { key: "Ctrl + F",         desc: "搜索命令" },
                        { key: "Ctrl + B",         desc: "显示 / 隐藏侧边栏" },
                        { key: "Ctrl + I",         desc: "导入数据" },
                        { key: "Ctrl + E",         desc: "导出数据" },
                        { key: "F5",               desc: "刷新列表" },
                        { key: "Ctrl + Q",         desc: "退出程序" }
                    ]
                }

                rowHeightProvider: function() { return guideDialog.rowHeight }

                columnWidthProvider: function(column) {
                    return column === 0 ? guideDialog.leftColWidth
                                        : tableView.width - guideDialog.leftColWidth
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                delegate: Rectangle {
                    implicitHeight: guideDialog.rowHeight
                    color: row % 2 ? "#fafafa" : "#ffffff"

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: "#eeeeee"
                    }

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                        maximumLineCount: column === 0 ? 1 : 2
                        elide: Text.ElideRight

                        font.pixelSize: 13
                        color: "#222222"
                        text: display
                    }
                }
            }
        }
    }
}
