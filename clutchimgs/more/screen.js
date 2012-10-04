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

var USER = null;
var TABLE = null;

var MoreTable = Clutch.UI.Table.extend({
    style: 'grouped',
    numSections: 2,

    numCells: function(section) {
        if(section === 0) {
            return 3;
        } else if(section === 1) {
            return 1;
        }
    },

    initialize: function(options) {
        Clutch.UI.View.prototype.initialize.call(this, options);
        _.bindAll(this,
            'aboutTapped', 'logoutTapped', 'loginTapped', 'sendTapped',
            'emailTapped', 'aboutCell', 'accountCell'
        );
    },

    aboutTapped: function(e) {
        Clutch.Core.callMethod('aboutTapped');
    },

    logoutTapped: function(e) {
        Clutch.Core.callMethod('logoutTapped');
        USER = null;
        this.render();
    },

    loginTapped: function(e) {
        Clutch.Core.callMethod('loginTapped');
    },

    sendTapped: function(e) {
        setTimeout(function() {
            Clutch.Core.callMethod('sendTapped', {
                url: 'http://itunes.apple.com/us/app/imgs/id498626072?ls=1&mt=8',
                title:'Funny images app'
            });
            $('li.cell.selected', this.el).removeClass('selected');
        }, 100);
    },

    emailTapped: function(e) {
        Clutch.Core.callMethod('emailTapped', {
            subject: 'Feedback about Imgs',
            to: 'support@clutch.io',
            body: '',
            isHTML: false
        });
    },

    sectionHeader: function(section) {
        if(section === 0) {
            return new Clutch.UI.TableSectionHeader({value: 'About'});
        } else if(section === 1) {
            return new Clutch.UI.TableSectionHeader({value: 'Accounts'});
        }
    },

    aboutCell: function(row) {
        switch(row) {
            case 0:
                return new Clutch.UI.TableCell({
                    value: 'About',
                    accessory: Clutch.UI.Accessories.DisclosureButton,
                    tap: this.aboutTapped
                });
            case 1:
                return new Clutch.UI.TableCell({
                    value: 'Send to Friend',
                    accessory: Clutch.UI.Accessories.DisclosureButton,
                    tap: this.sendTapped
                });
            case 2:
                return new Clutch.UI.TableCell({
                    value: 'Questions? Comments?',
                    accessory: Clutch.UI.Accessories.DisclosureButton,
                    tap: this.emailTapped
                });
        }
    },

    accountCell: function(row) {
        var cell;
        if(USER) {
            cell = new Clutch.UI.TableCell({
                value: 'Logout',
                accessory: Clutch.UI.Accessories.DisclosureButton,
                tap: this.logoutTapped
            });
            $(cell.el).addClass('logout');
        } else {
            cell = new Clutch.UI.TableCell({
                value: 'Login',
                accessory: Clutch.UI.Accessories.DisclosureButton,
                tap: this.loginTapped
            });
            $(cell.el).addClass('login');
        }
        return cell;
    },

    cell: function(section, row) {
        return {
            0: this.aboutCell,
            1: this.accountCell
        }[section](row);
    }
});

Clutch.Core.registerMethod('setData', function(data) {
    USER = data.user;
    TABLE.render();
});

Clutch.Core.callMethod('getInitialData', function(data) {
    USER = data.user;
    TABLE = new MoreTable();
    $('#more').html(TABLE.render().el);
});

if(!Clutch.iOS) {
    TABLE = new MoreTable();
    $('#more').html(TABLE.render().el);
}

});