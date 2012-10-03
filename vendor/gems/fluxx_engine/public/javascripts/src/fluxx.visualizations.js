(function($){
  $.fn.extend({
    renderChart: function() {
      return this.each(function() {
        var $chart = $(this);
        if ($chart.children().length > 0)
          return;

        var data = $.parseJSON($chart.html());
        var saveHTML = $chart.html();
        $chart.html('').show().parent();
        var chartID = 'chart' + $.fluxx.visualizations.counter++;
        if (data) {
          var $card;

          if (typeof $chart.fluxxCard == 'function') {
            $card = $chart.fluxxCard();
          } else {
            $card = $('#hand');
          }
          if (data.hasOwnProperty('class'))
              $card.fluxxCardDetail().addClass(data['class']);
          if (data.hasOwnProperty('width'))
              $card.fluxxCardDetail().width(data.width);

          $chart.html("").append('<div id="' + chartID + '"></div>');
          $.jqplot.config.enablePlugins = true;

          if (data.type == 'bar') {
            if (!data.seriesDefaults)
              data.seriesDefaults = {};
            data.seriesDefaults.renderer = $.jqplot.BarRenderer;
          }

         if (data.axes && data.axes.xaxis && data.axes.xaxis.ticks.length > 0 && !$.isArray(data.axes.xaxis.ticks[0]))
           data.axes.xaxis.renderer = $.jqplot.CategoryAxisRenderer;
         var error = false;
         try {
           plot = $.jqplot(chartID, data.data, {
            axesDefaults: {
              tickRenderer: $.jqplot.CanvasAxisTickRenderer ,
              tickOptions: {
                fontSize: '10pt'
              }
            },
            title: {show: false},
            width: $chart.css('width'),
            stackSeries: data.stackSeries,
            grid:{background:'#fefbf3', borderWidth:2.5},
            seriesDefaults: data.seriesDefaults,
            axes: data.axes,
            series: data.series
           });
         } catch(e) {
           $chart.html(saveHTML);
           error = true;
         }
         if (!error) {
            var legend = {};
            _.each(plot.series, function(key) {
              legend[key.label] = key;
            });

            $('.legend table.legend-table tr', $card).each(function() {
             var $td = $('td:first', $(this));
             if ($td.length) {
               $td.prepend('<span class="legend-color-swatch" style="background-color: ' + legend[$.trim($td.text())].color + '"/>');
             }
            })
            .hover(function(e) {
              var $td = $('td:first', $(this));
              legend[$.trim($td.text())].canvas._elem.css('opacity', '.5');
            }, function(e) {
              var $td = $('td:first', $(this));
              legend[$.trim($td.text())].canvas._elem.css('opacity', '1');
            });
          }
        }
      });
    }
  });
  $.extend(true, {
    fluxx: {
      visualizations: {
        counter: 0
      }
    }
  });

})(jQuery);
