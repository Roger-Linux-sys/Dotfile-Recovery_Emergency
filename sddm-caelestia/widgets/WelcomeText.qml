import QtQuick

Item {
    id: topLeftRect

    Text {
        renderType: Text.NativeRendering
        width: 370
        text: "<span style='color:" + config.text + ";'>I use ARCH btw </span>" +
              "<img src='file:///usr/share/sddm/themes/caelestia/assets/lightbulb.png' width='28' height='28'>"
        textFormat: Text.RichText
        wrapMode: Text.WordWrap
        anchors.centerIn: parent
        font.family: "Rubik"
        font.bold: false
        font.pixelSize: 36
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
