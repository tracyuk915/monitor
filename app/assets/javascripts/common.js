var product_line_mapping = {
    'Weibo' : ['SRMA', 'Publisher', 'Engage', 'Analytics'],
    'LinkedIn' : ['SRMA', 'Publisher', 'Engage', 'Analytics'],
    'SRMA' : ['Weibo', 'LinkedIn', 'Instagram'],
    'Publisher': ['Weibo', 'LinkedIn']
};

function loadTemplates(template, func){
    $.get('templates/'+template+'.html', function(templates) {
        $('body').append(templates);
        func.apply();
    });
}

function renderSingleCell(automation_set){
    $("#cell-container").loadTemplate($("#cell-template"), automation_set, {append:true});
    $("#"+automation_set['id']).loadTemplate($("#job-template"), automation_set['jobs']);
}

function renderCells(){
    $.ajax({
        method: "GET",
        url: "/automation_list",
    }).done(function(automation_sets){
        $.each(automation_sets, function(index, automation_set){
            renderSingleCell(automation_set);
        });
        $("#cell-container").loadTemplate($("#add-action-template"), {}, {append:true});

        renderConfigPanel();
        $(".add-cell").click(function(){ $(".bs-example-modal-lg").modal(); });
    });
}

$(document).ready(function(){
    loadTemplates('automation_set', function(){
        renderCells();
    });
});