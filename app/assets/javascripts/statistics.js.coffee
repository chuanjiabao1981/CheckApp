# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/$ ->
$ ->
  $("select#statistics_zone_id").live "change", ->
    organization_chooser = $(":selected",this).attr("data-organization_chooser")
    currnet_organization_chooser = $(".organization_chooser")
    $("select", currnet_organization_chooser).remove()
    $("div.templates div."+organization_chooser).children().clone().appendTo currnet_organization_chooser

$ ->
  organization_chooser = $("select#statistics_zone_id option:selected").attr('data-organization_chooser');
  currnet_organization_chooser = $(".organization_chooser")
  $("select", currnet_organization_chooser).remove()
  $("div.templates div."+organization_chooser).children().clone().appendTo currnet_organization_chooser


$ ->
  chart   = undefined
  chart_x = undefined
  $(document).ready ->
    chart_x         = $('div#reports-x').data('reports-x')
    chart_series    = $('div#reports-statistics').data('reports-statistics')
    chart_org       = $('div#reports-org').data('reports-org')
    chart_group_by  = $('div#reports-group-by').data('reports-group-by')
    return  if chart_series is `undefined`
    chart = new Highcharts.Chart(
      chart:
        renderTo: "container"
        type: "line"
        marginRight: 130
        marginBottom: 75

      title:
        text: chart_org + "工作统计"
        x: -20 #center

      subtitle:
        text: chart_x[0].split("-")[0] + "年"+ chart_x[0].split("-")[1] + chart_group_by  +  "--" + chart_x[chart_x.length - 1].split("-")[0] + "年" + chart_x[chart_x.length - 1].split("-")[1] + chart_group_by
        x: -20

      xAxis:
        categories: chart_x
        tickInterval:2
        labels:{align:'right',rotation:-45},
        showLastLabel:true
        showFirstLabel:true
        endOnTick: true


      yAxis:
        title:
          text: "每周检查(次数)"

        min: 0

        plotLines: [
          value: 0
          width: 1
          color: "#808080"
        ]

      tooltip:
        formatter: ->
          "<b>" + @series.name + "</b><br/>" + @x+ "周: " + @y + "次"

      legend:
        layout: "vertical"
        align: "right"
        verticalAlign: "top"
        x: 0
        y: 100
        borderWidth: 0

      series: chart_series
    )




