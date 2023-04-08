
function makeQuestion(q_id) {
    return `<div class="question" data-q-id="${q_id}"><p class="num">#${q_id}</p><input placeholder="Fråga" type="text" /><button class="button delete" type="button">Radera</button></div>`;
}

function makeAnswer(q_id, a_id) {
    return `<div class="answer" data-q-id="${q_id}" data-a-id="${a_id}"><p class="num">#${q_id}.${a_id}</p><input placeholder="Svar" type="text" /><button class="button delete" type="button">Radera</button></div>`;
}


$(document).ready(function() {

$('section#yours .button.desc').click(function() {
    var container = $(this).parents('.quiz_list').find('.desc_container');
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
    if(container.hasClass('login')) {
        container.removeClass('login');
        container.addClass('signup');
    } else {
        container.removeClass('signup');
        container.addClass('login');
    }
});

$('section#create .content_container').on('click', '.question, .answer, .question *, .answer *', function() { // väljer fråga eller svar
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

$('section#create .button.add_question').click(function() { // skapar ny fråga
    var item, item_q_id, q_id, a_id;
    if($('.focus').length == 1) { // om någon fråga eller något svar är valt

        item = $('.focus');
        item_q_id = parseInt(item.data('q-id')); // hämtar question id från valt element

        $(`.focus ~ .question, .focus ~ .answer:not(.answer[data-q-id="${item_q_id}"])`).each(function() { // uppdaterar värden för frågor och svar som kommer hamna efter den nya frågan (egentligen efter det valda elementet, men det är samma sak)
            if($(this).hasClass('question')) {
                q_id = parseInt($(this).data('q-id'))+1; // skapar nytt question id
                $(this).attr('data-q-id', q_id); // stoppar in nytt q-id i datan
                $(this).find('p.num').text(`#${q_id}`); // stoppar in nytt q-id i texten
            } else if($(this).hasClass('answer')) {
                q_id = parseInt($(this).data('q-id'))+1;
                a_id = parseInt($(this).data('a-id'));
                $(this).attr('data-q-id', q_id);
                $(this).find('p.num').text(`#${q_id}.${a_id}`);
            }
        });
        
        q_id = item_q_id+1; // definierar question id för den nya frågan

        if($('.question.focus').length == 1) { // om det är en fråga som är vald
            if($(`.answer[data-q-id="${item_q_id}"]`).length > 0) { // om den valda frågan har svar
                $(`.answer[data-q-id="${item_q_id}"]`).last().after(makeQuestion(q_id)); // skapar frågan efter det sista svaret med samma question id som det den valda frågan
            } else {
                item.after(makeQuestion(q_id));
            }
        } else if($('.answer.focus').length == 1) { // om det är ett svar som är valt
            $(`.answer[data-q-id="${item_q_id}"]`).last().after(makeQuestion(q_id)); // skapar frågan efter det sista svaret med samma question id som det valda svaret
        }
    } else { // om inget element är valt
        item = $('.question').last();
        q_id = parseInt(item.data('q-id'))+1;
        item.parent().append(makeQuestion(q_id)); // lägger ny fråga sist i listan
    }
});

$('section#create .button.add_answer').click(function() { // skapar nytt svar
    var item, item_a_id, q_id, a_id;
    if($('.focus').length == 1) { // om någon fråga eller något svar är valt

        if($('.question.focus').length == 1) { // om det är en fråga som är vald

            item = $('.question.focus'); 
            q_id = parseInt(item.data('q-id')); // hämtar question id från valt element (vilket är samma q-id som det nya svaret ska få)

            if($(`.answer[data-q-id="${q_id}"]`).length > 0) { // om den valda frågan har svar
                item = $(`.answer[data-q-id="${q_id}"]`).last(); 
                a_id = parseInt(item.data('a-id'))+1;
                item.after(makeAnswer(q_id, a_id)); // skapar svaret efter det sista svaret med samma question id som den valda frågan
            } else {
                item.after(makeAnswer(q_id, 1));
            }

        } else if($('.answer.focus').length == 1) { // om det är ett svar som är valt

            item = $('.answer.focus');
            q_id = parseInt(item.data('q-id'));
            item_a_id = parseInt(item.data('q-id'));

            $(`.answer.focus ~ .answer[data-q-id="${q_id}"]`).each(function() { // uppdaterar värden för svar som kommer hamna efter det nya svaret (egentligen efter det valda svaret, men det är samma sak)
                a_id = parseInt($(this).data('a-id'))+1; // skapar nytt answer id
                $(this).attr('data-a-id', a_id); // stoppar in nytt a-id i data
                $(this).find('p.num').text(`#${q_id}.${a_id}`); // stoppar in nytt id i texten
            });

            a_id = item_a_id+1;
            item.after(makeAnswer(q_id, a_id)); // skapar svaret efter det valda svaret
        }
    } else { // om inget element är valt
        item = $('.question').last();
        q_id = item.data('q-id');
        if($(`.answer[data-q-id="${q_id}"]`).length > 0) {
            item = $(`.answer[data-q-id="${q_id}"]`).last();
            a_id = parseInt(item.data('a-id'))+1;
            item.after(makeAnswer(q_id, a_id)); // skapar svaret efter det sista svaret efter den sista frågan
        } else {
            item.after(makeAnswer(q_id, 1));
        }
    }
});

$('section#create .button.delete, section#create .button.delete').click(function() {

});

});

