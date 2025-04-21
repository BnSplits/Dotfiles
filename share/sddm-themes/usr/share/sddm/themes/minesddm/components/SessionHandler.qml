// This is a huge workarround to just to get the name of the sessions
// For some reason sessionMovel.get is not working so I came up with this:
// This will create a hiden and not interactable ListView just to get and store the values of session model in a list for later use

import QtQml.Models 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

ListView {
    model: sessionModel
    enabled: false
    visible: false

    delegate: Item {
        Component.onCompleted: {
            root.sessions.push({
                "name": model.name,
                "comment": model.comment
            });
            // For some reason I need to update the root.sessionIndex for the values on the root.session to update and appear where they are used
            root.sessionIndex = (root.sessionIndex + 1) % sessionModel.count;
            root.sessionIndex = sessionModel.lastIndex;
        }
    }

}
