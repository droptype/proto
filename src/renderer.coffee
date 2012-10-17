CoffeeScript    = require 'coffee-script'
Jade            = require 'jade'
Stylus          = require 'stylus'

VERSION         = require './VERSION'



compileScriptFile = (script_source) ->
    return CoffeeScript.compile(script_source.toString())

compileMarkupFile = (markup_source) ->
    template = Jade.compile(markup_source.toString())
    return template()

compileStyleFile = (style_source) ->
    compiled_style = ''
    # This isn't actually async, just bonkers.
    Stylus.render style_source.toString(), (err, data) ->
        compiled_style = data
    return compiled_style

compileScriptLibraries = (script_libraries) ->
    script_libs = ''
    for lib in script_libraries
        script_libs += "<script src='#{ lib }'></script>"
    return script_libs

compileStyleLibraries = (style_libraries) ->
    style_libs = ''
    for lib in style_libraries
        style_libs += "<link rel='stylesheet' href='#{ lib }' type='text/css'>"
    return style_libs

compileExtraHeadMarkup = (markup) ->
    if not markup
        return ''
    else
        return markup

compositePage = (compiled) ->
    page = """
    <!-- Generated by https://github.com/droptype/proto v#{ VERSION } -->
    <!doctype html>
    <html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        #{ compiled.script_libraries }
        #{ compiled.style_libraries }
        #{ compiled.extra_head_markup }
        <style>
            #{ compiled.style }
        </style>
    </head>
    <body>
        #{ compiled.markup }
        <script>
            #{ compiled.script }
        </script>
        #{ compiled.extra_body_markup }
    </body>
    </html>
    """
    return page

doCompilation = (sources) ->
    output = compositePage
        style               : compileStyleFile(sources.style)
        script              : compileScriptFile(sources.script)
        markup              : compileMarkupFile(sources.markup)
        script_libraries    : compileScriptLibraries(sources.settings.script_libraries)
        style_libraries     : compileStyleLibraries(sources.settings.style_libraries)
        extra_head_markup   : compileExtraHeadMarkup(sources.settings.extra_head_markup)
        extra_body_markup   : sources.extra_body or ''
    return output


module.exports = (sources) ->
    return doCompilation(sources)