Backbone.Events.bind('clutch.initialized', function() {


var LoginForm = Clutch.UI.View.extend({
    el: '#login-form',
    events: {
        'submit': 'handleSubmit'
    },
    handleSubmit: function(e) {
        e.stopPropagation();
        e.preventDefault();
        Clutch.Core.callMethod('submit', {
            username: $('#username').val(),
            password: $('#password').val()
        });
    }
});

var loginForm = new LoginForm();

});