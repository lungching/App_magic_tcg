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
    library = shuffle( library );
    for( var i = 0; i < 7; i++) {
        var card = $( library.shift() );
        card.css('display', 'inline');
    }
});

var max_zindex = 100;
function startMovingCard(event, ui) {
    ui.helper.css('z-index', max_zindex++);
}

function shuffle(array) {
    var tmp, current, top = array.length;

    if(top) while(--top) {
        current = Math.floor(Math.random() * (top + 1));
        tmp = array[current];
        array[current] = array[top];
        array[top] = tmp;
    }

    return array;
}

function draw_card() {
    $( library.shift() ).css('display', 'inline').css('top', '100px').css('left', '15px').css('position', 'absolute').css('z-index', max_zindex);
    
}
