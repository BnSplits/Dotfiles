import QtQuick 2.15
import QtQuick.Controls 2.15

TextField {
    width: config.inputWidth
    height: config.itemHeight
    color: config.lightText
    placeholderText: config.usernamePlaceholder
    placeholderTextColor: config.darkText

    font {
        family: minecraftFont.name
        pixelSize: config.fontPixelSize
    }
    leftPadding: config.inputLeftPadding

    background: TextFieldBackground {
    }

}
