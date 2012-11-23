// Magical utility to make all cards draggable, always
(function ($) {
    $.fn.liveDraggable = function (opts) {
        this.live("mouseover", function() {
            if (!$(this).data("init")) {
                $(this).data("init", true).draggable(opts);
            }
        });
    };
})(jQuery);

var library;

$(document).ready(function() {
    $('img').liveDraggable({
        containment: 'window',
        start: startMovingCard,
        // stop: doneMovingCard
    });

    var images = $('img[name="library"]');
    library = $.makeArray(images);
    library.sort(function() { return 0.5 - Math.random() });
    for( var i = 0; i < 7; i++) {
        var card = $( library.shift() );
        card.css('display', 'inline');
    }
});

var max_zindex = 100;
function startMovingCard(event, ui) {
    ui.helper.css('z-index', max_zindex++);
}

