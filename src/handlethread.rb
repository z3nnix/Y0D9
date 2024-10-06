def handle_thread_request(req, res, forum_instance, section)
  set_utf8_headers(res)

  thread_id = req.path.split('/').last.to_i
  
  if req.request_method == 'POST'
    # Decode the request body and safely access the 'comment' key
    params = URI.decode_www_form(req.body).to_h
    comment = params['comment'] ? params['comment'].strip : nil

    unless comment.nil? || comment.empty?
      forum_instance.add_comment(thread_id, comment)
    end

    res.set_redirect(WEBrick::HTTPStatus::SeeOther, "#{section}thread/#{thread_id}")
    return
  end
  
  if forum_instance.threads.any? { |thread| thread[:id] == thread_id && thread[:section] == section }
    thread = forum_instance.threads.find { |t| t[:id] == thread_id }

    eval(File.read("src/frontend/threads.html"))
    
  else
    puts "Thread not found for id: #{thread_id}" # Debugging output
    
    res.body = <<-HTML
      <html>
      <head>
        <title>404 - Страница не найдена</title>
      </head>

      <style>#{File.read("src/frontend/style.css")}</style>

      <body>
        <header class="header">
            <h1>404 - Страница не найдена</h1>
        </header>
        <main>
            <div align="center">
                <h2>К сожалению, такой тред не существует.</h2>
                <p>Вы можете вернуться на главную страницу.</p>
                <a href="/" class="theme-button">На главную</a><br><br>
            </div>
            <hr>
            <footer><a href="/rules">Правила</a> <br>Y0d9 — Борда <a href="https://z3nn1x.t.me">Zennix-а</a>.</footer>
        </main>
      </body>
      </html>
    HTML
    
    res.status = 404
  end
end
