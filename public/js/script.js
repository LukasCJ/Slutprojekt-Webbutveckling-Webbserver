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
    console.log('hey');
    let question_numbers = []
    $('.content_container .question, .content_container .answer').each(function() {
        question_numbers.push($(this).data('local-id'));
        console.log(question_numbers); 
    });
    let hi = Math.max(...question_numbers);
    if(Number.isInteger(hi)) {
        var id = hi + 1;
    } else {
        var id = Math.ceil(hi);
    }
    $('.content_container').append('<div class="question" data-local-id="' + id + '"><p class="num">#' + id + '</p><input placeholder="Fråga" type="text" /><button class="button delete" type="button">Radera</button></div>');
});

$('section#create .question, section#create .answer').click(function() {
    if(!$(this).hasClass('focus')) {
        $('.content_container .question, .content_container .answer').each(function() {
            $(this).removeClass('focus');
        });
        $(this).addClass('focus');
    }
});

});

