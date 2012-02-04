Backbone.Events.bind('clutch.initialized', function() {

var LoginOptions = Clutch.UI.View.extend({
    el: '#login-options',
    events: {
        'tap #login-btn': 'login',
        'tap #register-btn': 'register',
        'tap #facebook-btn': 'facebook',
        'click': 'preventClicks'
    },
    login: function(e) {
        Clutch.Core.callMethod('login');
    },
    register: function(e) {
        Clutch.Core.callMethod('register');
    },
    facebook: function(e) {
        Clutch.Core.callMethod('facebook');
    },
    preventClicks: function(e) {
        e.stopPropagation();
        e.preventDefault();
    }
});

var loginOptions = new LoginOptions();

});