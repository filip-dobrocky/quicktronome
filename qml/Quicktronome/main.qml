/*
 * Copyright (C) 2013 Filip Dobrocky <filip.dobrocky@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import QtQuick.LocalStorage 2.0
import QtQuick.Controls 1.1
import QtQuick.Window 2.0
import QtMultimedia 5.1


/*!
    A simple metronome
*/

ApplicationWindow {
    id: windowMain
    title: "Quicktronome"
    minimumWidth: 400
    minimumHeight: 300
    width: 400
    height: 300

    menuBar: MenuBar {
        Menu {
            title: "File"

            MenuItem {
                text: "About"
                onTriggered: {
                    windowAbout.visible = true
                }
            }
        }

        Menu {
            title: "View"

            MenuItem {
                text: "Flash"
                checkable: true
                checked: flashOn
                shortcut: "ctrl+f"
                onToggled: {
                    flashOn = checked
                }
            }
        }
    }

    // VARIABLES
    property int count: 1
    property double millis: 0
    property double lastMillis: 0
    property int i: 1
    property double taps: 0
    property double lastTap: 0
    property bool isZero
    property color shapeColor: "green"

    // SETTINGS
    property string timeSign //time signature string
    property int timeSignCount //number of clicks per beat
    property int timeSignIndex //index of the time signature OptionSelector
    property int accentSound //index of the accent OptionSelector
    property int clickSound //index of the click OptionSelector
    property int bpm: 1 //beats per minute
    property int accentOn //state of the switchAccent
    property int flashOn //animation on/off
    property double accentVolume //volume of the accent sound
    property double clickVolume //volume of the click sound

    // ABOUT
    property string version: "1.0"
    property string about: "<b>Quicktronome " + version + "</b><br><br>Quicktronome is a simple metronome app built in QtQuick. It is based on <i>uClick</i>, a metronome made using Ubuntu SDK.<br><br><b>Copyright (C) 2013 Filip Dobrocky &lt;filip.dobrocky@gmail.com&gt;</b>"
    property string license: "This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.\n\nThis program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.\n\nYou should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>."

    // DATABASE
    property var db: null

    function openDB() {
        if(db !== null) return;

        // db = LocalStorage.openDatabaseSync(identifier, version, description, estimated_size, callback(db))
        db = LocalStorage.openDatabaseSync("Quicktronome", "0.1", "Quicktronome settings", 100000);

        try {
            db.transaction(function(tx){
                tx.executeSql('CREATE TABLE IF NOT EXISTS settings(key TEXT UNIQUE, value TEXT)');
                var table  = tx.executeSql("SELECT * FROM settings");
                // seed the table with default values
                if (table.rows.length === 0) {
                    tx.executeSql('INSERT INTO settings VALUES(?, ?)', ["timeSign", "4/4"]);
                    tx.executeSql('INSERT INTO settings VALUES(?, ?)', ["timeSignCount", 4]);
                    tx.executeSql('INSERT INTO settings VALUES(?, ?)', ["timeSignIndex", 2]);
                    tx.executeSql('INSERT INTO settings VALUES(?, ?)', ["accentSound", 0]);
                    tx.executeSql('INSERT INTO settings VALUES(?, ?)', ["clickSound", 0]);
                    tx.executeSql('INSERT INTO settings VALUES(?, ?)', ["bpm", 120]);
                    tx.executeSql('INSERT INTO settings VALUES(?, ?)', ["accentOn", 1]);
                    tx.executeSql('INSERT INTO settings VALUES(?, ?)', ["flashOn", 1]);
                    tx.executeSql('INSERT INTO settings VALUES(?, ?)', ["width", 70]);
                    tx.executeSql('INSERT INTO settings VALUES(?, ?)', ["heigth", 60]);
                    tx.executeSql('INSERT INTO settings VALUES(?, ?)', ["accentVolume", 1]);
                    tx.executeSql('INSERT INTO settings VALUES(?, ?)', ["clickVolume", 0.8]);
                    console.log('Settings table added');
                };
            });
        } catch (err) {
            console.log("Error creating table in database: " + err);
        };
    }


    function saveSetting(key, value) {
        openDB();
        db.transaction( function(tx){
            tx.executeSql('INSERT OR REPLACE INTO settings VALUES(?, ?)', [key, value]);
        });
    }

    function getSetting(key) {
        openDB();
        var res = "";
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT value FROM settings WHERE key=?;', [key]);
            res = rs.rows.item(0).value;
        });
        return res;
    }

    // on startup
    Component.onCompleted: {
        timeSign = getSetting("timeSign")
        timeSignCount = getSetting("timeSignCount")
        timeSignIndex = getSetting("timeSignIndex")
        accentSound = getSetting("accentSound")
        clickSound = getSetting("clickSound")
        bpm = getSetting("bpm")
        accentOn = getSetting("accentOn")
        flashOn = getSetting("flashOn")
        width = getSetting("width")
        height = getSetting("height")
        accentVolume = getSetting("accentVolume")
        clickVolume = getSetting("clickVolume")
    }

    // on closed
    Component.onDestruction: {
        saveSetting("timeSign", timeSign)
        saveSetting("timeSignCount", timeSignCount)
        saveSetting("timeSignIndex", timeSignIndex)
        saveSetting("accentSound", accentSound)
        saveSetting("clickSound", clickSound)
        saveSetting("bpm", bpm)
        saveSetting("accentOn", accentOn)
        saveSetting("flashOn", flashOn)
        saveSetting("width", width)
        saveSetting("height", height)
        saveSetting("accentVolume", accentVolume)
        saveSetting("clickVolume", clickVolume)
    }

    // FUNCTIONS
    function playClick(sound) {
        switch (sound) {
        case 0:
            clickSine.play()
            break;
        case 1:
            clickPluck.play()
            break;
        case 2:
            clickBass.play()
            break;
        }
    }

    function playAccent(sound) {
        switch (sound) {
        case 0:
            accentSine.play()
            break;
        case 1:
            accentPluck.play()
            break;
        case 2:
            accentBass.play()
            break;
        }
    }

    function italian(tempo) {
        if (tempo < 40) return "Larghissimo"
        else if (tempo >= 40 && tempo < 60) return "Largo"
        else if (tempo >= 60 && tempo < 66) return "Larghetto"
        else if (tempo >= 66 && tempo < 76) return "Adagio"
        else if (tempo >= 76 && tempo < 108) return "Adante"
        else if (tempo >= 108 && tempo < 120) return "Modernato"
        else if (tempo >= 120 && tempo < 168) return "Allegro"
        else if (tempo >= 168 && tempo < 208) return "Presto"
        else if (tempo >= 208) return "Prestissimo"
    }

    function changeTimeSign(index, text, count) {
        timeSign = text
        timeSignIndex = index
        timeSignCount = count
    }


    SoundEffect {
        id: clickSine
        source: "qrc:/sounds/click_sine.wav"
        volume: clickVolume
    }

    SoundEffect {
        id: accentSine
        source: "qrc:/sounds/accent_sine.wav"
        volume: accentVolume
    }

    SoundEffect {
        id: clickPluck
        source: "qrc:/sounds/click_pluck.wav"
        volume: clickVolume
    }

    SoundEffect {
        id: accentPluck
        source: "qrc:/sounds/accent_pluck.wav"
        volume: accentVolume
    }

    SoundEffect {
        id: clickBass
        source: "qrc:/sounds/click_bass.wav"
        volume: clickVolume
    }

    SoundEffect {
        id: accentBass
        source: "qrc:/sounds/accent_bass.wav"
        volume: accentVolume
    }

    Timer {
        id: timer
        interval: 60000/bpm
        running: false
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            if (count == 1 && switchAccent.checked) {
                shapeColor = "green"
                playAccent(accentSound)
            } else {
                shapeColor = "red"
                playClick(clickSound)
            }

            if (flashOn) flash.start()
            else shape.color = shapeColor

            label.text = count
            count++
            if (count > timeSignCount) count = 1
        }
    }

    ApplicationWindow {
        id: windowAbout
        title: "About"
        visible: false
        minimumWidth: 280
        minimumHeight: 200

        Column {
            id: columnAbout
            spacing: 5
            anchors {
                fill: parent
                margins: 5
            }

            ScrollView {
                width: parent.width
                height: parent.height-buttonAbout.height-5

                Flickable {
                    id: flickableAbout
                    width: parent.width
                    height: parent.height-buttonAbout.height-5
                    contentHeight: labelAbout.height
                    flickableDirection: Flickable.VerticalFlick
                    clip: true

                    Label {
                        id: labelAbout
                        width: flickableAbout.width-5
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                        text: about
                    }
                }
            }



            Button {
                id: buttonAbout
                width: parent.width
                text: "License"

                onClicked: {
                    if (text == "License") {
                        text = "About"
                        labelAbout.text = license
                        labelAbout.horizontalAlignment = Text.AlignLeft
                    } else {
                        text = "License"
                        labelAbout.text = about
                        labelAbout.horizontalAlignment = Text.AlignHCenter
                    }
                }
            }
        }
    }

    ApplicationWindow {
        id: windowBar
        title: "Bar"
        visible: false
        minimumWidth: 280
        minimumHeight: 240

        Row {
            spacing: 5
            anchors {
                fill: parent
                margins: 5
            }

            GroupBox {
                width: (parent.width-5)/2
                height: parent.height
                title: "Time Signature"

                Column {
                    anchors.fill: parent
                    spacing: 5

                    ExclusiveGroup { id: groupBar }

                    RadioButton {
                        text: "2/4"
                        exclusiveGroup: groupBar
                        checked: (timeSignIndex == 0) ? true : false

                        onCheckedChanged: if (checked) changeTimeSign(0, text, 2)
                    }

                    RadioButton {
                        text: "3/4"
                        exclusiveGroup: groupBar
                        checked: (timeSignIndex == 1) ? true : false

                        onCheckedChanged: if (checked) changeTimeSign(1, text, 3)
                    }

                    RadioButton {
                        text: "4/4"
                        exclusiveGroup: groupBar
                        checked: (timeSignIndex == 2) ? true : false

                        onCheckedChanged: if (checked) changeTimeSign(2, text, 4)
                    }

                    RadioButton {
                        text: "5/4"
                        exclusiveGroup: groupBar
                        checked: (timeSignIndex == 3) ? true : false

                        onCheckedChanged: if (checked) changeTimeSign(3, text, 5)
                    }

                    RadioButton {
                        text: "6/8"
                        exclusiveGroup: groupBar
                        checked: (timeSignIndex == 4) ? true : false

                        onCheckedChanged: if (checked) changeTimeSign(4, text, 6)
                    }

                    RadioButton {
                        text: "7/8"
                        exclusiveGroup: groupBar
                        checked: (timeSignIndex == 5) ? true : false

                        onCheckedChanged: if (checked) changeTimeSign(5, text, 7)
                    }

                    RadioButton {
                        id: radioButtonCustom
                        text: "Custom"
                        exclusiveGroup: groupBar
                        checked: (timeSignIndex == 6) ? true : false

                        onCheckedChanged: {
                            if (checked) timeSignIndex = 6
                            textFieldCustom.enabled = checked
                        }
                    }
                }
            }

            Column {
                width: (parent.width-5)/2
                spacing: 5

                Label {
                    text: "Custom (1-99):"
                }

                SpinBox {
                    id: textFieldCustom
                    width: parent.width
                    enabled: radioButtonCustom.checked
                    minimumValue: 1
                    maximumValue: 99
                    value: timeSignCount

                    onValueChanged: {
                        if (timeSignIndex == 6) {
                            timeSignCount = value
                            timeSign = (timeSignCount == 1) ? timeSignCount + " click"
                                                            : timeSignCount + " clicks"
                        }
                    }
                    onEnabledChanged: {
                        if (enabled) {
                            timeSignCount = value
                            timeSign = (timeSignCount == 1) ? timeSignCount + " click"
                                                            : timeSignCount + " clicks"
                        }
                    }
                }
            }
        }
    }

    Window {
        id: windowSound
        title: "Sound"
        minimumWidth: 200
        minimumHeight: 180

        Row {
            spacing: 5
            anchors {
                fill: parent
                margins: 5
            }

            Column {
                width: (parent.width-5)/2
                height: parent.height
                spacing: 5

                GroupBox {
                    title: "Click"

                    Column {
                        anchors.fill: parent
                        spacing: 5

                        ExclusiveGroup { id: groupClick }

                        RadioButton {
                            text: "Sine"
                            exclusiveGroup: groupClick
                            checked: (clickSound == 0) ? true : false

                            onCheckedChanged: if (checked) clickSound = 0
                        }

                        RadioButton {
                            text: "Pluck"
                            exclusiveGroup: groupClick
                            checked: (clickSound == 1) ? true : false

                            onCheckedChanged: if (checked) clickSound = 1
                        }

                        RadioButton {
                            text: "Bass"
                            exclusiveGroup: groupClick
                            checked: (clickSound == 2) ? true : false

                            onCheckedChanged: if (checked) clickSound = 2
                        }
                    }
                }

                GroupBox {
                    title: "Volume"
                    width: parent.width

                    SpinBox {
                        width: parent.width
                        minimumValue: 0
                        maximumValue: 1
                        decimals: 1
                        stepSize: 0.1
                        value: clickVolume

                        onValueChanged: clickVolume = value
                    }
                }
            }

            Column {
                width: (parent.width-5)/2
                height: parent.height
                spacing: 5

                GroupBox {
                    title: "Accent"

                    Column {
                        anchors.fill: parent
                        spacing: 5

                        ExclusiveGroup { id: groupAccent }

                        RadioButton {
                            text: "Sine"
                            exclusiveGroup: groupAccent
                            checked: (accentSound == 0) ? true : false

                            onCheckedChanged: if (checked) accentSound = 0
                        }

                        RadioButton {
                            text: "Pluck"
                            exclusiveGroup: groupAccent
                            checked: (accentSound == 1) ? true : false

                            onCheckedChanged: if (checked) accentSound = 1
                        }

                        RadioButton {
                            text: "Bass"
                            exclusiveGroup: groupAccent
                            checked: (accentSound == 2) ? true : false

                            onCheckedChanged: if (checked) accentSound = 2
                        }
                    }
                }

                GroupBox {
                    title: "Volume"
                    width: parent.width

                    SpinBox {
                        width: parent.width
                        minimumValue: 0
                        maximumValue: 1
                        decimals: 1
                        stepSize: 0.1
                        value: accentVolume

                        onValueChanged: accentVolume = value
                    }
                }
            }
        }
    }



    Column {
        id: column1
        spacing: 5
        anchors {
            margins: 5
            fill: parent
        }

        Rectangle {
            id: shape
            color: "#303030"
            radius: 6
            border.color: shapeColor
            border.width: 1
            width: parent.width
            // use all the free height
            height: parent.height-row1.height-row2.height-rowTempo.height-slider.height-buttonStart.height-25

            Label {
                id: label
                anchors.centerIn: parent
                color: "white"
                font.bold: true
                text: "1"
                font.pointSize: 36
            }

            SequentialAnimation on color {
                id: flash
                running: false

                ColorAnimation { from: "#303030"; to: shapeColor; duration: 0 }
                ColorAnimation { from: shapeColor; to: "#303030"; duration: 60000/bpm*0.6 }

            }

        }

        Row {
            id: row1
            spacing: 5
            width: parent.width

            Button {
                id: buttonTap
                width: 2*(parent.width-5)/3
                action: actionTap
            }

            Action {
                id: actionTap
                text: "Tap"
                shortcut: "t"
                tooltip: "Tap tempo\nShortcut: T"

                onTriggered: {
                    /* on each tap, it calculates the average of all of the taps,
                    if the difference is bigger than 25 BPM, it resets the tempo */

                    var date = new Date()

                    if (lastTap != 0) {
                        millis = date.getTime() - lastTap
                        lastTap = date.getTime()

                        // if the difference between taps is greater than 25 BPM, reset
                        if (lastMillis != 0 && Math.abs(60000/(lastMillis-millis)) > 25) {
                            i = 1
                            taps = lastTap = millis = lastMillis = 0
                            return
                        }

                        lastMillis = millis

                        taps += (60000/millis)

                        // set tempo to the average of the taps
                        slider.value = (taps/i > 300) ? 300 : taps/i
                        i++
                    } else {
                        lastTap = date.getTime()
                    }
                }
            }

            Button {
                id: buttonTimeSign
                width: (parent.width-5)/3
                text: timeSign
                tooltip: "Change the time signature"

                onClicked: windowBar.visible = true
            }
        }

        Row {
            id: row2
            spacing: 5
            width: parent.width

            CheckBox {
                id: switchAccent
                width: 2*(parent.width-5)/3
                text: "Accent"
                checked: accentOn

                onCheckedChanged: accentOn = checked
            }

            Button {
                id: buttonSound
                width: (parent.width-5)/3
                text: "Sound"
                tooltip: "Change sounds and volumes"
                onClicked: windowSound.visible = true
            }
        }

        Row {
            id: rowTempo
            width: parent.width
            spacing: 5

            Label {
                id: labelTempo
                width: parent.width-rowPlusMinus.width-5
                anchors.verticalCenter: parent.verticalCenter
                text: "Tempo: " + slider.value.toFixed() + " BPM (" + italian(slider.value.toFixed()) + ")"
            }

            Row {
                id: rowPlusMinus
                spacing: 5

                Action {
                    id: actionMinus
                    text: "-"
                    shortcut: "q"
                    tooltip: "Tempo - 1\nShortcut: Q"

                    onTriggered: slider.value--
                }

                Action {
                    id: actionPlus
                    text: "+"
                    shortcut: "w"
                    tooltip: "Tempo + 1\nShortcut: W"

                    onTriggered: slider.value++
                }

                Button {
                    width: height
                    action: actionMinus
                }

                Button {
                    width: height
                    action: actionPlus
                }
            }
        }

        Slider {
            id: slider
            width: parent.width
            minimumValue: 30
            maximumValue: 300
            value: bpm

            onValueChanged: windowMain.bpm = value
        }

        Button {
            id: buttonStart
            width: parent.width
            action: actionStart

            Component.onCompleted: {
                height *= 1.2
            }
        }

        Action {
            id: actionStart
            text: "Start"
            shortcut: "space"
            tooltip: "Start/stop the metronome\nShortcut: Space"

            onTriggered: {
                bpm = slider.value
                if (timer.running) {
                    text = "Start"
                    timer.stop()
                    count = 1
                } else {
                    text = "Stop"
                    timer.start()
                }
            }
        }
    }
}
