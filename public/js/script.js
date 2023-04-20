
function makeQuestion(qid) {
    return `<div class="question" qid="${qid}"><p class="num">#${qid}</p><input placeholder="Fråga" type="text" name="question" />`;
}

function makeAnswer(qid, aid) {
    return `<div class="answer" qid="${qid}" aid="${aid}"><p class="num">#${qid}.${aid}</p><input placeholder="Svar" type="text" name="answer" /><select name="correct"><option value="0">Fel</option><option value="1">Rätt</option></select></div>`;
}

function prepareQuizSubmit(type) {
    var content = [];
    var q, a, qid;

    if($('.question').length == 0) { // validering
        alert("Quiz saknar frågor.");
        return false; 
    }

    $('.question').each(function() {
        q = {}; // object
        q['answers'] = []

        qid = parseInt($(this).attr('qid'));
        if($(`.answer[qid="${qid}"]`).length == 0) { // validering
            alert("Fråga saknar svar.");
            return false; 
        }

        q['id'] = qid;
        q['text'] = $(this).find('input[name="question"]').first().val();

        $(`.answer[qid="${qid}"]`).each(function() {
            a = {}; // object
            a['id'] = parseInt( $(this).attr('aid') );
            a['text'] = $(this).find('input[name="answer"]').first().val();
            a['correct'] = parseInt( $(this).find('select[name="correct"]').first().val() );
            q['answers'].push(a);
        })
        content.push(q);
    });
    var json = JSON.stringify(content);

    if(type == "create") {
        $('form.create').append(`<input type="hidden" name="content" value='${json}'>`);
    } else if(type == "edit") {
        json_current = $('.content_container');
        if(json != json_current) {
            $('form.edit').append(`<input type="hidden" name="content" value='${json}' current='${json_current}'>`);
        } else {
            $('input[name="content"]').remove(); // om någon skickar in post och sedan återvändre med bak-pil, kommer elementet finnas kvar även om de ångrar ändringarna i content, därför ser vi till att den inte finns såhär
        }
        if($('input[name="owners"]').val() != $('input[name="owners"]').attr('current')) {
            $('form.edit').append('<input type="hidden" name="owners_changed" value="true">');
        }
    }
}

$(document).ready(function() {

$('section#yours .button.desc').click(function() {
    var container = $(this).parents('.quiz_list > li').find('.desc_container');
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

$('section#create .content_container, section#edit .content_container').on('click', '.question, .answer, .question *, .answer *', function() { // väljer fråga eller svar
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

$('section#create .button.add_question, section#edit .button.add_question').click(function() { // skapar ny fråga
    var item, item_qid, qid, aid;
    if($('.question').length > 100) { return } // validering, max 100 frågor per quiz

    if($('.focus').length == 1) { // om någon fråga eller något svar är valt

        item = $('.focus');
        item_qid = parseInt(item.attr('qid')); // hämtar question id från valt element

        $(`.focus ~ .question, .focus ~ .answer:not(.answer[qid="${item_qid}"])`).each(function() { // uppdaterar värden för frågor och svar som kommer hamna efter den nya frågan (egentligen efter det valda elementet, men det är samma sak)
            if($(this).hasClass('question')) {
                qid = parseInt($(this).attr('qid'))+1; // skapar nytt question id
                $(this).attr('qid', qid); // stoppar in nytt qid i datan
                $(this).find('p.num').text(`#${qid}`); // stoppar in nytt qid i texten
            } else if($(this).hasClass('answer')) {
                qid = parseInt($(this).attr('qid'))+1;
                aid = parseInt($(this).attr('aid'));
                $(this).attr('qid', qid);
                $(this).find('p.num').text(`#${qid}.${aid}`);
            }
        });
        
        qid = item_qid+1; // skapar nytt question id

        if(item.hasClass('question')) { // om det är en fråga som är vald
            if($(`.answer[qid="${item_qid}"]`).length > 0) { // om den valda frågan har svar
                $(`.answer[qid="${item_qid}"]`).last().after(makeQuestion(qid)); // skapar frågan efter det sista svaret med samma question id som det den valda frågan
            } else {
                item.after(makeQuestion(qid));
            }
        } else if(item.hasClass('answer')) { // om det är ett svar som är valt
            $(`.answer[qid="${item_qid}"]`).last().after(makeQuestion(qid)); // skapar frågan efter det sista svaret med samma question id som det valda svaret
        }
    } else { // om inget element är valt
        item = $('.question').last();
        qid = parseInt(item.attr('qid'))+1;
        item.parent().append(makeQuestion(qid)); // lägger ny fråga sist i listan
    }
});

$('section#create .button.add_answer, section#edit .button.add_answer').click(function() { // skapar nytt svar
    var item, qid, aid;
    if($('.focus').length == 1) { // om någon fråga eller något svar är valt

        item = $('.focus');
        if(item.hasClass('question')) { // om det är en fråga som är vald

            qid = parseInt(item.attr('qid')); // hämtar question id från valt element (vilket är samma qid som det nya svaret ska få)
            if($(`.answer[qid="${qid}"]`).length > 12) { return; } // validering, max 12 svar per fråga

            if($(`.answer[qid="${qid}"]`).length > 0) { // om den valda frågan har svar
                item = $(`.answer[qid="${qid}"]`).last(); 
                aid = parseInt(item.attr('aid'))+1;
                item.after(makeAnswer(qid, aid)); // skapar svaret efter det sista svaret med samma question id som den valda frågan
            } else {
                item.after(makeAnswer(qid, 1));
            }

        } else if(item.hasClass('answer')) { // om det är ett svar som är valt

            qid = parseInt(item.attr('qid'));
            if($(`.answer[qid="${qid}"]`).length > 12) { return; } // validering, max 12 svar per fråga

            $(`.answer.focus ~ .answer[qid="${qid}"]`).each(function() { // uppdaterar värden för svar som kommer hamna efter det nya svaret (egentligen efter det valda svaret, men det är samma sak)
                aid = parseInt($(this).attr('aid'))+1; // skapar nytt answer id
                $(this).attr('aid', aid); // stoppar in nytt aid i data
                $(this).find('p.num').text(`#${qid}.${aid}`); // stoppar in nytt id i texten
            });

            aid = parseInt(item.attr('aid'))+1;
            item.after(makeAnswer(qid, aid)); // skapar svaret efter det valda svaret
        }
    } else { // om inget element är valt

        item = $('.question').last();
        qid = item.attr('qid');
        if($(`.answer[qid="${qid}"]`).length > 12) { return } // validering, max 12 svar per fråga

        if($(`.answer[qid="${qid}"]`).length > 0) {
            item = $(`.answer[qid="${qid}"]`).last();
            aid = parseInt(item.attr('aid'))+1;
            item.after(makeAnswer(qid, aid)); // skapar svaret efter det sista svaret efter den sista frågan
        } else {
            item.after(makeAnswer(qid, 1));
        }
    }
});

$('.content_container .button.delete').click(function() { // raderar valt element (fråga eller svar)
    var item_qid, qid, item_aid, aid;
    if($('.focus').length == 1) {
        const item = $('.focus');
        if(item.hasClass('question')) {

            if($('.question').length == 1) { return } // validering, man kan inte slänga alla frågor, det måsta alltid finnas minst en

            item_qid = parseInt(item.attr('qid'));
            $(`.question[qid="${item_qid}"] ~ .question, .question[qid="${item_qid+1}"] ~ .answer`).each(function() { // uppdaterar värden för frågor och svar som ligger efter dem frågan som ska raderas
                if($(this).hasClass('question')) {
                    qid = parseInt($(this).attr('qid'))-1; // skapar nytt question id
                    $(this).attr('qid', qid); // stoppar in nytt qid i datan
                    $(this).find('p.num').text(`#${qid}`); // stoppar in nytt qid i texten
                } else if($(this).hasClass('answer')) {
                    qid = parseInt($(this).attr('qid'))-1;
                    aid = parseInt($(this).attr('aid'));
                    $(this).attr('qid', qid);
                    $(this).find('p.num').text(`#${qid}.${aid}`);
                }
            });

            $(`.answer[qid="${item_qid}"]`).remove();
    
        } else if(item.hasClass('answer')) {
    
            qid = parseInt(item.attr('qid'));
            item_aid = parseInt(item.attr('aid'));
            $(`.answer[aid="${item_aid}"] ~ .answer[qid="${qid}"]`).each(function() { // uppdaterar värden för svar (med samma qid som det svaret som ska raderas) som ligger efter det svaret som ska raderas
                aid = parseInt($(this).attr('aid'))-1; // skapar nytt answer id
                $(this).attr('aid', aid); // stoppar in nytt aid i data
                $(this).find('p.num').text(`#${qid}.${aid}`); // stoppar in nytt id i texten
            });
    
        }
        item.remove();
    }  
});

});

