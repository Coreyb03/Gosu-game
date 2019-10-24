require 'gosu'

class Tutorial < Gosu::Window
  def initialize
    super 640, 480
    self.caption = "Tutorial Game"

    @background_image = Gosu::Image.new("media/space.png", :tileable => true)

    @player = Player.new
    @player.warp(320, 240)

    @star_anim = Gosu::Image.load_tiles("media/star.png",25,25)
    @stars = Array.new

    @laser = Laser.new
    @font = Gosu::Font.new(20)
    @font = Gosu::Font.new(30)
  end
  
  def update
    if Gosu.button_down? Gosu::KB_LEFT or Gosu::button_down? Gosu::GP_LEFT
        @player.turn_left
    end

    if Gosu.button_down? Gosu::KB_RIGHT or Gosu::button_down? Gosu::GP_RIGHT
        @player.turn_right
    end

    if Gosu.button_down? Gosu::KB_UP or Gosu::button_down? Gosu::GP_BUTTON_0
        @player.accelerate
    end

    if Gosu.button_down? Gosu::KB_MINUS
        @player.birb
    end

    if @player.score % 100 == 0&&@player.score > 0
        @laser.warp(-400)
    end
    @laser.shoot
    @player.move
    @player.collect_stars(@stars)

    if rand(100) < 6 and @stars.size < 25
        @stars.push(Star.new(@star_anim))
    end
end
  
  def draw
    @player.draw
    @background_image.draw(0,0,ZOrder::BACKGROUND)
    @stars.each { |star| star.draw}
    @font.draw("Score: #{@player.score}",10,10,ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
    @laser.draw
  end

    def button_down(id)
        if id == Gosu::KB_ESCAPE
            close
        else
            super
        end
    end

end

module ZOrder
    BACKGROUND, STARS, PLAYER, UI = *0..3
end

class Player
    attr_reader :score

    def initialize
        @image = Gosu::Image.new("media/starfighter.bmp")
        @beep = Gosu::Sample.new("media/beep.wav")
        @x = @y = @vel_x = @vel_y = @angle = 0.0
        @score = 0
    end

    def scorecheck
        @image = Gosu::Image.new("media/bird.png")
    end

    def warp(x,y)
        @x , @y = x, y
    end

    def birb
        @image = Gosu::Image.new("media/bird.png")
    end

    def turn_left 
        @angle -= 4.5
    end
    
    def turn_right
        @angle += 4.5
    end

    def accelerate
        @vel_x += Gosu.offset_x(@angle, 0.5)
        @vel_y += Gosu.offset_y(@angle, 0.5)
    end

    def move
        @x += @vel_x
        @y += @vel_y
        @x %= 640
        @y %= 480

        @vel_x *= 0.95
        @vel_y *= 0.95
    end

    def draw 
        @image.draw_rot(@x, @y, 1, @angle)
    end

    def score 
        @score
    end
    def collect_stars(stars)
        playersize = @image.width
        stars.reject! do |star| 
            if Gosu.distance(@x, @y, star.x, star.y)< playersize
                @score += 10
                @beep.play
                true
            else
                false
            end
        end
    end
end

class Star
    attr_reader :x, :y

    def initialize(animation)
        @animation = animation
        @color = Gosu::Color::BLACK.dup
        @color.red = rand(256 - 40) + 40
        @color.green = rand(256 - 40) + 40
        @color.blue = rand(256 -40) + 40
        @x = rand * 640
        @y = rand * 480
    end

    def draw  
        img = @animation[Gosu.milliseconds / 100 % @animation.size]
        img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
            ZOrder::STARS, 1, 1, @color, :add)
    end
end

class Laser

    def initialize
        @x = rand(0 - 640)
        @y = 1000
        @angle = 0
        @laser = Gosu::Image.new("media/laser.jpg")
    end

    def draw
        @laser.draw_rot(@x, @y, 1, @angle)
    end

    def warp(y)
        @y = y
    end

    def shoot 
        @y += 5
    end
end

Tutorial.new.show