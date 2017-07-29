using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class TidyWatchApp extends App.AppBase {

    var data = new TidyData();
    var view = null;

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
        view = new TidyWatchView();
        view.setData(data);
        return [ view ];
    }

    function onSettingsChanged() {
        if ( view != null ){ view.clear(); }
        Ui.requestUpdate();
    }
}