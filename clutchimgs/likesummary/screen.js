Backbone.Events.bind('clutch.initialized', function() {

// Simple table to show the people who have liked the given image
var LikeTable = Clutch.UI.Table.extend({
    numSections: 1,
    numCells: function(section) {
        return this.options.image.likes.length;
    },
    cell: function(section, row) {
        var user = this.options.image.likes[row];
        return new Clutch.UI.TableCell({value: user.username});
    }
});

Clutch.Core.callMethod('getInitialData', function(data) {
    var table = new LikeTable({image: data.image});
    $('body').append(table.render().el);
});

});