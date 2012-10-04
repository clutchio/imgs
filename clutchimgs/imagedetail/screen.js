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

// This is the global-ish variable where the user will be stored
var USER = null;

// Used to display an image detail entry, with full comments and likes etc.
var ImageDetail = Clutch.UI.View.extend({
    tagName: 'li',
    template: _.template($('#template-image-detail').html()),
    events: {
        'tap img.main': 'imagePopup',
        'tap a.like': 'likeTapped',
        'tap a.comment': 'commentTapped',
        'tap a.more': 'moreTapped',
        'tap a.like-summary': 'likeSummaryTapped',
        'click': 'preventClicks'
    },
    imagePopup: function(e) {
        Clutch.Core.callMethod('imagePopup', this.options.image);
    },
    likeTapped: function(e) {
        // First tell iOS that they tapped the image
        Clutch.Core.callMethod('likeTapped', this.options.image);

        // If they weren't logged in, then we know iOS kicked them to a login
        // screen, so just bail.
        if(!USER) {
            return;
        }

        // Otherwise they were logged in, make the change
        var created = _.pluck(this.options.image.likes, 'id').indexOf(USER.id) === -1;
        if(created) {
            this.options.image.likes.push(USER);
        } else {
            this.options.image.likes = _.reject(this.options.image.likes, function(user) {
                return user.id === USER.id;
            });
        }
        this.render();
    },
    likeSummaryTapped: function(e) {
        Clutch.Core.callMethod('likeSummaryTapped', this.options.image);
    },
    commentTapped: function(e) {
        Clutch.Core.callMethod('commentTapped', this.options.image, _.bind(function(data) {
            this.options.image.comments.push({
                user: USER,
                text: data.text
            });
            this.render();
        }, this));
    },
    moreTapped: function(e) {
        Clutch.Core.callMethod('moreTapped', this.options.image);
    },
    preventClicks: function(e) {
        e.stopPropagation();
        e.preventDefault();
    },
    render: function(force) {
        // Determine whether this user liked this image, for use in the
        // template context.
        var liked;
        if(USER) {
            liked = _.pluck(this.options.image.likes, 'id').indexOf(USER.id) !== -1;
        } else {
            liked = false;
        }

        // Render the template to this element
        $(this.el).html(this.template({
            user: USER,
            c: this.options,
            liked: liked
        }));
        
        return this;
    }
});

Clutch.Core.registerMethod('setUser', function(data) {
    USER = data;
});

if(Clutch.iOS) {
    Clutch.Core.callMethod('getInitialData', function(data) {
        if(data.user) {
            USER = data.user;
        }
        var imageDetail = new ImageDetail({
            image: data.image
        });
        $('#photo-detail').html(imageDetail.render().el);
    });
} else {
    var images = {"gallery":[{"hash":"xjy7M","title":"Yeah, you're right.","score":5681416,"views":352195,"bandwidth":"157.86 GB","size":481258,"datetime":"2012-01-18 02:44:51","mimetype":"image\/png","ext":".png","width":750,"height":492,"ups":552,"downs":19,"points":533,"reddit":"\/r\/funny\/comments\/olf7y\/yeah_youre_right\/","subreddit":"funny","firstpost_date":1326841207}]};
    var image = images.gallery[0];
    image.likes = [];
    image.comments = [];
    var imageDetail = new ImageDetail({image: image});
    $('#photo-detail').html(imageDetail.render().el);
}

});