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