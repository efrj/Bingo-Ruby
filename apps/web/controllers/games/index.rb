module Web
  module Controllers
    module Games
      class Index
        include Web::Action

        expose :games

        def call(params)
          @games = GameRepository.new.all
        end
      end
    end
  end
end
