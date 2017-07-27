using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class TidyWatchApp extends App.AppBase {

    var data = new TidyData();

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        var view = new TidyWatchView();
        view.setData(data);
        if (Ui has :WatchFaceDelegate) {
            return [ view, new TWDelegate() ];
        } else {
            return [ view ];
        }
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() {
        view.clear();
        Ui.requestUpdate();
    }
}