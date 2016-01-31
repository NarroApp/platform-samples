<!DOCTYPE html>
<meta charset="utf-8">
<html>
  <head>

  </head>
  <body>
    <p>Here are your most recent Narro articles!</p>
    <p>
      <%= articles.map{ |article| article["title"] }.join(', ') %>
    </p>
  </body>
</html>
