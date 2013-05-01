path = require( "path" )

class Style

  constructor: ( options ) ->
    @layout = options.layout
    @selector = options.selector
    @pixelRatio = options.pixelRatio || 1
    
    @resolveImageSelector = options.resolveImageSelector if options.resolveImageSelector
    @resolveImagePrefix = options.resolveImagePrefix if options.resolveImagePrefix

  css: ( selector, attributes ) ->
    "#{ selector } {\n#{ @cssStyle( attributes ) };\n}\n"
  
  cssStyle: ( attributes ) ->
    attributes.join ";\n"
  
  cssComment: ( comment ) ->
    "/*\n#{ comment }\n*/"
  
  resolveImageSelector: ( name ) ->
    name

  resolveImagePrefix: ->
    ''
  
  generate: ( options ) ->
    if @pixelRatio < 2
      { imagePath, relativeImagePath, images, pixelRatio } = options

      @pixelRatio = pixelRatio || 1
    
      styles = [
        @css @selector, [
          "  background: url( '#{ relativeImagePath }' ) no-repeat"
        ]
      ]
      for image in images
        attr = [
          "  width: #{ image.cssw }px"
          "  height: #{ image.cssh }px"
          "  background-position: #{ -image.cssx }px #{ -image.cssy }px"
        ]
        image.style = @cssStyle attr
        image.selector = @resolveImageSelector( image.name, image.path )
        prefix = @resolveImagePrefix( image.name, image.path )

        styles.push @css( prefix + [ @selector, image.selector ].join( '.' ), attr )
      
      styles.push ""
      css = styles.join "\n"
    else
      spriteHeight = options.layout.height / @pixelRatio
      spriteWidth = options.layout.width / @pixelRatio
      css = """
        @media
          (min--moz-device-pixel-ratio: #{@pixelRatio}),
          (-o-min-device-pixel-ratio: #{@pixelRatio}/1),
          (-webkit-min-device-pixel-ratio: #{@pixelRatio}),
          (min-device-pixel-ratio: #{@pixelRatio}) {
            .sprite {
              background: url( '#{options.relativeImagePath}' ) no-repeat;
              -moz-background-size: #{spriteWidth}px #{spriteHeight}px;
              -ie-background-size: #{spriteWidth}px #{spriteHeight}px;
              -o-background-size: #{spriteWidth}px #{spriteHeight}px;
              -webkit-background-size: #{spriteWidth}px #{spriteHeight}px;
              background-size: #{spriteWidth}px #{spriteHeight}px;
            }
          }
      """
    return css
  
  comment: ( comment ) ->
    @cssComment comment
  
module.exports = Style
