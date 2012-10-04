//
// Copyright 2012 Twitter
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

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