$(function() {
    var t;
    function size(animate){
        if (animate == undefined){
            animate = false;
        }
        clearTimeout(t);
        t = setTimeout(function(){
            $("canvas").each(function(i,el){
                    $(el).attr({
                        "width":$(el).parent().width()
                    });
            });

            $(".line_chart").each(function(){
                draw_line_chart(animate, $(this));
            });

            $(".doughnut_chart").each(function(){
                if($(this).is(":visible")){
                    draw_doughnut_chart(animate, $(this));
                }
            });

        }, 30);
    }

    function draw_doughnut_chart(animation, $this){
        var options = get_animation({}, animation);
        var tmp = $this.data('chart');

        if(jQuery.isEmptyObject(tmp)){
            // Append error message if there is no data
            $this.parent().append("<h4 class=\"text-warning\">No data!</h4>");
            // Remove canvas
            $this.remove();
        }else{
            var data = [];
            for (var key in tmp) {
                data.push(tmp[key]);
            }

            var ctx = $this.get(0).getContext("2d");
            new Chart(ctx).Doughnut(data, options);
        }
    }

    function get_animation(options, animation){
        if (!animation){
            options.animation = false;
        } else {
            options.animation = true;
        }
        return options;
    }

    function draw_line_chart(animation, $canvas){
        var options = get_animation({}, animation);
        var chart_data = create_dataset($canvas);
        var weeks = $canvas.parent().data('weeks');
        var data = {
            labels : weeks,
            datasets : chart_data
        }

        var ctx = $canvas.get(0).getContext("2d");
        new Chart(ctx).Line(data, options);
    }

    function create_dataset($canvas){
        var selected = getSelectedConferences($canvas);
        var chart_data = $canvas.parent().data('chart');
        var conferences = $canvas.parent().data('conferences');
        var result = [];

        for(var i in conferences){
            if(selected.indexOf(conferences[i].short_title) >= 0){
                var options = {};
                options.fillColor = "rgba(255,255,255,0.0)";
                options.strokeColor = conferences[i].color;
                options.data = chart_data[conferences[i].short_title];
                if(options.data == null || options.data.length == 0){
                    options.data = [0];
                }
                result.push(options)
            }
        }
        return result
    }

    function getSelectedConferences($canvas){
        var name = $canvas.data('name');
        var id = '#' + name + 'Checkboxes'
        var selected = [];
        var $checkboxes = $(id + ' input');
        // If there are checkboxes -> get selected
        // Else -> use the active conference
        if($checkboxes.length){
            $(id + ' input').each(function(){
                if($(this).is(":checked")) {
                    selected.push($(this).attr('name'));
                }
            });
        }else{
            var active = $canvas.parent().data('active');
            for(i in active){
                selected.push(active[i].short_title)
            }
        }
        return selected;
    }

    $('.conferenceCheckboxes input').change(function(){
        var chart_name = $(this).parent().data('chart');
        var $canvas = $('#line_chart_' + chart_name);
        draw_line_chart(false, $canvas);
    });

    $(window).on('resize', function(){
        size(false);
    });

    $('#doughnut_tabs a').click(function (e) {
        e.preventDefault();
        $(this).tab('show');
        size(false);
    });

    size(true);
});
