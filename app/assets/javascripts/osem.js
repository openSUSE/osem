$(function() {
    $('.dropdown-toggle').dropdown();
    $("#conference-start-datepicker").datepicker({
        dateFormat: 'yy/mm/dd',
        numberOfMonths: 2,
        onSelect: function(selected) {
            $("#conference-end-datepicker").datepicker("option","minDate", selected)
        }
    });
    $("#conference-end-datepicker").datepicker({
        dateFormat: 'yy/mm/dd',
        numberOfMonths: 2,
        onSelect: function(selected) {
            $("#conference-start-datepicker").datepicker("option","maxDate", selected)
            $("#cfp-hard-datepicker").datepicker("option","minDate", selected)

        }
    });

    $("#cfp-hard-datepicker").datepicker({
        dateFormat: 'yy/mm/dd',
        numberOfMonths: 2,
        onSelect: function(selected) {
            $("#conference-end-datepicker").datepicker("option","maxDate", selected)
            $("#conference-start-datepicker").datepicker("option","maxDate", selected)

        }
    });

    $("#conference-reg-start-datepicker").datetimepicker({
        dateFormat: "yy-mm-dd",
        timeFormat: "HH:mm",
        showSecond: false,
        numberOfMonths: 2,
        onSelect: function(selected) {
            $("#conference-reg-end-datepicker").datepicker("option","minDate", selected)
        }
    });

    $("#conference-reg-end-datepicker").datetimepicker({
        dateFormat: "yy-mm-dd",
        timeFormat: "HH:mm",
        showSecond: false,
        numberOfMonths: 2,
        onSelect: function(selected) {
            $("#conference-reg-start-datepicker").datepicker("option","maxDate", selected)
        }
    });

    $(".comment-reply-link").click(function(){
        $(".comment-reply", $(this).parent()).toggle();
        return false;
    });

    $("#event-comment-link").click(function(){
        $("#comments-div").toggle();
        return false;
    });

    $(".comment-reply").hide();
    $(".user-details-popover").popover();
    $("#comments-div").hide();
    
    $("#votes-div").hide();
    $("#votes-link").click(function(){
      $("#votes-div").toggle();
      return false;
    });
});

function word_count(text, divId, maxcount) {
    var r = 0;
    var input = text.value.replace(/\s/g,' ');
    var word_array = input.split(' ');
    for (var i=0; i < word_array.length; i++) {
        if (word_array[i].length > 0) r++;
    }

    $('#' + divId).text(r);
    if (r > maxcount) {
        console.log("R is greater than maxcount");
        $('#' + divId).css('color', 'red');
    } else {
        console.log("R is less than maxcount");
        $('#' + divId).css('color', '#333');
    }
};


/* Set the defaults for DataTables initialisation */
$.extend( true, $.fn.dataTable.defaults, {
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "oLanguage": {
        "sLengthMenu": "_MENU_ items per page"
    }
} );

/* Default class modification */
$.extend( $.fn.dataTableExt.oStdClasses, {
    "sWrapper": "dataTables_wrapper form-inline"
} );

/* API method to get paging information */
$.fn.dataTableExt.oApi.fnPagingInfo = function ( oSettings )
{
    return {
        "iStart":         oSettings._iDisplayStart,
        "iEnd":           oSettings.fnDisplayEnd(),
        "iLength":        oSettings._iDisplayLength,
        "iTotal":         oSettings.fnRecordsTotal(),
        "iFilteredTotal": oSettings.fnRecordsDisplay(),
        "iPage":          oSettings._iDisplayLength === -1 ?
            0 : Math.ceil( oSettings._iDisplayStart / oSettings._iDisplayLength ),
        "iTotalPages":    oSettings._iDisplayLength === -1 ?
            0 : Math.ceil( oSettings.fnRecordsDisplay() / oSettings._iDisplayLength )
    };
};

$.fn.dataTableExt.oApi.fnReloadAjax = function ( oSettings, sNewSource, fnCallback, bStandingRedraw )
{
    if ( typeof sNewSource != 'undefined' && sNewSource != null ) {
        oSettings.sAjaxSource = sNewSource;
    }

    // Server-side processing should just call fnDraw
    if ( oSettings.oFeatures.bServerSide ) {
        this.fnDraw();
        return;
    }

    this.oApi._fnProcessingDisplay( oSettings, true );
    var that = this;
    var iStart = oSettings._iDisplayStart;
    var aData = [];

    this.oApi._fnServerParams( oSettings, aData );

    oSettings.fnServerData.call( oSettings.oInstance, oSettings.sAjaxSource, aData, function(json) {
        /* Clear the old information from the table */
        that.oApi._fnClearTable( oSettings );

        /* Got the data - add it to the table */
        var aData =  (oSettings.sAjaxDataProp !== "") ?
            that.oApi._fnGetObjectDataFn( oSettings.sAjaxDataProp )( json ) : json;

        for ( var i=0 ; i<aData.length ; i++ )
        {
            that.oApi._fnAddData( oSettings, aData[i] );
        }

        oSettings.aiDisplay = oSettings.aiDisplayMaster.slice();

        if ( typeof bStandingRedraw != 'undefined' && bStandingRedraw === true )
        {
            oSettings._iDisplayStart = iStart;
            that.fnDraw( false );
        }
        else
        {
            that.fnDraw();
        }

        that.oApi._fnProcessingDisplay( oSettings, false );

        /* Callback user function - for event handlers etc */
        if ( typeof fnCallback == 'function' && fnCallback != null )
        {
            fnCallback( oSettings );
        }
    }, oSettings );
};

/* Bootstrap style pagination control */
$.extend( $.fn.dataTableExt.oPagination, {
    "bootstrap": {
        "fnInit": function( oSettings, nPaging, fnDraw ) {
            var oLang = oSettings.oLanguage.oPaginate;
            var fnClickHandler = function ( e ) {
                e.preventDefault();
                if ( oSettings.oApi._fnPageChange(oSettings, e.data.action) ) {
                    fnDraw( oSettings );
                }
            };

            $(nPaging).addClass('pagination').append(
                '<ul>'+
                    '<li class="prev disabled"><a href="#">&larr; '+oLang.sPrevious+'</a></li>'+
                    '<li class="next disabled"><a href="#">'+oLang.sNext+' &rarr; </a></li>'+
                    '</ul>'
            );
            var els = $('a', nPaging);
            $(els[0]).bind( 'click.DT', { action: "previous" }, fnClickHandler );
            $(els[1]).bind( 'click.DT', { action: "next" }, fnClickHandler );
        },

        "fnUpdate": function ( oSettings, fnDraw ) {
            var iListLength = 5;
            var oPaging = oSettings.oInstance.fnPagingInfo();
            var an = oSettings.aanFeatures.p;
            var i, ien, j, sClass, iStart, iEnd, iHalf=Math.floor(iListLength/2);

            if ( oPaging.iTotalPages < iListLength) {
                iStart = 1;
                iEnd = oPaging.iTotalPages;
            }
            else if ( oPaging.iPage <= iHalf ) {
                iStart = 1;
                iEnd = iListLength;
            } else if ( oPaging.iPage >= (oPaging.iTotalPages-iHalf) ) {
                iStart = oPaging.iTotalPages - iListLength + 1;
                iEnd = oPaging.iTotalPages;
            } else {
                iStart = oPaging.iPage - iHalf + 1;
                iEnd = iStart + iListLength - 1;
            }

            for ( i=0, ien=an.length ; i<ien ; i++ ) {
                // Remove the middle elements
                $('li:gt(0)', an[i]).filter(':not(:last)').remove();

                // Add the new list items and their event handlers
                for ( j=iStart ; j<=iEnd ; j++ ) {
                    sClass = (j==oPaging.iPage+1) ? 'class="active"' : '';
                    $('<li '+sClass+'><a href="#">'+j+'</a></li>')
                        .insertBefore( $('li:last', an[i])[0] )
                        .bind('click', function (e) {
                            e.preventDefault();
                            oSettings._iDisplayStart = (parseInt($('a', this).text(),10)-1) * oPaging.iLength;
                            fnDraw( oSettings );
                        } );
                }

                // Add / remove disabled classes from the static elements
                if ( oPaging.iPage === 0 ) {
                    $('li:first', an[i]).addClass('disabled');
                } else {
                    $('li:first', an[i]).removeClass('disabled');
                }

                if ( oPaging.iPage === oPaging.iTotalPages-1 || oPaging.iTotalPages === 0 ) {
                    $('li:last', an[i]).addClass('disabled');
                } else {
                    $('li:last', an[i]).removeClass('disabled');
                }
            }
        }
    }
} );

/* Commodity function for modal windows */

window.build_dialog = function(selector, content) {
  // Close it and remove content if it's already open
  $("#" + selector).modal('hide');
  $("#" + selector).remove();
  // Add new content and pops it up
  $("body").append("<div id=\"" + selector + "\" class=\"modal fade\" role=\"dialog\">\n" + content + "</div>");
  $("#" + selector).modal();
}
