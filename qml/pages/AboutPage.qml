import QtQuick 2.6
import Sailfish.Silica 1.0


Page {
    id: page
    allowedOrientations: Orientation.Portrait //All

    SilicaFlickable {
        id: listView
        anchors.fill: parent
        contentHeight: idColumn.height  // Tell SilicaFlickable the height of its content.

        VerticalScrollDecorator {}

        Column {
            id: idColumn
            x: Theme.paddingLarge
            width: parent.width - 2*x

            Label {
                width: parent.width
                height: Theme.itemSizeLarge
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.primaryColor
                text: qsTr("Bible")
            }
            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Image {
                width: parent.width
                height: Theme.itemSizeHuge
                source: "../cover/harbour-bible.png"
                sourceSize.width: height
                sourceSize.height: height
                fillMode: Image.PreserveAspectFit
            }
            Item {
                width: parent.width
                height: Theme.paddingLarge * 2.5
            }

            Label {
                x: Theme.paddingMedium
                width: parent.width - 2*x
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                text: qsTr("Bible is a simple parser for Bibles stored in ZefaniaXML. These are available for free in multiple translations here:")

            }
            Label {
                x: Theme.paddingMedium + Theme.paddingLarge
                width: parent.width - 2*x
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                text: "\n" + "https://sourceforge.net/projects/zefania-sharp/files/Bibles/" + "\n"
                color: Theme.highlightColor

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Qt.openUrlExternally("https://sourceforge.net/projects/zefania-sharp/files/Bibles/")
                    }
                }
            }
            Label {
                x: Theme.paddingMedium
                width: parent.width - 2*x
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                text: qsTr("After downloading unpack and link to the XML file in Settings. ")
                    + qsTr("Thanksgiving, feedback and support is always welcome. ")
            }
            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                wrapMode: Text.Wrap
                text: "\n" + qsTr("Copyright © 2022 Tobias Planitzer")
                + "\n" + qsTr("tp.labs@protonmail.com")
                + "\n" + qsTr("License: GPL v3")
            }
            Item {
                width: parent.width
                height: Theme.paddingLarge * 2.5
            }
        }

    } // end Silica Flickable
}
