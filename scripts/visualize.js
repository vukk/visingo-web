
(function(document) {
    'use strict';

    var app = document.querySelector('#app');

    /* Defaults for bindings */

    // Listen for template bound event to know when bindings
    // have resolved and content has been stamped to the page
    app.addEventListener('dom-change', function() {
      console.log('visualize.js dom-change, stamped');
    });

    // See https://github.com/Polymer/polymer/issues/1381
    window.addEventListener('WebComponentsReady', function() {
      console.log('visualize.js WebComponentsReady');
      // routes are also in WebComponentsReady, Firefox seems to care about this (NOTE: routes removed)
      // load parameters from url ?foo=bar
      app.params = app.params || {};
      var url = Qurl.create();
      app.params.visualizer = url.query('visualizer');
      app.params.bundleUrl = url.query('bundleUrl');

      Polymer.Base.async(function() {
          var bundle;

          if(typeof app.params.bundleUrl === 'undefined') {
            // No bundle URL, load from LocalStorage
            try {
              bundle = JSON.parse(window.localStorage[app.params.visualizer]);

              // TODO: just load all to app? by Object.keys(bundle) app.key = ...
              app.visualizer = bundle.visualizer; // TODO: could differ from params.visualizer O_o check if same, otherwise show error?
              app.visualizationType = bundle.visualizationType;
              app.settings = bundle.settings;
              app.inputFiles = bundle.inputFiles;
            } catch (e) {
              window.alert('ERROR: Could not find bundle data from LocalStorage!');
            }
          }
          else {
            // Check if we used LocalStorage or need to download a bundle
            if(typeof app.params.bundleUrl !== 'undefined') {
              // Load the bundle, fairly hacky
              app.$.loadBundleAjax.addEventListener('bundle-changed', function() {
                var bundle = app.$.loadBundleAjax.bundle;
                // TODO: just load all to app? by Object.keys(bundle) app.key = ...
                app.visualizer = bundle.visualizer; // TODO: could differ from params.visualizer O_o check if same, otherwise show error?
                app.visualizationType = bundle.visualizationType;
                app.settings = bundle.settings;
                app.inputFiles = bundle.inputFiles;
              });
              // Load bundle data from URL
              app.$.loadBundleAjax.url = app.params.bundleUrl;
              app.$.loadBundleAjax.generateRequest();

              app.loadedFromBundle = true;
            }
          }
          // Otherwise load the bundle, this is done at first app dom-change
          // so the ajax elements are ready.
      },1);
    });

})(document);
