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
                redraw(animate, $(this));
            });

            var m = 0;
            $(".widget").height("");
            $(".widget").each(function(i,el){ m = Math.max(m,$(el).height()); });
            $(".widget").height(m);
        }, 30);
    }

    function redraw(animation, $this){
        var options = {};
        if (!animation){
            options.animation = false;
        } else {
            options.animation = true;
        }

        var chart_data = create_dataset($this);
        var weeks = $this.parent().data('weeks');
        var data = {
            labels : weeks,
            datasets : chart_data
        }

        var canvas = $this[0];
        var ctx = canvas.getContext("2d");
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
        redraw(false, $canvas);
    });

    $(window).on('resize', function(){ size(false); });

    size(true);
});
