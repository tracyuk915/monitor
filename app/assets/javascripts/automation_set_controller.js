function renderConfigPanel(){
    var productLineChanged = function (){
        var productLine = $("#productLine").val();
        var products = new Array();
        $.each(product_line_mapping[productLine], function(index, value){
            products.push({'product': value});
        });
        $("#products").loadTemplate($("#product-template"), products);
        $('[name=product]').click(productClicked);
    };

    var productClicked = function(){
        var allVals = [];
        $('input[name=product]:checked').each(function() {
            allVals.push($(this).val());
        });
    };

    var monitorItBtnClicked = function(){
        var auto_set = {
            id: "set4",
            name: 'Joe Bloggs2',
            jobs:[
                {
                    job_id : 1,
                    job_url: 'http://www.baidu.com',
                    job_name: "Job1",
                    build_id: 23,
                    build_status: "running"
                },
                {
                    job_url: 'http://www.baidu.com',
                    job_name: "Job2",
                    job_status: "running",
                    build_id: 24,
                    build_status: "running"
                }
            ]
        };
        $("#cell-container").loadTemplate($("#cell-template"), auto_set, {prepend:true});
        $('.bs-example-modal-lg').modal('hide');
    };

    var product_lines = new Array();
    $.each(product_line_mapping, function(key, value){
        product_lines.push({'productLine': key});
    });
    $("#productLine").loadTemplate($("#product-line-template"), product_lines);
    $("#productLine").change(productLineChanged);
    $("#monitorItBtn").click(monitorItBtnClicked);

    productLineChanged();
}

