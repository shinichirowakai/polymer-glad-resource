require! <[fs async jade browserify browserify-livescript]>

compile = (cb)->
  err, results <- async.parallel (
    fs.readdir-sync "#__dirname/../components"
    |> map (dir)->
      fs.readdir-sync "#__dirname/../components/#dir"
      |> map ( .match /([^.]+)\.\w+/ .1)
      |> unique
      |> map (name)->
        (next)->
          html = fs.read-file-sync "#__dirname/../components/#dir/#name.jade" |> jade.render
          err, content <- browserify "#__dirname/../components/#dir/#name.ls", transform: [browserify-livescript] .bundle
          js = content |> ( .to-string!) |> ("<script>" + ) |> ( + "</script>")
          fs.write-file-sync "#__dirname/../#name.html", (html + js)
          next!
    |> concat
  )
  cb!


do main = ->
  <- compile
  console.log \Built


