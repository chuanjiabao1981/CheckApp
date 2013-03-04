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
