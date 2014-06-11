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
                    "width":$(el).parent().width(),
                    "height":$(el).parent().outerHeight()
                });
            });

            $(".line_chart").each(function(){
                draw_line_chart(animate, $(this));
            });

            $(".doughnut_chart").each(function(){
                draw_doughnut_chart(animate, $(this));
            });

            var m = 0;
            $(".widget").height("");
            $(".widget").each(function(i,el){ m = Math.max(m,$(el).height()); });
            $(".widget").height(m);
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

    function draw_line_chart(animation, $this){
        var options = get_animation({}, animation);

        var chart_data = create_dataset($this);
        var weeks = $this.parent().data('weeks');
        var data = {
            labels : weeks,
            datasets : chart_data
        }

        var ctx = $this.get(0).getContext("2d");
        new Chart(ctx).Line(data, options);
    }

    function create_dataset($this){
        var selected = getSelectedConferences($this);
        var chart_data = $this.parent().data('chart');
        var conferences = $this.parent().data('conferences');
        var result = [];

        for(var i in conferences){
            if(selected.indexOf(conferences[i].short_title) >= 0){
                var options = {};
                options.fillColor = "rgba(255,255,255,0.0)";
                options.strokeColor = conferences[i].color;
                options.data = chart_data[conferences[i].short_title];
                result.push(options)
            }
        }
        return result
    }

    function getSelectedConferences($this){
        var name = $this.data('name');
        var id = '#' + name + 'Checkboxes'
        var selected = []
        $(id + ' input').each(function(){
            if($(this).is(":checked")) {
                selected.push($(this).attr('name'));
            }
        })
        return selected;
    }

    $('.conferenceCheckboxes input').change(function(){
        var chart = $(this).parent().data('chart');
        var $canvas = $('#' + chart + 'Chart');
        draw_line_chart(false, $canvas);
    });

    $(window).on('resize', function(){ size(false); });

    size(true);
});
