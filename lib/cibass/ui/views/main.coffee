$ ->
  $('.succeed-stage').live 'click', ->
    stage = $(this).parents('.stage').data('id')
    build = $(this).parents('.build').data('id')
    project = "main"
    url = "/#{project}/#{build}/#{stage}/succeeded"
    console.log url
    $.ajax {
      type: 'PUT',
      url:  url
    }
    false
  $('.fail-stage').live 'click', ->
    stage = $(this).parents('.stage').data('id')
    build = $(this).parents('.build').data('id')
    project = "main"
    url = "/#{project}/#{build}/#{stage}/failed"
    console.log url
    $.ajax {
      type: 'PUT',
      url:  url
    }
    false

  socket = new WebSocket('ws://localhost:3000/ws')
  socket.onmessage = (msg) ->
    data = $.parseJSON(msg.data)
    console.log data

    $('#container').empty()

    $(data['main'].builds).each ->
      stages_html = ""
      $(this.stages).each ->
        button = if this.state == 'not_started'
          """
            <a href="#" class="succeed-stage">Succeed</a>
            <a href="#" class="fail-stage">Fail</a>
          """
        else
          ''
        stages_html += "<div class='stage' data-id='#{this.id}'>#{this.id}: #{this.state} #{button}</div>"
      html = """
        <article data-id='#{this.id}' class='build'>
          <h1>#{this.id}</h1>
          #{stages_html}
        </article>
      """
      $('#container').append(html)
