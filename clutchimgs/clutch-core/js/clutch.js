(function() {

var Clutch = {};

Clutch.VERSION = '0.4';

Clutch.iOS = $.os.ios;

var _initialized = false;
var _callbackNum = 1;
var _callbacks = {};
var _methodRegistry = {};

var callMethod = null;
if($.os.android) {
    callMethod = function(method, args, callback) {
        if(args && _.isFunction(args)) {
            callback = args;
            args = {};
        }
        var callbackNum = 0;
        if(callback && _.isFunction(callback)) {
            callbackNum = _callbackNum++ % 1000000;
            _callbacks[callbackNum] = callback;
        }
        prompt(JSON.stringify({method: method, callbackNum: '' + callbackNum, args: args || {}}), 'methodCalled');
    };
} else {
    callMethod = function(method, args, callback) {
        if(args && _.isFunction(args)) {
            callback = args;
            args = {};
        }
        var callbackNum = 0;
        if(callback && _.isFunction(callback)) {
            callbackNum = _callbackNum++ % 1000000;
            _callbacks[callbackNum] = callback;
        }
        var iframe = document.createElement('iframe');
        iframe.setAttribute('src', '/___mobilerpc___/' + method + '/' + callbackNum + '/' + encodeURIComponent(JSON.stringify(args || {})));
        document.documentElement.appendChild(iframe);
        iframe.parentNode.removeChild(iframe);
        iframe = null;
    };
}

Clutch.Core = {
    registerMethod: function(method, func) {
        if(!_methodRegistry[method]) {
            _methodRegistry[method] = [];
        }
        _methodRegistry[method].push(func);
    },

    callCallback: function(i, data) {
        var callback = _callbacks[i];
        if(!callback) {
            return;
        }
        callback(data);
        delete _callbacks[i];
        callback = null;
    },

    callMethod: callMethod,

    methodCalled: function(method, args) {
        var methods = _methodRegistry[method] || [];
        for(var i = 0; i < methods.length; ++i) {
            methods[i](args);
        }
    },

    bottomReached: function() {
        Backbone.Events.trigger('clutch.bottomReached');
    },
    
    init: function(func) {
        if(_initialized) {
            func();
        }
        Backbone.Events.bind('clutch.initialized', func);
    }
};

Clutch.Load = {
    begin: function(text, top) {
        Clutch.Core.callMethod('clutch.loading.begin', {
            text: text || null,
            top: top || null
        });
    },
    end: function() {
        Clutch.Core.callMethod('clutch.loading.end');
    }
};

var ClutchView = Backbone.View.extend({
    template: _.template('<%= c.value %>'),

    initialize: function(options) {
        var extraClasses = this.extraClasses || [];
        for(var i = 0; i < extraClasses.length; ++i) {
            $(this.el).addClass(extraClasses[i]);
        }
    },

    render: function() {
        $(this.el).html(this.template({c: this.options}));
        return this;
    }
});

Clutch.UI = {

    View: ClutchView,

    Table: ClutchView.extend({
        tagName: 'div',
        className: 'table',

        render: function() {
            $(this.el).html('');

            var _self = this;
            function maybeApply(maybeFunc) {
                if(_.isFunction(maybeFunc)) {
                    var args = Array.prototype.slice.call(arguments);
                    args.shift();
                    return maybeFunc.apply(_self, args);
                }
                return maybeFunc;
            }
            
            if(this.style) {
                $(this.el).addClass(this.style);
            }

            var th = maybeApply(this.tableHeader);
            if(th) {
                $(this.el).append(th.render().el);
            }

            for(var i = 0; i < maybeApply(this.numSections); ++i) {
                var section = $('<div class="section"></div>');

                var sh = maybeApply(this.sectionHeader, i);
                if(sh) {
                    section.append(sh.render().el);
                }

                var cells = $('<ul class="cells"></ul>');
                for(var j = 0; j < maybeApply(this.numCells, i); ++j) {
                    cells.append(maybeApply(this.cell, i, j).render().el);
                }
                section.append(cells);

                var sf = maybeApply(this.sectionFooter, i);
                if(sf) {
                    section.append(sf.render().el);
                }

                $(this.el).append(section);
            }

            var tf = maybeApply(this.tableFooter);
            if(tf) {
                $(this.el).append(tf.render().el);
            }

            return this;
        }

    }),

    TableHeader: ClutchView.extend({className: 'table-header'}),
    TableFooter: ClutchView.extend({className: 'table-footer'}),
    TableSectionHeader: ClutchView.extend({className: 'section-header'}),
    TableSectionFooter: ClutchView.extend({className: 'section-footer'}),

    TableCell: ClutchView.extend({
        /* arguments: value, accessory */
        tagName: 'li',
        multiline: false,
        className: 'cell',
        template: _.template('<%= c.value %>'),
        events: {
            'touchselect': 'handleSelect',
            'tap': 'handleTap'
        },
        initialize: function(options) {
            ClutchView.prototype.initialize.call(this, options);
            if(this.options.accessory) {
                $(this.el).addClass('accessory-' + this.options.accessory);
            }
            if(this.multiline) {
                $(this.el).addClass('multi');
            }
        },
        handleSelect: function() {
            $('li.cell.selected').removeClass('selected');
            $(this.el).addClass('selected');
        },
        handleTap: function(e) {
            if(!this.options.tap) {
                return;
            }
            this.options.tap.apply(this, [e]);
        }
    }),

    Accessories: {
        Checkmark: 'checkmark',
        DisclosureButton: 'disclosure-button',
        DisclosureIndicator: 'disclosure-indicator'
    }

};

function setupTapEvents() {
    var touch = {};

    function parentIfText(node){
        return 'tagName' in node ? node : node.parentNode;
    }

    $(document.body).bind('touchstart', function(e) {
        touch.target = parentIfText(e.touches[0].target);
        touch.x1 = e.touches[0].pageX;
        touch.y1 = e.touches[0].pageY;
    }).bind('touchmove', function(e) {
        touch.x2 = e.touches[0].pageX;
        touch.y2 = e.touches[0].pageY;
        if(Math.abs(touch.x1 - touch.x2) > 25 || Math.abs(touch.y1 - touch.y2) > 25) {
            touch.scrolled = true;
        }
    }).bind('touchend', function(e) {
        if(!touch.scrolled) {
            $(touch.target).trigger('touchselect');
            $(touch.target).trigger('tap');
        }
        touch = {};
    }).bind('touchcancel', function() {
        touch = {};
    });
}

function setupTableDeselecter() {
    Clutch.Core.registerMethod('clutch.viewDidAppear', function() {
        $('li.cell.selected').removeClass('selected');
    });
}

function setupViewport() {
    if(Clutch.iOS) {
        $('head').append('<meta content="width=device-width, user-scalable=no, initial-scale=.5" name="viewport">');
    }
}

$(document).ready(function() {
    setupTapEvents();
    setupTableDeselecter();
    setupViewport();
    _initialized = true;
    Backbone.Events.trigger('clutch.initialized');
});

window.Clutch = Clutch;

})();