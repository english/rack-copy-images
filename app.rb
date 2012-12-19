require 'rack'
require 'haml'
require 'pry'
require 'webrick'

app = Rack::Builder.app {
  use Rack::Reloader
  run lambda { |env|
    request = Rack::Request.new(env)
    body = Haml::Engine.new(DATA.read).render(Object.new, { params: request.params })

    [200, {"Content-Type" => "text/html"}, [body]]
  }
}

options = { Port: '3000', Host: '127.0.0.1' }
server = ::WEBrick::HTTPServer.new(options)
server.mount '/', Rack::Handler::WEBrick, app
Thread.new do
  server.start
end

sleep 10
server.stop

puts 'end'

__END__
!!!
%head
  %script{src: "https://raw.github.com/Phrogz/context-blender/master/context_blender.js", type: "text/javascript"}
%body
  %canvas#offScreenCanvas{style: 'position: absolute; left: -9999999px;'}
  %canvas#difference
  %img#animation{src: params['filepath'], style: 'display: none'}
  %img#oldImage{style: 'display: none'}
  %img#newImage{style: 'display: none'}

  #buttonBar{style: 'width: 400px; margin: 0px auto'}
    %button#differenceButton Difference
    %button#animationButton Animation
    %button#oldImageButton Old Image
    %button#newImageButton New Image
  :javascript
    var compaa = {
      differenceGifPath: '#{params["filepath"]}',
      oldImagePath: '#{params["filepath"].gsub('gif','png').gsub('_difference.png','').gsub('differences_in_screenshots_this_run','reference_screenshots')}',
      newImagePath: '#{params["filepath"].gsub('gif','png').gsub('_difference.png','').gsub('differences_in_screenshots_this_run','screenshots_generated_this_run')}',

      init: function() {
        var oldImg=document.createElement('img');
        oldImg.src = compaa.oldImagePath
        
        var newImg=document.createElement('img');
        newImg.src = compaa.newImagePath

        document.getElementById('difference').width = oldImg.width;
        document.getElementById('difference').height = oldImg.height;

        document.getElementById('offScreenCanvas').width = newImg.width;
        document.getElementById('offScreenCanvas').height = newImg.height;
        
        var over = document.getElementById('offScreenCanvas').getContext('2d'); 
        over.drawImage(oldImg, 0, 0);

        var under = document.getElementById('difference').getContext('2d');
        under.drawImage(newImg, 0, 0);

        over.blendOnto(under,'difference');

        document.getElementById('oldImage').src = compaa.oldImagePath;
        document.getElementById('newImage').src = compaa.newImagePath;

        compaa.show('difference');

        document.getElementById('differenceButton').onclick = function(){compaa.show('difference')};
        document.getElementById('animationButton').onclick = function(){compaa.show('animation')};
        document.getElementById('oldImageButton').onclick = function(){compaa.show('oldImage')};
        document.getElementById('newImageButton').onclick = function(){compaa.show('newImage')};
      },
      show: function(mode) {
        document.getElementById('difference').style.display = 'none';
        document.getElementById('animation').style.display = 'none';
        document.getElementById('oldImage').style.display = 'none';
        document.getElementById('newImage').style.display = 'none';
        
        switch(mode){
          case 'difference':
            document.getElementById('difference').style.display = 'block';
            break;
          case 'animation':
            document.getElementById('animation').style.display = 'block';
            break;
          case 'oldImage':
            document.getElementById('oldImage').style.display = 'block';
            break;
          case 'newImage':
            document.getElementById('newImage').style.display = 'block';
            break;
        }
      }
    }

    document.onreadystatechange = function () {
      if (document.readyState == "complete" || document.readyState == "interactive") {
        compaa.init();
      }
    }
