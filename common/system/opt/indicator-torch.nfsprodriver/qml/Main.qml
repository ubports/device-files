import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Indicator 1.0

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'indicator-torch'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    Page {
        header: PageHeader {
            id: header
            title: i18n.tr("Indicator Torch")
        }

        Flickable {
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            clip: true
            contentHeight: contentColumn.height + units.gu(4)

            ColumnLayout {
                id: contentColumn
                anchors {
                    left: parent.left
                    top: parent.top
                    right: parent.right
                    margins: units.gu(2)
                }
                spacing: units.gu(1)

                Button {
                    visible: !Indicator.isInstalled

                    text: i18n.tr("Install Indicator")
                    onClicked: {
                        message.visible = false;
                        Indicator.install();
                    }
                    color: UbuntuColors.green
                }

                Button {
                    visible: Indicator.isInstalled

                    text: i18n.tr("Uninstall Indicator")
                    onClicked: {
                        message.visible = false;
                        Indicator.uninstall();
                    }
                }

                Label {
                    id: message
                    visible: false
                }
            }
        }
    }

    Connections {
        target: Indicator

        onInstalled: {
            message.visible = true;
            if (success) {
                message.text = i18n.tr("Successfully installed, please reboot");
                message.color = UbuntuColors.green;
            }
            else {
                message.text = i18n.tr("Failed to install");
                message.color = UbuntuColors.red;
            }
        }

        onUninstalled: {
            message.visible = true;
            if (success) {
                message.text = i18n.tr("Successfully uninstalled, please reboot");
                message.color = UbuntuColors.green;
            }
            else {
                message.text = i18n.tr("Failed to uninstall");
                message.color = UbuntuColors.red;
            }
        }
    }
}
