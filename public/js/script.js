$(document).ready(function() {

$('section#yours .button.desc').click(function() {
    console.log('yo');
    var container = $(this).parents('.quiz_list').find('.desc_container');
    console.log(container);
    if(container.hasClass('open')) {
        $(this).text('View description');
        container.removeClass('open');
    } else {
        $(this).text('Close description');
        container.addClass('open');
    }
});

$('section#forms .button.switch_forms').click(function() {
    container = $('.form_container');
    console.log('yo');
    if(container.hasClass('login')) {
        container.removeClass('login');
        container.addClass('signup');
    } else {
        container.removeClass('signup');
        container.addClass('login');
    }
});

$('section#create .button.delete, section#create .button.delete').click(function() {

});

$('section#create .button.add_question').click(function() {
    var item, item_q_id, q_id, a_id;
    if($('.focus').length == 1) {

        $('.question').each(function() {
            if(parseInt($(this).data('q-id')) > parseInt($('.focus').data('q-id'))) {
                q_id = parseInt($(this).data('q-id'))+1;
                $(this).attr('data-q-id', q_id);
                $(this).find('p.num').text(`#${q_id}`);
            }
        });
        $('.answer').each(function() {
            if(parseInt($(this).data('q-id')) > parseInt($('.focus').data('q-id'))) {
                q_id = parseInt($(this).data('q-id'))+1;
                a_id = parseInt($(this).data('q-id'));
                $(this).attr('data-q-id', q_id);
                $(this).find('p.num').text(`#${q_id}.${a_id}`);
            }
        });

        if($('.question.focus').length == 1) {
            item = $('.question.focus');
            item_q_id = parseInt(item.data('q-id'));
            q_id = item_q_id+1;
            if($(`.answer[data-q-id="${item_q_id}"]`).length > 0) {
                $(`.answer[data-q-id="${item_q_id}"]`).last().after(`<div class="question" data-q-id="${q_id}"><p class="num">#${q_id}</p><input placeholder="Fråga" type="text" /><button class="button delete" type="button">Radera</button></div>`);
            } else {
                item.after(`<div class="question" data-q-id="${q_id}"><p class="num">#${q_id}</p><input placeholder="Fråga" type="text" /><button class="button delete" type="button">Radera</button></div>`)
            }
        } else if($('.answer.focus').length == 1) {
            item = $('.answer.focus');
            item_q_id = parseInt(item.data('q-id'));
            q_id = item_q_id+1;
            $(`.answer[data-q-id="${item_q_id}"]`).last().after(`<div class="question" data-q-id="${q_id}"><p class="num">#${q_id}</p><input placeholder="Fråga" type="text" /><button class="button delete" type="button">Radera</button></div>`);
        }
    } else {
        var hi = 1;
        $('.question, .answer').each(function() {
            item_q_id = parseInt($(this).data('q-id'));
            console.log(item_q_id);
            if(item_q_id > hi) {
                hi = item_q_id;
                console.log(hi);
            }
        });
        q_id = hi+1;
        $('.content_container').append(`<div class="question" data-q-id="${q_id}"><p class="num">#${q_id}</p><input placeholder="Fråga" type="text" /><button class="button delete" type="button">Radera</button></div>`);
    }
});

$('section#create .button.add_answer').click(function() {
    var item, item_q_id, item_a_id, q_id, a_id;
    if($('.focus').length == 1) {

        if($('.question.focus').length == 1) {

            item = $('.question.focus');
            q_id = parseInt(item.data('q-id'));

            if($(`.answer[data-q-id="${q_id}"]`).length > 0) {

                var hi = 1;
                $(`.answer[data-q-id="${q_id}"]`).each(function() {
                    item_a_id = parseInt($(this).data('a-id'));
                    if(item_a_id > hi) {
                        hi = item_a_id;
                    }
                });
                a_id = hi+1;

                $(`.answer[data-q-id="${q_id}"]`).last().after(`<div class="answer" data-q-id="${q_id}" data-a-id="${a_id}"><p class="num">#${q_id}.${a_id}</p><input placeholder="Svar" type="text" /><button class="button delete" type="button">Radera</button></div>`);
            } else {
                item.after(`<div class="answer" data-q-id="${q_id}" data-a-id="1"><p class="num">#${q_id}.1</p><input placeholder="Svar" type="text" /><button class="button delete" type="button">Radera</button></div>`);
            }

        } else if($('.answer.focus').length == 1) {

            $('.answer').each(function() {
                if(parseInt($(this).data('q-id')) > parseInt($('.focus').data('q-id'))) {
                    q_id = parseInt($(this).data('q-id'))+1;
                    a_id = parseInt($(this).data('q-id'));
                    $(this).attr('data-q-id', q_id);
                    $(this).find('p.num').text(`#${q_id}.${a_id}`);
                }
            });

            item = $('.answer.focus');
            item_q_id = parseInt(item.data('q-id'));
            q_id = item_q_id+1;
            $(`.answer[data-q-id="${item_q_id}"]`).last().after(`<div class="question" data-q-id="${q_id}"><p class="num">#${q_id}</p><input placeholder="Fråga" type="text" /><button class="button delete" type="button">Radera</button></div>`);
        }
    } else {
        var hi = 1;
        $('.question, .answer').each(function() {
            item_q_id = parseInt($(this).data('q-id'));
            console.log(item_q_id);
            if(item_q_id > hi) {
                hi = item_q_id;
                console.log(hi);
            }
        });
        q_id = hi+1;
        $('.content_container').append(`<div class="question" data-q-id="${q_id}"><p class="num">#${q_id}</p><input placeholder="Fråga" type="text" /><button class="button delete" type="button">Radera</button></div>`);
    }
});

});

$('section#create .content_container').on('click', '.question, .answer, .question *, .answer *', function() {
    console.log($(this));
    if(!$(this).hasClass('question') && !$(this).hasClass('answer')) {
        var item = $(this).parents('.question, .answer');
        if(!item.hasClass('focus')) {
            $('.question, .answer').removeClass('focus');
            item.addClass('focus');
        }
    } else if(!$(this).hasClass('focus')) {
        $('.question, .answer').removeClass('focus');
        $(this).addClass('focus');
    }
});