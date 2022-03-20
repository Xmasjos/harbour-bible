import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    /*
    Label {
        id: label
        anchors.centerIn: parent
        text: qsTr("Bible")
    }
    */
    Image {
        id: name
        anchors.centerIn: parent
        source: "harbour-bible.png"
        width: Theme.iconSizeLarge
        height: Theme.iconSizeLarge
        sourceSize.width: width
        sourceSize.height: height
        fillMode: Image.PreserveAspectFit
    }
    /*
    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-pause"
        }
    }
    */
}
