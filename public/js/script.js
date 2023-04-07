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

$('section#create .question .button.delete, section#create .answer .button.delete').click(function() {
    console.log('hey');
    var question_numbers = []
    $('.content_container .question, .content_container .answer').each(function() {
        question_numbers.push($(this).data('local-id')); 
    });
    Math.floor(Math.max(...question_numbers));
    $('.content_container .question, .content_container .answer').each(function() {
        // if($(this).data('local-id') >= )
        question_numbers.push($(this).data('local-id')); 
    });
});

$('section#create .button.add_question').click(function() {
    var item, item_q_id, q_id;
    if($('.question.focus').length == 1) {
        item = $('.question.focus');
        item_q_id = parseInt(item.data('q-id'));
        q_id = item_q_id+1;
        if($('.answer[data-q-id="'+item_q_id+'"]').length > 0) {
            $('.answer[data-q-id="'+item_q_id+'"]').last().after('<div class="question" data-q-id="' + q_id + '"><p class="num">#' + q_id + '</p><input placeholder="Fråga" type="text" /><button class="button delete" type="button">Radera</button></div>');
        } else {
            item.after('<div class="question" data-q-id="' + q_id + '"><p class="num">#' + q_id + '</p><input placeholder="Fråga" type="text" /><button class="button delete" type="button">Radera</button></div>')
        }
    } else if($('.answer.focus').length == 1) {
        item = $('.answer.focus');
        item_q_id = parseInt(item.data('q-id'));
        q_id = item_q_id+1;
        $('.answer[data-q-id="'+item_q_id+'"]').last().after('<div class="question" data-q-id="' + q_id + '"><p class="num">#' + q_id + '</p><input placeholder="Fråga" type="text" /><button class="button delete" type="button">Radera</button></div>');
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
        $('.content_container').append('<div class="question" data-q-id="' + q_id + '"><p class="num">#' + q_id + '</p><input placeholder="Fråga" type="text" /><button class="button delete" type="button">Radera</button></div>');
    }
});

// $('section#create .button.add_answer').click(function() {

// item = $('.answer.focus');
// item_q_id = parseInt(item.data('q-id'));
// item_a_id = parseInt(item.data('a-id'));
// a_id = item_a_id+1;
// item.after('<div class="question" data-local-id="' + q_id + '"><p class="num">#' + q_id + '</p><input placeholder="Fråga" type="text" /><button class="button delete" type="button">Radera</button></div>');

//     console.log('hey');
//     let question_numbers = []
//     $('.content_container .question, .content_container .answer').each(function() {
//         question_numbers.push($(this).data('local-id'));
//         console.log(question_numbers); 
//     });
//     let hi = Math.max(...question_numbers);
//     if(Number.isInteger(hi)) {
//         var id = hi + 1;
//     } else {
//         var id = Math.ceil(hi);
//     }
//     $('.content_container').append('<div class="question" data-local-id="' + id + '"><p class="num">#' + id + '</p><input placeholder="Fråga" type="text" /><button class="button delete" type="button">Radera</button></div>');
// });

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