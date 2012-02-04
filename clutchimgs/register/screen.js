Backbone.Events.bind('clutch.initialized', function() {

var RegisterForm = Clutch.UI.View.extend({
    el: '#register-form',
    events: {
        'submit': 'handleSubmit'
    },
    handleSubmit: function(e) {
        e.stopPropagation();
        e.preventDefault();
        Clutch.Core.callMethod('submit', {
            username: $('#username').val(),
            password: $('#password').val(),
            email: $('#email').val()
        });
    }
});

var registerForm = new RegisterForm();

});